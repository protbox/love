-- love.audio


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------OBJECTS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- RecordingDevice (love.audio.get_recording_devices)
love.test.audio.RecordingDevice = function(test)

  -- skip recording device on runners, they cant emulate it
  if GITHUB_RUNNER then
    return test:skip_test('cant emulate recording devices in CI')
  end

  -- check devices first
  local devices = love.audio.get_recording_devices()
  if #devices == 0 then
    return test:skip_test('cant test this works: no recording devices found')
  end

  -- check object created and basics
  local device = devices[1]
  test:assert_object(device)
  test:assert_match({1, 2}, device:get_channel_count(), 'check channel count is 1 or 2')
  test:assert_not_equals(nil, device:get_name(), 'check has name')

  -- check initial data is empty as we haven't recorded anything yet 
  test:assert_not_nil(device:get_bit_depth())
  test:assert_equals(nil, device:get_data(), 'check initial data empty')
  test:assert_equals(0, device:get_sample_count(), 'check initial sample empty')
  test:assert_not_nil(device:get_sample_rate())
  test:assert_false(device:is_recording(), 'check not recording')

  -- start recording for a short time
  local startrecording = device:start(32000, 4000, 16, 1)
  test:wait_frames(10)
  test:assert_true(startrecording, 'check recording started')
  test:assert_true(device:is_recording(), 'check now recording')
  test:assert_equals(4000, device:get_sample_rate(), 'check sample rate set')
  test:assert_equals(16, device:get_bit_depth(), 'check bit depth set')
  test:assert_equals(1, device:get_channel_count(), 'check channel count set')
  local recording = device:stop()
  test:wait_frames(10)

  -- after recording 
  test:assert_false(device:is_recording(), 'check not recording')
  test:assert_equals(nil, device:get_data(), 'using stop should clear buffer')
  test:assert_object(recording)

end


-- Source (love.audio.new_source)
love.test.audio.Source = function(test)

  -- create stereo source
  local stereo = love.audio.new_source('resources/click.ogg', 'static')
  test:assert_object(stereo)

  -- check stereo props
  test:assert_equals(2, stereo:get_channel_count(), 'check stereo src')
  test:assert_range(stereo:get_duration("seconds"), 0, 0.1, 'check stereo seconds')
  test:assert_not_nil(stereo:get_free_buffer_count())
  test:assert_equals('static', stereo:get_type(), 'check stereo type')

  -- check cloning a stereo
  local clone = stereo:clone()
  test:assert_equals(2, clone:get_channel_count(), 'check clone stereo src')
  test:assert_range(clone:get_duration("seconds"), 0, 0.1, 'check clone stereo seconds')
  test:assert_not_nil(clone:get_free_buffer_count())
  test:assert_equals('static', clone:get_type(), 'check cloned stereo type')

  -- mess with stereo playing
  test:assert_false(stereo:is_playing(), 'check not playing')
  stereo:set_looping(true)
  stereo:play()
  test:assert_true(stereo:is_playing(), 'check now playing')
  test:assert_true(stereo:is_looping(), 'check now playing')
  stereo:pause()
  stereo:seek(0.01, 'seconds')
  test:assert_equals(0.01, stereo:tell('seconds'), 'check seek/tell')
  stereo:stop()
  test:assert_false(stereo:is_playing(), 'check stopped playing')

  -- check volume limits
  stereo:set_volume_limits(0.1, 0.5)
  local min, max = stereo:get_volume_limits()
  test:assert_range(min, 0.1, 0.2, 'check min limit')
  test:assert_range(max, 0.5, 0.6, 'check max limit')

  -- check setting volume
  stereo:set_volume(1)
  test:assert_equals(1, stereo:get_volume(), 'check set volume')
  stereo:set_volume(0)
  test:assert_equals(0, stereo:get_volume(), 'check set volume')

  -- change some get/set props that can apply to stereo
  stereo:set_pitch(2)
  test:assert_equals(2, stereo:get_pitch(), 'check pitch change')

  -- create mono source
  local mono = love.audio.new_source('resources/clickmono.ogg', 'stream')
  test:assert_object(mono)
  test:assert_equals(1, mono:get_channel_count(), 'check mono src')
  test:assert_equals(2927, mono:get_duration("samples"), 'check mono seconds')
  test:assert_equals('stream', mono:get_type(), 'check mono type')

  -- air absorption
  test:assert_equals(0, mono:get_air_absorption(), 'get air absorption')
  mono:set_air_absorption(1)
  test:assert_equals(1, mono:get_air_absorption(), 'set air absorption')

  -- cone
  mono:set_cone(0, 90*(math.pi/180), 1)
  local ia, oa, ov = mono:get_cone()
  test:assert_equals(0, ia, 'check cone ia')
  test:assert_equals(math.floor(9000*(math.pi/180)), math.floor(oa*100), 'check cone oa')
  test:assert_equals(1, ov, 'check cone ov')

  -- direction
  mono:set_direction(3, 1, -1)
  local x, y, z = mono:get_direction()
  test:assert_equals(3, x, 'check direction x')
  test:assert_equals(1, y, 'check direction y')
  test:assert_equals(-1, z, 'check direction z')

  -- relative
  mono:set_relative(true)
  test:assert_true(mono:is_relative(), 'check set relative')

  -- position
  mono:set_position(1, 2, 3)
  x, y, z = mono:get_position()
  test:assert_equals(x, 1, 'check pos x')
  test:assert_equals(y, 2, 'check pos y')
  test:assert_equals(z, 3, 'check pos z')

  -- velocity
  mono:set_velocity(1, 3, 4)
  x, y, z = mono:get_velocity()
  test:assert_equals(x, 1, 'check velocity x')
  test:assert_equals(y, 3, 'check velocity x')
  test:assert_equals(z, 4, 'check velocity x')

  -- rolloff
  mono:set_rolloff(1)
  test:assert_equals(1, mono:get_rolloff(), 'check rolloff set')

  -- create queue source
  local queue = love.audio.new_queueable_source(44100, 16, 1, 3)
  local sdata = love.sound.new_sound_data(1024, 44100, 16, 1)
  test:assert_object(queue)
  local run = queue:queue(sdata)
  test:assert_true(run, 'check queued sound')
  queue:stop()

  -- check making a filer
  local setfilter = stereo:set_filter({
    type = 'lowpass',
    volume = 0.5,
    highgain = 0.3
  })
  test:assert_true(setfilter, 'check filter applied')
  local filter = stereo:get_filter()
  test:assert_equals('lowpass', filter.type, 'check filter type')
  test:assert_equals(0.5, filter.volume, 'check filter volume')
  test:assert_range(filter.highgain, 0.3, 0.4, 'check filter highgain')
  test:assert_equals(nil, filter.lowgain, 'check filter lowgain')

  -- add an effect
  local effsource = love.audio.new_source('resources/click.ogg', 'static')
  love.audio.set_effect('testeffect', {
    type = 'flanger',
    volume = 0.75
  })
  local seteffect, err = effsource:set_effect('testeffect', {
    type = 'highpass',
    volume = 0.3,
    lowgain = 0.1
  })

  -- both these fail on 12 using stereo or mono, no err
  test:assert_true(seteffect, 'check effect was applied')
  local filtersettings = effsource:get_effect('effectthatdoesntexist', {})
  test:assert_not_nil(filtersettings)

  love.audio.stop(stereo)
  love.audio.stop(mono)
  love.audio.stop(effsource)

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.audio.get_active_effects
love.test.audio.get_active_effects = function(test)
  -- check we get a value
  test:assert_not_nil(love.audio.get_active_effects())
  -- check setting an effect active
  love.audio.set_effect('testeffect', {
    type = 'chorus',
    volume = 0.75
  })
  test:assert_equals(1, #love.audio.get_active_effects(), 'check 1 effect running')
  test:assert_equals('testeffect', love.audio.get_active_effects()[1], 'check effect details')
end


-- love.audio.get_active_source_count
love.test.audio.get_active_source_count = function(test)
  -- check we get a value
  test:assert_not_nil(love.audio.get_active_source_count())
  -- check source isn't active by default
  local testsource = love.audio.new_source('resources/click.ogg', 'static')
  love.audio.stop(testsource)
  test:assert_equals(0, love.audio.get_active_source_count(), 'check not active')
  -- check playing a source marks it as active
  love.audio.play(testsource)
  test:assert_equals(1, love.audio.get_active_source_count(), 'check now active')
  love.audio.pause()
end


-- love.audio.get_distance_model
love.test.audio.get_distance_model = function(test)
  -- check we get a value
  test:assert_not_nil(love.audio.get_distance_model())
  -- check default value from documentation
  test:assert_equals('inverseclamped', love.audio.get_distance_model(), 'check default value')
  -- check get correct value after setting
  love.audio.set_distance_model('inverse')
  test:assert_equals('inverse', love.audio.get_distance_model(), 'check setting model')
end


-- love.audio.get_doppler_scale
love.test.audio.get_doppler_scale = function(test)
  -- check default value
  test:assert_equals(1, love.audio.get_doppler_scale(), 'check default 1')
  -- check correct value after setting to 0
  love.audio.set_doppler_scale(0)
  test:assert_equals(0, love.audio.get_doppler_scale(), 'check setting to 0')
  love.audio.set_doppler_scale(1)
end


-- love.audio.get_effect
love.test.audio.get_effect = function(test)
  -- check getting a non-existent effect
  test:assert_equals(nil, love.audio.get_effect('madeupname'), 'check wrong name')
  -- check getting a valid effect
  love.audio.set_effect('testeffect', {
    type = 'chorus',
    volume = 0.75
  })
  test:assert_not_nil(love.audio.get_effect('testeffect'))
  -- check effect values match creation values
  test:assert_equals('chorus', love.audio.get_effect('testeffect').type, 'check effect type')
  test:assert_equals(0.75, love.audio.get_effect('testeffect').volume, 'check effect volume')
end


-- love.audio.get_max_scene_effects
-- @NOTE feel like this is platform specific number so best we can do is a nil?
love.test.audio.get_max_scene_effects = function(test)
  test:assert_not_nil(love.audio.get_max_scene_effects())
end


-- love.audio.get_max_source_effects
-- @NOTE feel like this is platform specific number so best we can do is a nil?
love.test.audio.get_max_source_effects = function(test)
  test:assert_not_nil(love.audio.get_max_source_effects())
end


-- love.audio.get_orientation
-- @NOTE is there an expected default listener pos?
love.test.audio.get_orientation = function(test)
  -- checking getting values matches what was set
  love.audio.set_orientation(1, 2, 3, 4, 5, 6)
  local fx, fy, fz, ux, uy, uz = love.audio.get_orientation()
  test:assert_equals(1, fx, 'check fx orientation')
  test:assert_equals(2, fy, 'check fy orientation')
  test:assert_equals(3, fz, 'check fz orientation')
  test:assert_equals(4, ux, 'check ux orientation')
  test:assert_equals(5, uy, 'check uy orientation')
  test:assert_equals(6, uz, 'check uz orientation')
end


-- love.audio.get_playback_device
love.test.audio.get_playback_device = function(test)
  test:assert_not_nil(love.audio.get_playback_device)
  test:assert_not_nil(love.audio.get_playback_device())
end


-- love.audio.get_playback_devices
love.test.audio.get_playback_devices = function(test)
  test:assert_not_nil(love.audio.get_playback_devices)
  test:assert_greater_equal(0, #love.audio.get_playback_devices(), 'check table')
end


-- love.audio.get_position
-- @NOTE is there an expected default listener pos?
love.test.audio.get_position = function(test)
  -- check getting values matches what was set
  love.audio.set_position(1, 2, 3)
  local x, y, z = love.audio.get_position()
  test:assert_equals(1, x, 'check x position')
  test:assert_equals(2, y, 'check y position')
  test:assert_equals(3, z, 'check z position')
end


-- love.audio.get_recording_devices
-- @NOTE hardware dependent so best can do is not nil check
love.test.audio.get_recording_devices = function(test)
  test:assert_not_nil(love.audio.get_recording_devices())
end


-- love.audio.get_velocity
love.test.audio.get_velocity = function(test)
  -- check getting values matches what was set
  love.audio.set_velocity(1, 2, 3)
  local x, y, z = love.audio.get_velocity()
  test:assert_equals(1, x, 'check x velocity')
  test:assert_equals(2, y, 'check y velocity')
  test:assert_equals(3, z, 'check z velocity')
end


-- love.audio.get_volume
love.test.audio.get_volume = function(test)
  -- check getting values matches what was set
  love.audio.set_volume(0.5)
  test:assert_equals(0.5, love.audio.get_volume(), 'check matches set')
end


-- love.audio.is_effects_supported
love.test.audio.is_effects_supported = function(test)
  test:assert_not_nil(love.audio.is_effects_supported())
end


-- love.audio.new_queueable_source
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.audio.new_queueable_source = function(test)
  test:assert_object(love.audio.new_queueable_source(32, 8, 1, 8))
end


-- love.audio.new_source
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.audio.new_source = function(test)
  test:assert_object(love.audio.new_source('resources/click.ogg', 'static'))
  test:assert_object(love.audio.new_source('resources/click.ogg', 'stream'))
end


-- love.audio.pause
love.test.audio.pause = function(test)
  -- check nothing paused (as should be nothing playing)
  local nopauses = love.audio.pause()
  test:assert_equals(0, #nopauses, 'check nothing paused')
  -- check 1 source paused after playing/pausing 1
  local source = love.audio.new_source('resources/click.ogg', 'static')
  love.audio.play(source)
  local onepause = love.audio.pause()
  test:assert_equals(1, #onepause, 'check 1 paused')
  love.audio.stop(source)
end


-- love.audio.play
love.test.audio.play = function(test)
  -- check playing source is detected
  local source = love.audio.new_source('resources/click.ogg', 'static')
  love.audio.play(source)
  test:assert_true(source:is_playing(), 'check something playing')
  love.audio.stop()
end


-- love.audio.set_distance_model
love.test.audio.set_distance_model = function(test)
  -- check setting each of the distance models is accepted and val returned
  local distancemodel = {
    'none', 'inverse', 'inverseclamped', 'linear', 'linearclamped',
    'exponent', 'exponentclamped'
  }
  for d=1,#distancemodel do
    love.audio.set_distance_model(distancemodel[d])
    test:assert_equals(distancemodel[d], love.audio.get_distance_model(),
      'check model set to ' .. distancemodel[d])
  end
end


-- love.audio.set_doppler_scale
love.test.audio.set_doppler_scale = function(test)
  -- check setting value is returned properly
  love.audio.set_doppler_scale(0)
  test:assert_equals(0, love.audio.get_doppler_scale(), 'check set to 0')
  love.audio.set_doppler_scale(1)
  test:assert_equals(1, love.audio.get_doppler_scale(), 'check set to 1')
end


-- love.audio.set_effect
love.test.audio.set_effect = function(test)
  -- check effect is set correctly
  local effect = love.audio.set_effect('testeffect', {
    type = 'chorus',
    volume = 0.75
  })
  test:assert_true(effect, 'check effect created')
  -- check values set match
  local settings = love.audio.get_effect('testeffect')
  test:assert_equals('chorus', settings.type, 'check effect type')
  test:assert_equals(0.75, settings.volume, 'check effect volume')
end


-- love.audio.set_mix_with_system
love.test.audio.set_mix_with_system = function(test)
  test:assert_not_nil(love.audio.set_mix_with_system(true))
end


-- love.audio.set_orientation
love.test.audio.set_orientation = function(test)
  -- check setting orientation vals are returned
  love.audio.set_orientation(1, 2, 3, 4, 5, 6)
  local fx, fy, fz, ux, uy, uz = love.audio.get_orientation()
  test:assert_equals(1, fx, 'check fx orientation')
  test:assert_equals(2, fy, 'check fy orientation')
  test:assert_equals(3, fz, 'check fz orientation')
  test:assert_equals(4, ux, 'check ux orientation')
  test:assert_equals(5, uy, 'check uy orientation')
  test:assert_equals(6, uz, 'check uz orientation')
end


-- love.audio.set_playback_device
love.test.audio.set_playback_device = function(test)
  -- check method
  test:assert_not_nil(love.audio.set_playback_device)

  -- check blank string name
  test:assert_true(love.audio.set_playback_device(''), 'check blank device is fine')

  -- check invalid name
  test:assert_false(love.audio.set_playback_device('loveFM'), 'check invalid device fails')

  -- check setting already set
  test:assert_true(love.audio.set_playback_device(love.audio.get_playback_device()), 'check existing device is fine')
  
  -- if other devices to play with lets set a different one
  local devices = love.audio.get_playback_devices()
  if #devices > 1 then
    local another = ''
    local current = love.audio.get_playback_device()
    for a=1,#devices do
      if devices[a] ~= current then
        another = devices[a]
        break
      end
    end
    if another ~= '' then
      -- check setting new device
      local success4, msg4 = love.audio.set_playback_device(another)
      test:assert_true(success4, 'check setting different device')
      -- check resetting to default
      local success5, msg5 = love.audio.set_playback_device()
      test:assert_true(success5, 'check resetting')
      test:assert_equals(current, love.audio.get_playback_device())
    end
  end
end


-- love.audio.set_position
love.test.audio.set_position = function(test)
  -- check setting position vals are returned
  love.audio.set_position(1, 2, 3)
  local x, y, z = love.audio.get_position()
  test:assert_equals(1, x, 'check x position')
  test:assert_equals(2, y, 'check y position')
  test:assert_equals(3, z, 'check z position')
end


-- love.audio.set_velocity
love.test.audio.set_velocity = function(test)
  -- check setting velocity vals are returned
  love.audio.set_velocity(1, 2, 3)
  local x, y, z = love.audio.get_velocity()
  test:assert_equals(1, x, 'check x velocity')
  test:assert_equals(2, y, 'check y velocity')
  test:assert_equals(3, z, 'check z velocity')
end


-- love.audio.set_volume
love.test.audio.set_volume = function(test)
  -- check setting volume works
  love.audio.set_volume(0.5)
  test:assert_equals(0.5, love.audio.get_volume(), 'check set to 0.5')
end


-- love.audio.stop
love.test.audio.stop = function(test)
  -- check source is playing first
  local source = love.audio.new_source('resources/click.ogg', 'static')
  love.audio.play(source)
  test:assert_true(source:is_playing(), 'check is playing')
  -- check source is then stopped
  love.audio.stop()
  test:assert_false(source:is_playing(), 'check stopped playing')
end

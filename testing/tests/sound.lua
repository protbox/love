-- love.sound


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------OBJECTS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- Decoder (love.sound.new_decoder)
love.test.sound.Decoder = function(test)

  -- create obj
  local decoder = love.sound.new_decoder('resources/click.ogg')
  test:assert_object(decoder)

  -- check bit depth
  test:assert_match({8, 16}, decoder:get_bit_depth(), 'check bit depth')

  -- check channel count
  test:assert_match({1, 2}, decoder:get_channel_count(), 'check channel count')

  -- check duration
  test:assert_range(decoder:get_duration(), 0.06, 0.07, 'check duration')

  -- check sample rate
  test:assert_equals(44100, decoder:get_sample_rate(), 'check sample rate')

  -- check makes sound data (test in method below)
  test:assert_object(decoder:decode())

  -- check cloning sound
  local clone = decoder:clone()
  test:assert_match({8, 16}, clone:get_bit_depth(), 'check cloned bit depth')
  test:assert_match({1, 2}, clone:get_channel_count(), 'check cloned channel count')
  test:assert_range(clone:get_duration(), 0.06, 0.07, 'check cloned duration')
  test:assert_equals(44100, clone:get_sample_rate(), 'check cloned sample rate')

end


-- SoundData (love.sound.new_sound_data)
love.test.sound.SoundData = function(test)

  -- create obj
  local sdata = love.sound.new_sound_data('resources/click.ogg')
  test:assert_object(sdata)

  -- check data size + string
  test:assert_equals(11708, sdata:get_size(), 'check size')
  test:assert_not_nil(sdata:get_string())

  -- check bit depth
  test:assert_match({8, 16}, sdata:get_bit_depth(), 'check bit depth')

  -- check channel count
  test:assert_match({1, 2}, sdata:get_channel_count(), 'check channel count')

  -- check duration
  test:assert_range(sdata:get_duration(), 0.06, 0.07, 'check duration')

  -- check samples
  test:assert_equals(44100, sdata:get_sample_rate(), 'check sample rate')
  test:assert_equals(2927, sdata:get_sample_count(), 'check sample count')

  -- check cloning
  local clone = sdata:clone()
  test:assert_equals(11708, clone:get_size(), 'check clone size')
  test:assert_not_nil(clone:get_string())
  test:assert_match({8, 16}, clone:get_bit_depth(), 'check clone bit depth')
  test:assert_match({1, 2}, clone:get_channel_count(), 'check clone channel count')
  test:assert_range(clone:get_duration(), 0.06, 0.07, 'check clone duration')
  test:assert_equals(44100, clone:get_sample_rate(), 'check clone sample rate')
  test:assert_equals(2927, clone:get_sample_count(), 'check clone sample count')

  -- check sample setting
  test:assert_range(sdata:get_sample(0.001), -0.1, 0, 'check sample 1')
  test:assert_range(sdata:get_sample(0.005), -0.1, 0, 'check sample 1')
  sdata:set_sample(0.002, 1)
  test:assert_equals(1, sdata:get_sample(0.002), 'check setting sample manually')

  -- check copying from another sound
  local copy1 = love.sound.new_sound_data('resources/tone.ogg')
  local copy2 = love.sound.new_sound_data('resources/pop.ogg')
  local before = copy2:get_sample(0.02)
  copy2:copy_from(copy1, 0.01, 1, 0.02)
  test:assert_not_equals(before, copy2:get_sample(0.02), 'check changed')

  -- check slicing
  local count = math.floor(copy1:get_sample_count()/2)
  local slice = copy1:slice(0, count)
  test:assert_equals(count, slice:get_sample_count(), 'check slice length')

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



-- love.sound.new_decoder
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.sound.new_decoder = function(test)
  test:assert_object(love.sound.new_decoder('resources/click.ogg'))
end


-- love.sound.new_sound_data
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.sound.new_sound_data = function(test)
  test:assert_object(love.sound.new_sound_data('resources/click.ogg'))
  test:assert_object(love.sound.new_sound_data(math.floor((1/32)*44100), 44100, 16, 1))
end

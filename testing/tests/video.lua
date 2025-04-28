-- love.video


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
----------------------------------OBJECTS---------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- VideoStream (love.thread.new_video_stream)
love.test.video.VideoStream = function(test)

  -- create obj
  local video = love.video.new_video_stream('resources/sample.ogv')
  test:assert_object(video)

  -- check def properties
  test:assert_equals('resources/sample.ogv', video:get_filename(), 'check filename')
  test:assert_false(video:is_playing(), 'check not playing by def')

  -- check playing and pausing states
  video:play()
  test:assert_true(video:is_playing(), 'check now playing')
  video:seek(0.3)
  test:assert_range(video:tell(), 0.3, 0.4, 'check seek/tell')
  video:rewind()
  test:assert_range(video:tell(), 0, 0.1, 'check rewind')
  video:pause()
  test:assert_false(video:is_playing(), 'check paused')

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
----------------------------------METHODS---------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.video.new_video_stream
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.video.new_video_stream = function(test)
  test:assert_object(love.video.new_video_stream('resources/sample.ogv'))
end

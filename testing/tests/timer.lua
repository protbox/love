-- love.timer


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
----------------------------------METHODS---------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.timer.get_average_delta
-- @NOTE not sure if you could reliably get a specific delta?
love.test.timer.get_average_delta = function(test)
  test:assert_not_nil(love.timer.get_average_delta())
end

-- love.timer.get_delta
-- @NOTE not sure if you could reliably get a specific delta?
love.test.timer.get_delta = function(test)
  test:assert_not_nil(love.timer.get_delta())
end


-- love.timer.get_fps
-- @NOTE not sure if you could reliably get a specific FPS?
love.test.timer.get_fps = function(test)
  test:assert_not_nil(love.timer.get_fps())
end


-- love.timer.get_time
love.test.timer.get_time = function(test)
  local starttime = love.timer.get_time()
  love.timer.sleep(0.1)
  local endtime = love.timer.get_time() - starttime
  test:assert_range(endtime, 0.05, 1, 'check 0.1s passes')
end


-- love.timer.sleep
love.test.timer.sleep = function(test)
  local starttime = love.timer.get_time()
  love.timer.sleep(0.1)
  test:assert_range(love.timer.get_time() - starttime, 0.05, 1, 'check 0.1s passes')
end


-- love.timer.step
-- @NOTE not sure if you could reliably get a specific step val?
love.test.timer.step = function(test)
  test:assert_not_nil(love.timer.step())
end

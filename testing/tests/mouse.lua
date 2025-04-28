-- love.mouse
-- @NOTE we can't test this module fully as it's hardware dependent
-- however we can test methods do what is expected and can handle certain params

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.mouse.get_cursor
love.test.mouse.get_cursor = function(test)
  local cursor = love.mouse.get_cursor()
  test:assert_equals(nil, cursor, 'check nil initially')
  -- try setting a cursor to check return if supported
  if love.mouse.is_cursor_supported() then
    love.mouse.set_cursor(love.mouse.get_system_cursor("hand"))
    local newcursor = love.mouse.get_cursor()
    test:assert_object(newcursor)
    love.mouse.set_cursor()
  end
end


-- love.mouse.get_position
love.test.mouse.get_position = function(test)
  love.mouse.set_position(0, 0) -- cant predict
  local x, y = love.mouse.get_position()
  test:assert_equals(0, x, 'check x pos')
  test:assert_equals(0, y, 'check y pos')
end


-- love.mouse.get_relative_mode
love.test.mouse.get_relative_mode = function(test)
  local enabled = love.mouse.get_relative_mode()
  test:assert_equals(false, enabled, 'check relative mode')
  love.mouse.set_relative_mode(true)
  test:assert_equals(true, love.mouse.get_relative_mode(), 'check enabling')
end


-- love.mouse.get_system_cursor
love.test.mouse.get_system_cursor = function(test)
  local hand = love.mouse.get_system_cursor('hand')
  test:assert_object(hand)
  local ok, err = pcall(love.mouse.get_system_cursor, 'love')
  test:assert_equals(false, ok, 'check invalid cursor')
end


-- love.mouse.get_x
love.test.mouse.get_x = function(test)
  love.mouse.set_position(0, 0) -- cant predict
  local x = love.mouse.get_x()
  test:assert_equals(0, x, 'check x pos')
  love.mouse.set_x(10)
  test:assert_equals(10, love.mouse.get_x(), 'check set x')
end


-- love.mouse.get_y
love.test.mouse.get_y = function(test)
  love.mouse.set_position(0, 0) -- cant predict
  local y = love.mouse.get_y()
  test:assert_equals(0, y, 'check x pos')
  love.mouse.set_y(10)
  test:assert_equals(10, love.mouse.get_y(), 'check set y')
end


-- love.mouse.is_cursor_supported
love.test.mouse.is_cursor_supported = function(test)
  test:assert_not_nil(love.mouse.is_cursor_supported())
end


-- love.mouse.is_down
love.test.mouse.is_down = function(test)
  test:assert_not_nil(love.mouse.is_down())
end


-- love.mouse.is_grabbed
love.test.mouse.is_grabbed = function(test)
  test:assert_not_nil(love.mouse.is_grabbed())
end


-- love.mouse.is_visible
love.test.mouse.is_visible = function(test)
  local visible = love.mouse.is_visible()
  test:assert_equals(true, visible, 'check visible default')
  love.mouse.set_visible(false)
  test:assert_equals(false, love.mouse.is_visible(), 'check invisible')
  love.mouse.set_visible(true)
end


-- love.mouse.new_cursor
love.test.mouse.new_cursor = function(test)
  -- new cursor might fail if not supported
  if love.mouse.is_cursor_supported() then
    local cursor = love.mouse.new_cursor('resources/love.png', 0, 0)
    test:assert_object(cursor)
  else
    test:skip_test('cursor not supported on this system')
  end
end


-- love.mouse.set_cursor
love.test.mouse.set_cursor = function(test)
  -- cant set cursor if not supported
  if love.mouse.is_cursor_supported() then
    love.mouse.set_cursor()
    test:assert_equals(nil, love.mouse.get_cursor(), 'check reset')
    love.mouse.set_cursor(love.mouse.get_system_cursor('hand'))
    test:assert_object(love.mouse.get_cursor())
  else
    test:skip_test('cursor not supported on this system')
  end
end


-- love.mouse.set_grabbed
-- @NOTE can fail if you move the mouse a bunch while the test runs
love.test.mouse.set_grabbed = function(test)
  test:assert_equals(false, love.mouse.is_grabbed(), 'check not grabbed')
  love.mouse.set_grabbed(true)
  test:assert_equals(true, love.mouse.is_grabbed(), 'check now grabbed')
  love.mouse.set_grabbed(false)
end


-- love.mouse.set_position
love.test.mouse.set_position = function(test)
  love.mouse.set_position(10, 10)
  local x, y = love.mouse.get_position()
  test:assert_equals(10, x, 'check x position')
  test:assert_equals(10, y, 'check y position')
  love.mouse.set_position(15, 20)
  local x2, y2 = love.mouse.get_position()
  test:assert_equals(15, x2, 'check new x position')
  test:assert_equals(20, y2, 'check new y position')
end


-- love.mouse.set_relative_mode
love.test.mouse.set_relative_mode = function(test)
  love.mouse.set_relative_mode(true)
  local enabled = love.mouse.get_relative_mode()
  test:assert_equals(true, enabled, 'check relative mode')
  love.mouse.set_relative_mode(false)
  test:assert_equals(false, love.mouse.get_relative_mode(), 'check disabling')
end


-- love.mouse.set_visible
love.test.mouse.set_visible = function(test)
  local visible = love.mouse.is_visible()
  test:assert_equals(true, visible, 'check visible default')
  love.mouse.set_visible(false)
  test:assert_equals(false, love.mouse.is_visible(), 'check invisible')
  love.mouse.set_visible(true)
end


-- love.mouse.set_x
love.test.mouse.set_x = function(test)
  love.mouse.set_x(30)
  local x = love.mouse.get_x()
  test:assert_equals(30, x, 'check x pos')
  love.mouse.set_x(10)
  test:assert_equals(10, love.mouse.get_x(), 'check set x')
end


-- love.mouse.set_y
love.test.mouse.set_y = function(test)
  love.mouse.set_y(12)
  local y = love.mouse.get_y()
  test:assert_equals(12, y, 'check x pos')
  love.mouse.set_y(10)
  test:assert_equals(10, love.mouse.get_y(), 'check set y')
end

-- love.joystick
-- @NOTE we can't test this module fully as it's hardware dependent
-- however we can test methods do what is expected and can handle certain params

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.joystick.get_gamepad_mapping_string
love.test.joystick.get_gamepad_mapping_string = function(test)
  local mapping = love.joystick.get_gamepad_mapping_string('faker')
  test:assert_equals(nil, mapping, 'check no mapping for fake gui')
end


-- love.joystick.get_joystick_count
love.test.joystick.get_joystick_count = function(test)
  local count = love.joystick.get_joystick_count()
  test:assert_greater_equal(0, count, 'check number')
end


-- love.joystick.get_joysticks
love.test.joystick.get_joysticks = function(test)
  local joysticks = love.joystick.get_joysticks()
  test:assert_greater_equal(0, #joysticks, 'check is count')
end


-- love.joystick.load_gamepad_mappings
love.test.joystick.load_gamepad_mappings = function(test)
  local ok, err = pcall(love.joystick.load_gamepad_mappings, 'fakefile.txt')
  test:assert_equals(false, ok, 'check invalid file')
  love.joystick.load_gamepad_mappings('resources/mappings.txt')
end


-- love.joystick.save_gamepad_mappings
love.test.joystick.save_gamepad_mappings = function(test)
  love.joystick.load_gamepad_mappings('resources/mappings.txt')
  local mapping = love.joystick.save_gamepad_mappings()
  test:assert_greater_equal(0, #mapping, 'check something mapped')
end


-- love.joystick.set_gamepad_mapping
love.test.joystick.set_gamepad_mapping = function(test)
  local guid = '030000005e040000130b000011050000'
  local mappings = {
    love.joystick.set_gamepad_mapping(guid, 'a', 'button', 1, nil),
    love.joystick.set_gamepad_mapping(guid, 'b', 'button', 2, nil),
    love.joystick.set_gamepad_mapping(guid, 'x', 'button', 3, nil),
    love.joystick.set_gamepad_mapping(guid, 'y', 'button', 4, nil),
    love.joystick.set_gamepad_mapping(guid, 'back', 'button', 5, nil),
    love.joystick.set_gamepad_mapping(guid, 'start', 'button', 6, nil),
    love.joystick.set_gamepad_mapping(guid, 'guide', 'button', 7, nil),
    love.joystick.set_gamepad_mapping(guid, 'leftstick', 'button', 8, nil),
    love.joystick.set_gamepad_mapping(guid, 'leftshoulder', 'button', 9, nil),
    love.joystick.set_gamepad_mapping(guid, 'rightstick', 'button', 10, nil),
    love.joystick.set_gamepad_mapping(guid, 'rightshoulder', 'button', 11, nil),
    love.joystick.set_gamepad_mapping(guid, 'dpup', 'button', 12, nil),
    love.joystick.set_gamepad_mapping(guid, 'dpdown', 'button', 13, nil),
    love.joystick.set_gamepad_mapping(guid, 'dpleft', 'button', 14, nil),
    love.joystick.set_gamepad_mapping(guid, 'dpright', 'button', 15, nil),
    love.joystick.set_gamepad_mapping(guid, 'dpup', 'button', 12, 'u'),
    love.joystick.set_gamepad_mapping(guid, 'dpdown', 'button', 13, 'd'),
    love.joystick.set_gamepad_mapping(guid, 'dpleft', 'button', 14, 'l'),
    love.joystick.set_gamepad_mapping(guid, 'dpright', 'button', 15, 'r'),
    love.joystick.set_gamepad_mapping(guid, 'dpup', 'hat', 12, 'lu'),
    love.joystick.set_gamepad_mapping(guid, 'dpdown', 'hat', 13, 'ld'),
    love.joystick.set_gamepad_mapping(guid, 'dpleft', 'hat', 14, 'ru'),
    love.joystick.set_gamepad_mapping(guid, 'dpright', 'hat', 15, 'rd'),
    love.joystick.set_gamepad_mapping(guid, 'leftstick', 'axis', 8, 'c')
  }
  for m=1,#mappings do
    test:assert_equals(true, mappings[m], 'check mapping #' .. tostring(m))
  end
end

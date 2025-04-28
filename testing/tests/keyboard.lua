-- love.keyboard
-- @NOTE we can't test this module fully as it's hardware dependent
-- however we can test methods do what is expected and can handle certain params

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.keyboard.get_key_from_scancode
love.test.keyboard.get_key_from_scancode = function(test)
  test:assert_equals('function', type(love.keyboard.get_key_from_scancode))
end


-- love.keyboard.get_scancode_from_key
love.test.keyboard.get_scancode_from_key = function(test)
  test:assert_equals('function', type(love.keyboard.get_scancode_from_key))
end


-- love.keyboard.has_key_repeat
love.test.keyboard.has_key_repeat = function(test)
  local enabled = love.keyboard.has_key_repeat()
  test:assert_not_nil(enabled)
end


-- love.keyboard.has_screen_keyboard
love.test.keyboard.has_screen_keyboard = function(test)
  local enabled = love.keyboard.has_screen_keyboard()
  test:assert_not_nil(enabled)
end


-- love.keyboard.has_text_input
love.test.keyboard.has_text_input = function(test)
  local enabled = love.keyboard.has_text_input()
  test:assert_not_nil(enabled)
end


-- love.keyboard.is_down
love.test.keyboard.is_down = function(test)
  local keydown = love.keyboard.is_down('a')
  test:assert_not_nil(keydown)
end


-- love.keyboard.is_scancode_down
love.test.keyboard.is_scancode_down = function(test)
  local keydown = love.keyboard.is_scancode_down('a')
  test:assert_not_nil(keydown)
end


-- love.keyboard.set_key_repeat
love.test.keyboard.set_key_repeat = function(test)
  love.keyboard.set_key_repeat(true)
  local enabled = love.keyboard.has_key_repeat()
  test:assert_equals(true, enabled, 'check key repeat set')
end


-- love.keyboard.is_modifier_active
love.test.keyboard.is_modifier_active = function(test)
  local active1 = love.keyboard.is_modifier_active('numlock')
  local active2 = love.keyboard.is_modifier_active('capslock')
  local active3 = love.keyboard.is_modifier_active('scrolllock')
  local active4 = love.keyboard.is_modifier_active('mode')
  test:assert_not_nil(active1)
  test:assert_not_nil(active2)
  test:assert_not_nil(active3)
  test:assert_not_nil(active4)
end


-- love.keyboard.set_text_input
love.test.keyboard.set_text_input = function(test)
  love.keyboard.set_text_input(false)
  test:assert_equals(false, love.keyboard.has_text_input(), 'check disable text input')
end

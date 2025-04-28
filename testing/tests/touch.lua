-- love.touch
-- @NOTE we can't test this module fully as it's hardware dependent
-- however we can test methods do what is expected and can handle certain params

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.touch.get_position
-- @TODO is there a way to fake the touchid pointer?
love.test.touch.get_position = function(test)
  test:assert_not_nil(love.touch.get_position)
  test:assert_equals('function', type(love.touch.get_position))
end


-- love.touch.get_pressure
-- @TODO is there a way to fake the touchid pointer?
love.test.touch.get_pressure = function(test)
  test:assert_not_nil(love.touch.get_pressure)
  test:assert_equals('function', type(love.touch.get_pressure))
end


-- love.touch.get_touches
love.test.touch.get_touches = function(test)
  test:assert_equals('function', type(love.touch.get_touches))
end

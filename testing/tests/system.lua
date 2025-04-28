-- love.system


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
----------------------------------METHODS---------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.system.get_clipboard_text
love.test.system.get_clipboard_text = function(test)
  -- ignore if not using window
  if love.test.windowmode == false then 
    return test:skip_test('clipboard only available in window mode') 
  end
  -- check clipboard value is set
  love.system.set_clipboard_text('helloworld')
  test:assert_equals('helloworld', love.system.get_clipboard_text(), 'check clipboard match')
end


-- love.system.get_os
love.test.system.get_os = function(test)
  -- check os is in documented values
  local os = love.system.get_os()
  local options = {'OS X', 'Windows', 'Linux', 'Android', 'iOS'}
  test:assert_match(options, os, 'check value matches')
end


-- love.system.get_preferred_locales
love.test.system.get_preferred_locales = function(test)
  local locale = love.system.get_preferred_locales()
  test:assert_not_nil(locale)
  test:assert_equals('table', type(locale), 'check returns table')
end


-- love.system.get_power_info
love.test.system.get_power_info = function(test)
  -- check battery state is one of the documented states
  local state, percent, seconds = love.system.get_power_info()
  local states = {'unknown', 'battery', 'nobattery', 'charging', 'charged'}
  test:assert_match(states, state, 'check value matches')
  -- if percent/seconds check within expected range
  if percent ~= nil then
    test:assert_range(percent, 0, 100, 'check battery percent within range')
  end
  if seconds ~= nil then
    test:assert_not_nil(seconds)
  end
end


-- love.system.get_processor_count
love.test.system.get_processor_count = function(test)
  test:assert_not_nil(love.system.get_processor_count()) -- youd hope right
end


-- love.system.has_background_music
love.test.system.has_background_music = function(test)
  test:assert_not_nil(love.system.has_background_music())
end


-- love.system.open_url
love.test.system.open_url = function(test)
  test:skip_test('cant test this worked')
  --test:assert_not_equals(nil, love.system.open_url('https://love2d.org'), 'check open URL')
end


-- love.system.get_clipboard_text
love.test.system.set_clipboard_text = function(test)
  -- ignore if not using window
  if love.test.windowmode == false then 
    return test:skip_test('clipboard only available in window mode') 
  end
  -- check value returned is what was set
  love.system.set_clipboard_text('helloworld')
  test:assert_equals('helloworld', love.system.get_clipboard_text(), 'check set text')
end


-- love.system.vibrate
-- @NOTE cant really test this
love.test.system.vibrate = function(test)
  test:skip_test('cant test this worked')
end

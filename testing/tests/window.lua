-- love.window


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
----------------------------------METHODS---------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.window.focus
love.test.window.focus = function(test)
  -- cant test as doesnt return anything
  test:assert_equals('function', type(love.window.focus), 'check method exists')
end


-- love.window.from_pixels
love.test.window.from_pixels = function(test)
  -- check dpi/pixel ratio as expected
  local dpi = love.window.get_dpi_scale()
  local pixels = love.window.from_pixels(100)
  test:assert_equals(100/dpi, pixels, 'check dpi ratio')
end


-- love.window.get_dpi_scale
-- @NOTE dependent on hardware so best can do is not nil
love.test.window.get_dpi_scale = function(test)
  test:assert_not_nil(test)
end


-- love.window.get_desktop_dimensions
-- @NOTE dependent on hardware so best can do is not nil
love.test.window.get_desktop_dimensions = function(test)
  local w, h = love.window.get_desktop_dimensions()
  test:assert_not_nil(w)
  test:assert_not_nil(h)
end


-- love.window.get_display_count
-- @NOTE cant wait for the test suite to be run headless and fail here
love.test.window.get_display_count = function(test)
  test:assert_greater_equal(1, love.window.get_display_count(), 'check 1 display')
end


-- love.window.get_display_name
-- @NOTE dependent on hardware so best can do is not nil
love.test.window.get_display_name = function(test)
  test:assert_not_nil(love.window.get_display_name(1))
end


-- love.window.get_display_orientation
-- @NOTE dependent on hardware so best can do is not nil
love.test.window.get_display_orientation = function(test)
  test:assert_not_nil(love.window.get_display_orientation(1))
end


-- love.window.get_fullscreen
love.test.window.get_fullscreen = function(test)
  if GITHUB_RUNNER and test:is_os('Linux') then
    return test:skip_test("xvfb on Linux doesn't support fullscreen")
  end

  -- check not fullscreen to start
  test:assert_false(love.window.get_fullscreen(), 'check not fullscreen')
  love.window.set_fullscreen(true)
  -- check now fullscreen
  test:assert_true(love.window.get_fullscreen(), 'check now fullscreen')
  love.window.set_fullscreen(false) -- reset
end


-- love.window.get_fullscreen_modes
-- @NOTE dependent on hardware so best can do is not nil
love.test.window.get_fullscreen_modes = function(test)
  test:assert_not_nil(love.window.get_fullscreen_modes(1))
end


-- love.window.get_icon
love.test.window.get_icon = function(test)
  -- check icon nil by default if not set
  test:assert_equals(nil, love.window.get_icon(), 'check nil by default')
  local icon = love.image.new_image_data('resources/love.png')
  -- check getting icon not nil after setting
  love.window.set_icon(icon)
  test:assert_not_nil(love.window.get_icon())
end


-- love.window.get_mode
-- @NOTE could prob add more checks on the flags here based on conf.lua
love.test.window.get_mode = function(test)
  local w, h, flags = love.window.get_mode()
  test:assert_equals(360, w, 'check w')
  test:assert_equals(240, h, 'check h')
  test:assert_false(flags["fullscreen"], 'check fullscreen')
end


-- love.window.get_position
-- @NOTE anything we could check display index agaisn't in getPosition return?
love.test.window.get_position = function(test)
  love.window.set_position(100, 100, 1)
  local x, y, _ = love.window.get_position()
  test:assert_equals(100, x, 'check position x')
  test:assert_equals(100, y, 'check position y')
end


-- love.window.get_safe_area
-- @NOTE dependent on hardware so best can do is not nil
love.test.window.get_safe_area = function(test)
  local x, y, w, h = love.window.get_safe_area()
  test:assert_not_nil(x)
  test:assert_not_nil(y)
  test:assert_not_nil(w)
  test:assert_not_nil(h)
end


-- love.window.get_title
love.test.window.get_title = function(test)
  -- check title returned is what was set
  love.window.set_title('love.testing')
  test:assert_equals('love.testing', love.window.get_title(), 'check title match')
  love.window.set_title('love.test')
end


-- love.window.get_v_sync
love.test.window.get_v_sync = function(test)
  test:assert_not_nil(love.window.get_v_sync())
end


-- love.window.has_focus
-- @NOTE cant really test as cant force focus
love.test.window.has_focus = function(test)
  test:assert_not_nil(love.window.has_focus())
end


-- love.window.has_mouse_focus
-- @NOTE cant really test as cant force focus
love.test.window.has_mouse_focus = function(test)
  test:assert_not_nil(love.window.has_mouse_focus())
end


-- love.window.is_display_sleep_enabled
love.test.window.is_display_sleep_enabled = function(test)
  test:assert_not_nil(love.window.is_display_sleep_enabled())
  -- check disabled
  love.window.set_display_sleep_enabled(false)
  test:assert_false(love.window.is_display_sleep_enabled(), 'check sleep disabled')
  -- check enabled
  love.window.set_display_sleep_enabled(true)
  test:assert_true(love.window.is_display_sleep_enabled(), 'check sleep enabled')
end


-- love.window.is_maximized
love.test.window.is_maximized = function(test)
  if GITHUB_RUNNER and test:is_os('Linux') then
    return test:skip_test("xvfb on Linux doesn't support window maximization")
  end

  test:assert_false(love.window.is_maximized(), 'check window not maximized')
  love.window.maximize()
  test:wait_frames(10)
  -- on MACOS maximize wont get recognised immedietely so wait a few frames
  test:assert_true(love.window.is_maximized(), 'check window now maximized')
  love.window.restore()
end


-- love.window.is_minimized
love.test.window.is_minimized = function(test)
  if GITHUB_RUNNER and test:is_os('Linux') then
    return test:skip_test("xvfb on Linux doesn't support window minimization")
  end

  -- check not minimized to start
  test:assert_false(love.window.is_minimized(), 'check window not minimized')
  -- try to minimize
  love.window.minimize()
  test:wait_frames(10)
  -- on linux minimize won't get recognized immediately, so wait a few frames
  test:assert_true(love.window.is_minimized(), 'check window minimized')
  love.window.restore()
end


-- love.window.is_occluded
love.test.window.is_occluded = function(test)
  love.window.focus()
  test:assert_false(love.window.is_occluded(), 'check window not occluded')
end


-- love.window.is_open
love.test.window.is_open = function(test)
  -- check open initially
  test:assert_true(love.window.is_open(), 'check window open')
  -- we check closing in test.window.close
end


-- love.window.is_visible
love.test.window.is_visible = function(test)
  -- check visible initially
  test:assert_true(love.window.is_visible(), 'check window visible')
end


-- love.window.maximize
love.test.window.maximize = function(test)
  if GITHUB_RUNNER and test:is_os('Linux') then
    return test:skip_test("xvfb on Linux doesn't support window maximization")
  end

  test:assert_false(love.window.is_maximized(), 'check window not maximized')
  -- check maximizing is set
  love.window.maximize()
  test:wait_frames(10)
  -- on macos we need to wait a few frames
  test:assert_true(love.window.is_maximized(), 'check window maximized')
  love.window.restore()
end


-- love.window.minimize
love.test.window.minimize = function(test)
  if GITHUB_RUNNER and test:is_os('Linux') then
    return test:skip_test("xvfb on Linux doesn't support window minimization")
  end

  test:assert_false(love.window.is_minimized(), 'check window not minimized')
  -- check minimizing is set
  love.window.minimize()
  test:wait_frames(10)
  -- on linux we need to wait a few frames
  test:assert_true(love.window.is_minimized(), 'check window maximized')
  love.window.restore()
end


-- love.window.request_attention
love.test.window.request_attention = function(test)
  test:skip_test('cant test this worked')
end


-- love.window.restore
love.test.window.restore = function(test)
  if GITHUB_RUNNER and test:is_os('Linux') then
    return test:skip_test("xvfb on Linux doesn't support window minimization")
  end

  -- check minimized to start
  love.window.minimize()
  test:wait_frames(10)
  love.window.restore()
  test:wait_frames(10)
  -- check restoring the state of the window
  test:assert_false(love.window.is_minimized(), 'check window restored')
end


-- love.window.set_display_sleep_enabled
love.test.window.set_display_sleep_enabled = function(test)
  -- check disabling sleep
  love.window.set_display_sleep_enabled(false)
  test:assert_false(love.window.is_display_sleep_enabled(), 'check sleep disabled')
  -- check setting it back to enabled
  love.window.set_display_sleep_enabled(true)
  test:assert_true(love.window.is_display_sleep_enabled(), 'check sleep enabled')
end


-- love.window.set_fullscreen
love.test.window.set_fullscreen = function(test)
  if GITHUB_RUNNER and test:is_os('Linux') then
    return test:skip_test("xvfb on Linux doesn't support fullscreen")
  end

  -- check fullscreen is set
  love.window.set_fullscreen(true)
  test:assert_true(love.window.get_fullscreen(), 'check fullscreen')
  -- check setting back to normal
  love.window.set_fullscreen(false)
  test:assert_false(love.window.get_fullscreen(), 'check not fullscreen')
end


-- love.window.set_icon
-- @NOTE could check the image data itself?
love.test.window.set_icon = function(test)
  -- check setting an icon returns the val
  local icon = love.image.new_image_data('resources/love.png')
  love.window.set_icon(icon)
  test:assert_not_equals(nil, love.window.get_icon(), 'check icon not nil')
end


-- love.window.set_mode
-- @NOTE same as getMode could be checking more flag properties
love.test.window.set_mode = function(test)
  -- set window mode
  love.window.set_mode(512, 512, {
    fullscreen = false,
    resizable = false
  })
  -- check what we set is returned
  local width, height, flags = love.window.get_mode()
  test:assert_equals(512, width, 'check window w match')
  test:assert_equals(512, height, 'check window h match')
  test:assert_false(flags["fullscreen"], 'check window not fullscreen')
  test:assert_false(flags["resizable"], 'check window not resizeable')
  love.window.set_mode(360, 240, {
    fullscreen = false,
    resizable = true
  })
end

-- love.window.set_position
love.test.window.set_position = function(test)
  -- check position is returned
  love.window.set_position(100, 100, 1)
  test:wait_frames(10)
  local x, y, _ = love.window.get_position()
  test:assert_equals(100, x, 'check position x')
  test:assert_equals(100, y, 'check position y')
end


-- love.window.set_title
love.test.window.set_title = function(test)
  -- check setting title val is returned
  love.window.set_title('love.testing')
  test:assert_equals('love.testing', love.window.get_title(), 'check title matches')
  love.window.set_title('love.test')
end


-- love.window.set_v_sync
love.test.window.set_v_sync = function(test)
  love.window.set_v_sync(0)
  test:assert_not_nil(love.window.get_v_sync())
end


-- love.window.show_message_box
-- @NOTE if running headless would need to skip anyway cos can't press it
love.test.window.show_message_box = function(test)
  test:skip_test('cant test this worked')
end


-- love.window.to_pixels
love.test.window.to_pixels = function(test)
  -- check dpi/pixel ratio is as expected
  local dpi = love.window.get_dpi_scale()
  local pixels = love.window.to_pixels(50)
  test:assert_equals(50*dpi, pixels, 'check dpi ratio')
end


-- love.window.update_mode
love.test.window.update_mode = function(test)
  -- set initial mode
  love.window.set_mode(512, 512, {
    fullscreen = false,
    resizable = false
  })
  -- update mode with some props but not others
  love.window.update_mode(360, 240, nil)
  -- check only changed values changed
  local width, height, flags = love.window.get_mode()
  test:assert_equals(360, width, 'check window w match')
  test:assert_equals(240, height, 'check window h match')
  test:assert_false(flags["fullscreen"], 'check window not fullscreen')
  test:assert_false(flags["resizable"], 'check window not resizeable')
  love.window.set_mode(360, 240, { -- reset
    fullscreen = false,
    resizable = true
  })

  -- test different combinations of the backbuffer depth/stencil buffer.
  test:wait_frames(1)
  love.window.update_mode(360, 240, {depth = false, stencil = false})
  test:wait_frames(1)
  love.window.update_mode(360, 240, {depth = true, stencil = true})
  test:wait_frames(1)
  love.window.update_mode(360, 240, {depth = true, stencil = false})
  test:wait_frames(1)
  love.window.update_mode(360, 240, {depth = false, stencil = true})
end

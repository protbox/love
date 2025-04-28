-- love
-- tests for the main love hooks + methods, mainly just that they exist

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.getVersion
love.test.love.get_version = function(test)
  local major, minor, revision, codename = love.getVersion()
  test:assert_greater_equal(0, major, 'check major is number')
  test:assert_greater_equal(0, minor, 'check minor is number')
  test:assert_greater_equal(0, revision, 'check revision is number')
  test:assert_true(codename ~= nil, 'check has codename')
end


-- love.hasDeprecationOutput
love.test.love.has_deprecation_output = function(test)
  local enabled = love.hasDeprecationOutput()
  test:assert_equals(true, enabled, 'check enabled by default')
end


-- love.isVersionCompatible
love.test.love.is_version_compatible = function(test)
  local major, minor, revision, _ = love.getVersion()
  test:assert_true(love.isVersionCompatible(major, minor, revision), 'check own version')
end


-- love.setDeprecationOutput
love.test.love.set_deprecation_output = function(test)
  local enabled = love.hasDeprecationOutput()
  test:assert_equals(true, enabled, 'check enabled by default')
  love.setDeprecationOutput(false)
  test:assert_equals(false, love.hasDeprecationOutput(), 'check disable')
  love.setDeprecationOutput(true)
end


-- love.errhand
love.test.love.errhand = function(test)
  test:assert_true(type(love.errhand) == 'function', 'check defined')
end


-- love.run
love.test.love.run = function(test)
  test:assert_true(type(love.run) == 'function', 'check defined')
end

-- love.sensor
-- @NOTE we can't test this module fully as it's hardware dependent
-- however we can test methods do what is expected and can handle certain params

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------HELPERS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function testIsEnabled(test, sensorType)
  love.sensor.set_enabled(sensorType, true)
  test:assert_true(love.sensor.is_enabled(sensorType), 'check ' .. sensorType .. ' enabled')
  love.sensor.set_enabled(sensorType, false)
  test:assert_false(love.sensor.is_enabled(sensorType), 'check ' .. sensorType .. ' disabled')
end


local function testGetName(test, sensorType)
  love.sensor.set_enabled(sensorType, true)
  local ok, name = pcall(love.sensor.get_name, sensorType)
  test:assert_true(ok, 'check sensor.getName("' .. sensorType .. '") success')
  test:assert_equals(type(name), 'string', 'check sensor.getName("' .. sensorType .. '") return value type')

  love.sensor.set_enabled(sensorType, false)
  ok, name = pcall(love.sensor.get_name, sensorType)
  test:assert_false(ok, 'check sensor.getName("' .. sensorType .. '") errors when disabled')
end


local function testGetData(test, sensorType)
  love.sensor.set_enabled(sensorType, true)
  local ok, x, y, z = pcall(love.sensor.get_data, sensorType)
  test:assert_true(ok, 'check sensor.getData("' .. sensorType .. '") success')
  if ok then
    test:assert_not_nil(x)
    test:assert_not_nil(y)
    test:assert_not_nil(z)
  end

  love.sensor.set_enabled(sensorType, false)
  ok, x, y, z = pcall(love.sensor.get_data, sensorType)
  test:assert_false(ok, 'check sensor.getData("' .. sensorType .. '") errors when disabled')
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.sensor.has_sensor
love.test.sensor.has_sensor = function(test)
  -- but we can make sure that the SensorTypes can be passed
  local accelerometer = love.sensor.has_sensor('accelerometer')
  local gyroscope = love.sensor.has_sensor('gyroscope')
  test:assert_not_nil(accelerometer)
  test:assert_not_nil(gyroscope)
end


-- love.sensor.is_enabled and love.sensor.set_enabled
love.test.sensor.is_enabled = function(test)
  local accelerometer = love.sensor.has_sensor('accelerometer')
  local gyroscope = love.sensor.has_sensor('gyroscope')

  if accelerometer or gyroscope then
    if accelerometer then testIsEnabled(test, 'accelerometer') end
    if gyroscope then testIsEnabled(test, 'gyroscope') end
  else
    test:skip_test('neither accelerometer nor gyroscope are supported in this system')
  end
end


-- love.sensor.get_name
love.test.sensor.get_name = function(test)
  local accelerometer = love.sensor.has_sensor('accelerometer')
  local gyroscope = love.sensor.has_sensor('gyroscope')

  if accelerometer or gyroscope then
    if accelerometer then testGetName(test, 'accelerometer') end
    if gyroscope then testGetName(test, 'gyroscope') end
  else
    test:skip_test('neither accelerometer nor gyroscope are supported in this system')
  end
end


-- love.sensor.get_data
love.test.sensor.get_data = function(test)
  local accelerometer = love.sensor.has_sensor('accelerometer')
  local gyroscope = love.sensor.has_sensor('gyroscope')

  if accelerometer or gyroscope then
    if accelerometer then testGetData(test, 'accelerometer') end
    if gyroscope then testGetData(test, 'gyroscope') end
  else
    test:skip_test('neither accelerometer nor gyroscope are supported in this system')
  end
end

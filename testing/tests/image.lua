-- love.image


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------OBJECTS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- CompressedImageData (love.image.new_compressed_image_data)
love.test.image.CompressedImageData = function(test)

  -- create obj
  local idata = love.image.new_compressed_data('resources/love.dxt1')
  test:assert_object(idata)

  -- check string + size
  test:assert_not_equals(nil, idata:get_string(), 'check data string')
  test:assert_equals(2744, idata:get_size(), 'check data size')

  -- check img dimensions
  local iw, ih = idata:get_dimensions()
  test:assert_equals(64, iw, 'check image dimension w')
  test:assert_equals(64, ih, 'check image dimension h')
  test:assert_equals(64, idata:get_width(), 'check image direct w')
  test:assert_equals(64, idata:get_height(), 'check image direct h')

  -- check format
  test:assert_equals('DXT1', idata:get_format(), 'check image format')

  -- check mipmap count
  test:assert_equals(7, idata:get_mipmap_count(), 'check mipmap count')

  -- check linear
  test:assert_false(idata:is_linear(), 'check not linear')
  idata:set_linear(true)
  test:assert_true(idata:is_linear(), 'check now linear')

end


-- ImageData (love.image.new_image_data)
love.test.image.ImageData = function(test)

  -- create obj
  local idata = love.image.new_image_data('resources/love.png')
  test:assert_object(idata)

  -- check string + size
  test:assert_not_equals(nil, idata:get_string(), 'check data string')
  test:assert_equals(16384, idata:get_size(), 'check data size')

  -- check img dimensions
  local iw, ih = idata:get_dimensions()
  test:assert_equals(64, iw, 'check image dimension w')
  test:assert_equals(64, ih, 'check image dimension h')
  test:assert_equals(64, idata:get_width(), 'check image direct w')
  test:assert_equals(64, idata:get_height(), 'check image direct h')

  -- check format
  test:assert_equals('rgba8', idata:get_format(), 'check image format')
  
  -- manipulate image data so white heart is black
  local mapdata = function(x, y, r, g, b, a)
    if r == 1 and g == 1 and b == 1 then
      r = 0; g = 0; b = 0
    end
    return r, g, b, a
  end
  idata:map_pixel(mapdata, 0, 0, 64, 64)
  local r1, g1, b1 = idata:get_pixel(25, 25)
  test:assert_equals(0, r1+g1+b1, 'check mapped black')

  -- map some other data into the idata
  local idata2 = love.image.new_image_data('resources/loveinv.png')
  idata:paste(idata2, 0, 0, 0, 0)
  r1, g1, b1 = idata:get_pixel(25, 25)
  test:assert_equals(3, r1+g1+b1, 'check back to white')

  -- set pixels directly
  idata:set_pixel(25, 25, 1, 0, 0, 1)
  local r2, g2, b2 = idata:get_pixel(25, 25)
  test:assert_equals(1, r2+g2+b2, 'check set to red')

  -- check encoding to an image (png)
  idata:encode('png', 'test-encode.png')
  local read1 = love.filesystem.open_file('test-encode.png', 'r')
  test:assert_not_nil(read1)
  love.filesystem.remove('test-encode.png')

  -- check encoding to an image (exr)
  local edata = love.image.new_image_data(100, 100, 'r16f')
  edata:encode('exr', 'test-encode.exr')
  local read2 = love.filesystem.open_file('test-encode.exr', 'r')
  test:assert_not_nil(read2)
  love.filesystem.remove('test-encode.exr')

  -- check linear
  test:assert_false(idata:is_linear(), 'check not linear')
  idata:set_linear(true)
  test:assert_true(idata:is_linear(), 'check now linear')

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.image.is_compressed
-- @NOTE really we need to test each of the files listed here:
-- https://love2d.org/wiki/CompressedImageFormat
-- also need to be platform dependent (e.g. dxt not suppored on phones)
love.test.image.is_compressed = function(test)
  test:assert_true(love.image.is_compressed('resources/love.dxt1'), 
    'check dxt1 valid compressed image')
end


-- love.image.new_compressed_data
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.image.new_compressed_data = function(test)
  test:assert_object(love.image.new_compressed_data('resources/love.dxt1'))
end


-- love.image.new_image_data
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.image.new_image_data = function(test)
  test:assert_object(love.image.new_image_data('resources/love.png'))
  test:assert_object(love.image.new_image_data(16, 16, 'rgba8', nil))
end

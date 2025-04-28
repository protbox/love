-- love.font


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------OBJECTS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- GlyphData (love.font.new_glyph_data)
love.test.font.GlyphData = function(test)

  -- create obj
  local rasterizer = love.font.new_rasterizer('resources/font.ttf')
  local gdata = love.font.new_glyph_data(rasterizer, 97) -- 'a'
  test:assert_object(gdata)

  -- check properties match expected
  test:assert_not_nil(gdata:get_string())
  test:assert_equals(128, gdata:get_size(), 'check data size')
  test:assert_equals(9, gdata:get_advance(), 'check advance')
  test:assert_equals('la8', gdata:get_format(), 'check format')

  -- @TODO 
  --[[
    currently these will return 0 and '' respectively as not implemented
    https://github.com/love2d/love/blob/12.0-development/src/modules/font/freetype/TrueTypeRasterizer.cpp#L140-L141
    "basically I haven't decided what to do here yet, because of the more 
    advanced text shaping that happens in love 12 having a unicode codepoint 
    associated with a glyph probably doesn't make sense in the first place"
  ]]--
  --test:assert_equals(97, gdata:get_glyph(), 'check glyph number') - returns 0
  --test:assert_equals('a', gdata:get_glyph_string(), 'check glyph string') - returns ''

  -- check height + width
  test:assert_equals(8, gdata:get_height(), 'check height')
  test:assert_equals(8, gdata:get_width(), 'check width')

  -- check boundary / dimensions
  local x, y, w, h = gdata:get_bounding_box()
  local dw, dh = gdata:get_dimensions()
  test:assert_equals(0, x, 'check bbox x')
  test:assert_equals(-3, y, 'check bbox y')
  test:assert_equals(8, w, 'check bbox w')
  test:assert_equals(14, h, 'check bbox h')
  test:assert_equals(8, dw, 'check dim width')
  test:assert_equals(8, dh, 'check dim height')

  -- check bearing
  local bw, bh = gdata:get_bearing()
  test:assert_equals(0, bw, 'check bearing w')
  test:assert_equals(11, bh, 'check bearing h')

end


-- Rasterizer (love.font.new_rasterizer)
love.test.font.Rasterizer = function(test)

  -- create obj
  local rasterizer = love.font.new_rasterizer('resources/font.ttf')
  test:assert_object(rasterizer)

  -- check advance
  test:assert_equals(9, rasterizer:get_advance(), 'check advance')

  -- check ascent/descent
  test:assert_equals(9, rasterizer:get_ascent(), 'check ascent')
  test:assert_equals(-3, rasterizer:get_descent(), 'check descent')

  -- check glyphcount
  test:assert_equals(77, rasterizer:get_glyph_count(), 'check glyph count')

  -- check specific glyphs
  test:assert_object(rasterizer:get_glyph_data('L'))
  test:assert_true(rasterizer:has_glyphs('L', 'O', 'V', 'E'), 'check LOVE')

  -- check height + lineheight
  test:assert_equals(12, rasterizer:get_height(), 'check height')
  test:assert_equals(15, rasterizer:get_line_height(), 'check line height')

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.font.new_bm_font_rasterizer
love.test.font.new_bm_font_rasterizer = function(test)
  local rasterizer = love.font.new_bm_font_rasterizer('resources/love.png');
  test:assert_object(rasterizer)
end


-- love.font.new_glyph_data
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.font.new_glyph_data = function(test)
  local img = love.image.new_image_data('resources/love.png')
  local rasterizer = love.font.new_image_rasterizer(img, 'ABC', 0, 1);
  local glyphdata = love.font.new_glyph_data(rasterizer, 65)
  test:assert_object(glyphdata)
end


-- love.font.new_image_rasterizer
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.font.new_image_rasterizer = function(test)
  local img = love.image.new_image_data('resources/love.png')
  local rasterizer = love.font.new_image_rasterizer(img, 'ABC', 0, 1);
  test:assert_object(rasterizer)
end


-- love.font.new_rasterizer
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.font.new_rasterizer = function(test)
  test:assert_object(love.font.new_rasterizer('resources/font.ttf'))
end


-- love.font.new_true_type_rasterizer
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.font.new_true_type_rasterizer = function(test)
  test:assert_object(love.font.new_true_type_rasterizer(12, "normal", 1))
  test:assert_object(love.font.new_true_type_rasterizer('resources/font.ttf', 8, "normal", 1))
end

-- love.graphics


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------OBJECTS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- GraphicsBuffer (love.graphics.new_buffer)
love.test.graphics.Buffer = function(test)

  -- setup vertex data and create some buffers
  local vertexformat = {
    {name="VertexPosition", format="floatvec2", location=0},
    {name="VertexTexCoord", format="floatvec2", location=1},
    {name="VertexColor", format="unorm8vec4", location=2},
  }
  local vertexdata = {
    {0,  0,  0, 0, 1, 0, 1, 1},
    {10, 0,  1, 0, 0, 1, 1, 1},
    {10, 10, 1, 1, 0, 0, 1, 1},
    {0,  10, 0, 1, 1, 0, 0, 1},
  }
  local flatvertexdata = {}
  for i, vert in ipairs(vertexdata) do
    for j, v in ipairs(vert) do
      table.insert(flatvertexdata, v)
    end
  end
  local vertexbuffer1 = love.graphics.new_buffer(vertexformat, 4, {vertex=true, debugname='testvertexbuffer'})
  local vertexbuffer2 = love.graphics.new_buffer(vertexformat, vertexdata, {vertex=true})
  test:assert_object(vertexbuffer1)
  test:assert_object(vertexbuffer2)

  -- check buffer properties
  test:assert_equals(4, vertexbuffer1:get_element_count(), 'check vertex count 1')
  test:assert_equals(4, vertexbuffer2:get_element_count(), 'check vertex count 2')
  -- vertex buffers have their elements tightly packed.
  test:assert_equals(20, vertexbuffer1:get_element_stride(), 'check vertex array stride')
  test:assert_equals(20 * 4, vertexbuffer1:get_size(), 'check vertex buffer size')
  vertexbuffer1:set_array_data(vertexdata)
  vertexbuffer1:set_array_data(flatvertexdata)
  vertexbuffer1:clear(8, 8) -- partial clear (the first texcoord)

  -- check buffer types
  test:assert_true(vertexbuffer1:is_buffer_type('vertex'), 'check is vertex buffer')
  test:assert_false(vertexbuffer1:is_buffer_type('index'), 'check is not index buffer')
  test:assert_false(vertexbuffer1:is_buffer_type('texel'), 'check is not texel buffer')
  test:assert_false(vertexbuffer1:is_buffer_type('shaderstorage'), 'check is not shader storage buffer')

  -- check debug name
  test:assert_equals('testvertexbuffer', vertexbuffer1:get_debug_name(), 'check buffer debug name')

  -- check buffer format and format properties
  local format = vertexbuffer1:get_format()
  test:assert_equals('table', type(format), 'check buffer format is table')
  test:assert_equals(#vertexformat, #format, 'check buffer format length')
  for i, v in ipairs(vertexformat) do
    test:assert_equals(v.name, format[i].name, string.format('check buffer format %d name', i))
    test:assert_equals(v.format, format[i].format, string.format('check buffer format %d format', i))
    test:assert_equals(0, format[i].arraylength, string.format('check buffer format %d array length', i))
    test:assert_not_nil(format[i].offset)
  end

  -- check index buffer
  local indexbuffer = love.graphics.new_buffer('uint16', 128, {index=true})
  test:assert_true(indexbuffer:is_buffer_type('index'), 'check is index buffer')

end


-- Shader Storage GraphicsBuffer (love.graphics.new_buffer)
-- Separated from the above test so we can skip it when they aren't supported.
love.test.graphics.ShaderStorageBuffer = function(test)
  if not love.graphics.get_supported().glsl4 then
    test:skip_test('GLSL 4 and shader storage buffers are not supported on this system')
    return
  end

  -- setup buffer
  local format = {
    { name="1", format="float" },
    { name="2", format="floatmat4x4" },
    { name="3", format="floatvec2" }
  }
  local buffer = love.graphics.new_buffer(format, 1, {shaderstorage = true})
  test:assert_equals(96, buffer:get_element_stride(), 'check shader storage buffer element stride')

  -- set new data
  local data = {}
  for i = 1, 19 do
    data[i] = 0
  end
  buffer:set_array_data(data)

end


-- Canvas (love.graphics.new_canvas)
love.test.graphics.Canvas = function(test)

  -- create canvas with defaults
  local canvas = love.graphics.new_canvas(100, 100, {
    type = '2d',
    format = 'normal',
    readable = true,
    msaa = 0,
    dpiscale = love.graphics.get_dpi_scale(),
    mipmaps = 'auto',
    debugname = 'testcanvas'
  })
  test:assert_object(canvas)
  test:assert_true(canvas:is_canvas(), 'check is canvas')
  test:assert_false(canvas:is_compute_writable(), 'check not compute writable')

  -- check dpi
  test:assert_equals(love.graphics.get_dpi_scale(), canvas:get_dpi_scale(), 'check dpi scale')

  -- check depth
  test:assert_equals(1, canvas:get_depth(), 'check depth is 2d')
  test:assert_equals(nil, canvas:get_depth_sample_mode(), 'check depth sample nil')

  local maxanisotropy = love.graphics.get_system_limits().anisotropy

  -- check fliter
  local min1, mag1, ani1 = canvas:get_filter()
  test:assert_equals('nearest', min1, 'check filter def min')
  test:assert_equals('nearest', mag1, 'check filter def mag')
  test:assert_equals(1, ani1, 'check filter def ani')
  canvas:set_filter('linear', 'linear', 2)
  local min2, mag2, ani2 = canvas:get_filter()
  test:assert_equals('linear', min2, 'check filter changed min')
  test:assert_equals('linear', mag2, 'check filter changed mag')
  test:assert_equals(math.min(maxanisotropy, 2), ani2, 'check filter changed ani')

  -- check layer
  test:assert_equals(1, canvas:get_layer_count(), 'check 1 layer for 2d')

  -- check texture type
  test:assert_equals('2d', canvas:get_texture_type(), 'check 2d')

  -- check texture wrap
  local horiz1, vert1 = canvas:get_wrap()
  test:assert_equals('clamp', horiz1, 'check def wrap h')
  test:assert_equals('clamp', vert1, 'check def wrap v')
  canvas:set_wrap('repeat', 'repeat')
  local horiz2, vert2 = canvas:get_wrap()
  test:assert_equals('repeat', horiz2, 'check changed wrap h')
  test:assert_equals('repeat', vert2, 'check changed wrap v')

    -- check readable
  test:assert_true(canvas:is_readable(), 'check canvas readable')

  -- check msaa
  test:assert_equals(1, canvas:get_msaa(), 'check samples match')

  -- check dimensions
  local cw, ch = canvas:get_dimensions()
  test:assert_equals(100, cw, 'check canvas dim w')
  test:assert_equals(100, ch, 'check canvas dim h')
  test:assert_equals(cw, canvas:get_width(), 'check canvas w matches dim')
  test:assert_equals(ch, canvas:get_height(), 'check canvas h matches dim')
  local pw, ph = canvas:get_pixel_dimensions()
  test:assert_equals(100*love.graphics.get_dpi_scale(), pw, 'check pixel dim w')
  test:assert_equals(100*love.graphics.get_dpi_scale(), ph, 'check pixel dim h')
  test:assert_equals(pw, canvas:get_pixel_width(), 'check pixel w matches dim')
  test:assert_equals(ph, canvas:get_pixel_height(), 'check pixel h matches dim')

  -- check mipmaps
  local mode, sharpness = canvas:get_mipmap_filter()
  test:assert_equals('linear', mode, 'check def minmap filter  mode')
  test:assert_equals(0, sharpness, 'check def minmap filter sharpness')
  local name, version, vendor, device = love.graphics.get_renderer_info()
  canvas:set_mipmap_filter('nearest', 1)
  mode, sharpness = canvas:get_mipmap_filter()
  test:assert_equals('nearest', mode, 'check changed minmap filter  mode')
  -- @NOTE mipmap sharpness wont work on opengl/metal
  if string.match(name, 'OpenGL ES') == nil and string.match(name, 'Metal') == nil then
    test:assert_equals(1, sharpness, 'check changed minmap filter sharpness')
  end
  test:assert_greater_equal(2, canvas:get_mipmap_count()) -- docs say no mipmaps should return 1
  test:assert_equals('auto', canvas:get_mipmap_mode())

  -- check debug name
  test:assert_equals('testcanvas', canvas:get_debug_name())

  -- check basic rendering
  canvas:render_to(function()
    love.graphics.set_color(1, 0, 0)
    love.graphics.rectangle('fill', 0, 0, 200, 200)
    love.graphics.set_color(1, 1, 1, 1)
  end)
  local imgdata1 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata1)

  -- check using canvas in love.graphics.draw()
  local xcanvas = love.graphics.new_canvas()
  love.graphics.set_canvas(xcanvas)
    love.graphics.draw(canvas, 0, 0)
  love.graphics.set_canvas()
  local imgdata2 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata2)

  -- check y-down
  local shader1 = love.graphics.new_shader[[
    vec4 effect(vec4 c, Image tex, vec2 tc, vec2 pc) {
      return tc.y > 0.5 ? vec4(1.0, 0.0, 0.0, 1.0) : vec4(0.0, 1.0, 0.0, 1.0);
    }
  ]]
  local shader2 = love.graphics.new_shader[[
    vec4 effect(vec4 c, Image tex, vec2 tc, vec2 pc) {
      // rounding during quantization from float to unorm8 doesn't seem to be
      // totally consistent across devices, lets do it ourselves.
      highp vec2 value = pc / love_ScreenSize.xy;
      highp vec2 quantized = (floor(255.0 * value + 0.5) + 0.1) / 255.0;
      return vec4(quantized, 0.0, 1.0);
    }
  ]]
  local img = love.graphics.new_image(love.image.new_image_data(1, 1))

  love.graphics.push("all")
    love.graphics.set_canvas(canvas)
    love.graphics.set_shader(shader1)
    love.graphics.draw(img, 0, 0, 0, canvas:get_dimensions())
  love.graphics.pop()
  local imgdata3 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata3)

  love.graphics.push("all")
    love.graphics.set_canvas(canvas)
    love.graphics.set_shader(shader2)
    love.graphics.draw(img, 0, 0, 0, canvas:get_dimensions())
  love.graphics.pop()
  local imgdata4 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata4)


  -- check depth samples
  local dcanvas = love.graphics.new_canvas(100, 100, {
    type = '2d',
    format = 'depth16',
    readable = true
  })
  test:assert_equals(nil, dcanvas:get_depth_sample_mode(), 'check depth sample mode nil by def')
  dcanvas:set_depth_sample_mode('equal')
  test:assert_equals('equal', dcanvas:get_depth_sample_mode(), 'check depth sample mode set')

  -- check compute writeable (wont work on opengl mac)
  if love.graphics.get_supported().glsl4 then
    local ccanvas = love.graphics.new_canvas(100, 100, {
      type = '2d',
      format = 'rgba8',
      computewrite = true
    })
    test:assert_true(ccanvas:is_compute_writable())
  end

end


-- Font (love.graphics.new_font)
love.test.graphics.Font = function(test)

  -- create obj
  local font = love.graphics.new_font('resources/font.ttf', 8)
  test:assert_object(font)

  -- check ascent/descent
  test:assert_equals(6, font:get_ascent(), 'check ascent')
  test:assert_equals(-2, font:get_descent(), 'check descent')

  -- check baseline
  test:assert_equals(6, font:get_baseline(), 'check baseline')

  -- check dpi 
  test:assert_equals(1, font:get_dpi_scale(), 'check dpi')

  -- check filter
  test:assert_equals('nearest', font:get_filter(), 'check filter def')
  font:set_filter('linear', 'linear')
  test:assert_equals('linear', font:get_filter(), 'check filter change')
  font:set_filter('nearest', 'nearest')

  -- check height + lineheight
  test:assert_equals(8, font:get_height(), 'check height')
  test:assert_equals(1, font:get_line_height(), 'check line height')
  font:set_line_height(2)
  test:assert_equals(2, font:get_line_height(), 'check changed line height')
  font:set_line_height(1) -- reset for drawing + wrap later

  -- check width + kerning
  test:assert_equals(0, font:get_kerning('a', 'b'), 'check kerning')
  test:assert_equals(24, font:get_width('test'), 'check data size')

  -- check specific glyphs
  test:assert_true(font:has_glyphs('test'), 'check data size')

  -- check font wrapping
  local width, wrappedtext = font:get_wrap('LÖVE is an *awesome* framework you can use to make 2D games in Lua.', 50)
  test:assert_equals(48, width, 'check actual wrap width')
  test:assert_equals(8, #wrappedtext, 'check wrapped lines')
  test:assert_equals('LÖVE is an ', wrappedtext[1], 'check wrapped line')

  -- check drawing font 
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.set_font(font)
    love.graphics.print('Aa', 0, 5)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)

  -- check font substitution
  local fontab = love.graphics.new_image_font('resources/font-letters-ab.png', 'AB')
  local fontcd = love.graphics.new_image_font('resources/font-letters-cd.png', 'CD')
  fontab:set_fallbacks(fontcd)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.set_font(fontab)
    love.graphics.print('AB', 0, 0) -- should come from fontab
    love.graphics.print('CD', 0, 9) -- should come from fontcd
  love.graphics.set_canvas()
  local imgdata2 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata2)

end


-- Image (love.graphics.new_image)
love.test.graphics.Image = function(test)

  -- create object
  local image = love.graphics.new_image('resources/love.png', {
    dpiscale = 1,
    mipmaps = true
  })
  test:assert_object(image)
  test:assert_false(image:is_canvas(), 'check not canvas')
  test:assert_false(image:is_compute_writable(), 'check not compute writable')

  -- check dpi
  test:assert_equals(love.graphics.get_dpi_scale(), image:get_dpi_scale(), 'check dpi scale')

  -- check depth
  test:assert_equals(1, image:get_depth(), 'check depth is 2d')
  test:assert_equals(nil, image:get_depth_sample_mode(), 'check depth sample nil')

  local maxanisotropy = love.graphics.get_system_limits().anisotropy

  -- check filter
  local min1, mag1, ani1 = image:get_filter()
  test:assert_equals('nearest', min1, 'check filter def min')
  test:assert_equals('nearest', mag1, 'check filter def mag')
  test:assert_equals(1, ani1, 'check filter def ani')
  image:set_filter('linear', 'linear', 2)
  local min2, mag2, ani2 = image:get_filter()
  test:assert_equals('linear', min2, 'check filter changed min')
  test:assert_equals('linear', mag2, 'check filter changed mag')
  test:assert_equals(math.min(maxanisotropy, 2), ani2, 'check filter changed ani')
  image:set_filter('nearest', 'nearest', 1)

  -- check layers
  test:assert_equals(1, image:get_layer_count(), 'check 1 layer for 2d')

  -- check texture type
  test:assert_equals('2d', image:get_texture_type(), 'check 2d')

  -- check texture wrapping
  local horiz1, vert1 = image:get_wrap()
  test:assert_equals('clamp', horiz1, 'check def wrap h')
  test:assert_equals('clamp', vert1, 'check def wrap v')
  image:set_wrap('repeat', 'repeat')
  local horiz2, vert2 = image:get_wrap()
  test:assert_equals('repeat', horiz2, 'check changed wrap h')
  test:assert_equals('repeat', vert2, 'check changed wrap v')

    -- check readable
  test:assert_true(image:is_readable(), 'check canvas readable')

  -- check msaa
  test:assert_equals(1, image:get_msaa(), 'check samples match')

  -- check dimensions
  local cw, ch = image:get_dimensions()
  test:assert_equals(64, cw, 'check canvas dim w')
  test:assert_equals(64, ch, 'check canvas dim h')
  test:assert_equals(cw, image:get_width(), 'check canvas w matches dim')
  test:assert_equals(ch, image:get_height(), 'check canvas h matches dim')
  local pw, ph = image:get_pixel_dimensions()
  test:assert_equals(64*love.graphics.get_dpi_scale(), pw, 'check pixel dim w')
  test:assert_equals(64*love.graphics.get_dpi_scale(), ph, 'check pixel dim h')
  test:assert_equals(pw, image:get_pixel_width(), 'check pixel w matches dim')
  test:assert_equals(ph, image:get_pixel_height(), 'check pixel h matches dim')

  -- check mipmaps
  local mode, sharpness = image:get_mipmap_filter()
  test:assert_equals('linear', mode, 'check def minmap filter  mode')
  test:assert_equals(0, sharpness, 'check def minmap filter sharpness')
  local name, version, vendor, device = love.graphics.get_renderer_info()
  -- @note mipmap sharpness wont work on opengl/metal
  image:set_mipmap_filter('nearest', 1)
  mode, sharpness = image:get_mipmap_filter()
  test:assert_equals('nearest', mode, 'check changed minmap filter  mode')
  if string.match(name, 'OpenGL ES') == nil and string.match(name, 'Metal') == nil then
    test:assert_equals(1, sharpness, 'check changed minmap filter sharpness')
  end
  test:assert_greater_equal(2, image:get_mipmap_count()) -- docs say no mipmaps should return 1?

  -- check image properties
  test:assert_false(image:is_compressed(), 'check not compressed')
  test:assert_false(image:is_format_linear(), 'check not linear')
  local cimage = love.graphics.new_image('resources/love.dxt1')
  test:assert_object(cimage)
  test:assert_true(cimage:is_compressed(), 'check is compressed')

  -- check pixel replacement
  local rimage = love.image.new_image_data('resources/loveinv.png')
  image:replace_pixels(rimage)
  local canvas = love.graphics.new_canvas(64, 64)
  love.graphics.set_canvas(canvas)
    love.graphics.draw(image, 0, 0)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  local r1, g1, b1 = imgdata:get_pixel(25, 25)
  test:assert_equals(3, r1+g1+b1, 'check back to white')
  test:compare_img(imgdata)

end


-- Mesh (love.graphics.new_mesh)
love.test.graphics.Mesh = function(test)

  -- create 2d mesh with pretty colors
  local image = love.graphics.new_image('resources/love.png')
  local vertices = {
		{ 0, 0, 0, 0, 1, 0, 0 },
		{ image:get_width(), 0, 1, 0, 0, 1, 0 },
		{ image:get_width(), image:get_height(), 1, 1, 0, 0, 1 },
		{ 0, image:get_height(), 0, 1, 1, 1, 0 },
  }
  local mesh1 = love.graphics.new_mesh(vertices, 'fan')
  test:assert_object(mesh1)

  -- check draw mode
  test:assert_equals('fan', mesh1:get_draw_mode(), 'check draw mode')
  mesh1:set_draw_mode('triangles')
  test:assert_equals('triangles', mesh1:get_draw_mode(), 'check draw mode set')

  -- check draw range
  local min1, max1 = mesh1:get_draw_range()
  test:assert_equals(nil, min1, 'check draw range not set')
  mesh1:set_draw_range(1, 10)
  local min2, max2 = mesh1:get_draw_range()
  test:assert_equals(1, min2, 'check draw range set min')
  test:assert_equals(10, max2, 'check draw range set max')

  -- check texture pointer
  test:assert_equals(nil, mesh1:get_texture(), 'check no texture')
  mesh1:set_texture(image)
  test:assert_equals(image:get_height(), mesh1:get_texture():getHeight(), 'check texture match w')
  test:assert_equals(image:get_width(), mesh1:get_texture():getWidth(), 'check texture match h')

  -- check vertext count
  test:assert_equals(4, mesh1:get_vertex_count(), 'check vertex count')

  -- check def vertex format
  local format = mesh1:get_vertex_format()
  test:assert_equals('floatvec2', format[2].format, 'check def vertex format 2')
  test:assert_equals('VertexColor', format[3].name, 'check def vertex format 3')

  -- check vertext attributes
  test:assert_true(mesh1:is_attribute_enabled('VertexPosition'), 'check def attribute VertexPosition')
  test:assert_true(mesh1:is_attribute_enabled('VertexTexCoord'), 'check def attribute VertexTexCoord')
  test:assert_true(mesh1:is_attribute_enabled('VertexColor'), 'check def attribute VertexColor')
  mesh1:set_attribute_enabled('VertexPosition', false)
  mesh1:set_attribute_enabled('VertexTexCoord', false)
  mesh1:set_attribute_enabled('VertexColor', false)
  test:assert_false(mesh1:is_attribute_enabled('VertexPosition'), 'check disable attribute VertexPosition')
  test:assert_false(mesh1:is_attribute_enabled('VertexTexCoord'), 'check disable attribute VertexTexCoord')
  test:assert_false(mesh1:is_attribute_enabled('VertexColor'), 'check disable attribute VertexColor')

  -- check vertex itself
  local x1, y1, u1, v1, r1, g1, b1, a1 = mesh1:get_vertex(1)
  test:assert_equals(0, x1, 'check vertex props x')
  test:assert_equals(0, y1, 'check vertex props y')
  test:assert_equals(0, u1, 'check vertex props u')
  test:assert_equals(0, v1, 'check vertex props v')
  test:assert_equals(1, r1, 'check vertex props r')
  test:assert_equals(0, g1, 'check vertex props g')
  test:assert_equals(0, b1, 'check vertex props b')
  test:assert_equals(1, a1, 'check vertex props a')

  -- check setting a specific vertex
  mesh1:set_vertex(2, image:get_width(), 0, 1, 0, 0, 1, 1, 1)
  local x2, y2, u2, v2, r2, g2, b2, a2 = mesh1:get_vertex(2)
  test:assert_equals(image:get_width(), x2, 'check changed vertex props x')
  test:assert_equals(0, y2, 'check changed vertex props y')
  test:assert_equals(1, u2, 'check changed vertex props u')
  test:assert_equals(0, v2, 'check changed vertex props v')
  test:assert_equals(0, r2, 'check changed vertex props r')
  test:assert_equals(1, g2, 'check changed vertex props g')
  test:assert_equals(1, b2, 'check changed vertex props b')
  test:assert_equals(1, a2, 'check changed vertex props a')

  -- check setting a specific vertex attribute 
  local r3, g3, b3, a3  = mesh1:get_vertex_attribute(3, 3)
  test:assert_equals(1, b3, 'check specific vertex color')
  mesh1:set_vertex_attribute(4, 3, 1, 0, 1)
  local r4, g4, b4, a4  = mesh1:get_vertex_attribute(4, 3)
  test:assert_equals(0, g4, 'check changed vertex color')

  -- check setting a vertice
  mesh1:set_vertices(vertices)
  local r5, g5, b5, a5  = mesh1:get_vertex_attribute(4, 3)
  local x6, y6, u6, v6, r6, g6, b6, a6 = mesh1:get_vertex(2)
  test:assert_equals(1, g5, 'check reset vertex color 1')
  test:assert_equals(0, b5, 'check reset vertex color 2')

  -- check setting the vertex map 
  local vmap1 = mesh1:get_vertex_map()
  test:assert_equals(nil, vmap1, 'check no map by def')
  mesh1:set_vertex_map({4, 1, 2, 3})
  local vmap2 = mesh1:get_vertex_map()
  test:assert_equals(4, #vmap2, 'check set map len')
  test:assert_equals(2, vmap2[3], 'check set map val')

  -- check using custom attributes
  local mesh2 = love.graphics.new_mesh({
    { name = 'VertexPosition', format = 'floatvec2', location = 0},
    { name = 'VertexTexCoord', format = 'floatvec2', location = 1},
    { name = 'VertexColor', format = 'floatvec4', location = 2},
    { name = 'CustomValue1', format = 'floatvec2', location = 3},
    { name = 'CustomValue2', format = 'uint16', location = 4}
  }, {
		{ 0, 0, 0, 0, 1, 0, 0, 1, 2, 1, 1005 },
		{ image:get_width(), 0, 1, 0, 0, 1, 0, 0, 2, 2, 2005 },
		{ image:get_width(), image:get_height(), 1, 1, 0, 0, 1, 0, 2, 3, 3005 },
		{ 0, image:get_height(), 0, 1, 1, 1, 0, 0, 2, 4, 4005 },
  }, 'fan')
  local c1, c2 = mesh2:get_vertex_attribute(1, 4)
  local c3 = mesh2:get_vertex_attribute(1, 5)
  test:assert_equals(2, c1, 'check custom attribute val 1')
  test:assert_equals(1, c2, 'check custom attribute val 2')
  test:assert_equals(1005, c3, 'check custom attribute val 3')

  -- check attaching custom attribute + detaching
  mesh1:attach_attribute('CustomValue1', mesh2)
  test:assert_true(mesh1:is_attribute_enabled('CustomValue1'), 'check custom attribute attached')
  mesh1:detach_attribute('CustomValue1')
  local obj, err = pcall(mesh1.isAttributeEnabled, mesh1, 'CustomValue1')
  test:assert_not_equals(nil, err, 'check attribute detached')
  mesh1:detach_attribute('VertexPosition')
  test:assert_true(mesh1:is_attribute_enabled('VertexPosition'), 'check cant detach def attribute')

end


-- ParticleSystem (love.graphics.new_particle_system)
love.test.graphics.ParticleSystem = function(test)

  -- create new system 
  local image = love.graphics.new_image('resources/pixel.png')
  local quad1 = love.graphics.new_quad(0, 0, 1, 1, image)
  local quad2 = love.graphics.new_quad(0, 0, 1, 1, image)
  local psystem = love.graphics.new_particle_system(image, 1000)
  test:assert_object(psystem)

  -- check psystem state properties 
  psystem:start()
  psystem:update(1)
  test:assert_true(psystem:is_active(), 'check active')
  test:assert_false(psystem:is_paused(), 'checked not paused by def')
  test:assert_false(psystem:has_relative_rotation(), 'check rel rot def')
  psystem:pause()
  test:assert_true(psystem:is_paused(), 'check now paused')
  test:assert_false(psystem:is_stopped(), 'check not stopped by def')
  psystem:stop()
  test:assert_true(psystem:is_stopped(), 'check now stopped')
  psystem:start()
  psystem:reset()
  
  -- check emitting some particles
  -- need to set a lifespan at minimum or none will be counted 
  local min, max = psystem:get_particle_lifetime()
  test:assert_equals(0, min, 'check def lifetime min')
  test:assert_equals(0, max, 'check def lifetime max')
  psystem:set_particle_lifetime(1, 2)
  psystem:emit(10)
  psystem:update(1)
  test:assert_equals(10, psystem:get_count(), 'check added particles')
  psystem:reset()
  test:assert_equals(0, psystem:get_count(), 'check reset')

  -- check setting colors
  local colors1 = {psystem:get_colors()}
  test:assert_equals(1, #colors1, 'check 1 color by def')
  psystem:set_colors(1, 1, 1, 1, 1, 0, 0, 1)
  local colors2 = {psystem:get_colors()}
  test:assert_equals(2, #colors2, 'check set colors')
  test:assert_equals(1, colors2[2][1], 'check set color')

  -- check setting direction
  test:assert_equals(0, psystem:get_direction(), 'check def direction')
  psystem:set_direction(90 * (math.pi/180))
  test:assert_equals(math.floor(math.pi/2*100), math.floor(psystem:get_direction()*100), 'check set direction')

  -- check emission area options
  psystem:set_emission_area('normal', 100, 50)
  psystem:set_emission_area('ellipse', 100, 50)
  psystem:set_emission_area('borderellipse', 100, 50)
  psystem:set_emission_area('borderrectangle', 100, 50)
  psystem:set_emission_area('none', 100, 50)
  psystem:set_emission_area('uniform', 100, 50)
  local dist, dx, dy, angle, rel = psystem:get_emission_area()
  test:assert_equals('uniform', dist, 'check emission area dist')
  test:assert_equals(100, dx, 'check emission area dx')
  test:assert_equals(50, dy, 'check emission area dy')
  test:assert_equals(0, angle, 'check emission area angle')
  test:assert_false(rel, 'check emission area rel')

  -- check emission rate
  test:assert_equals(0, psystem:get_emission_rate(), 'check def emission rate')
  psystem:set_emission_rate(1)
  test:assert_equals(1, psystem:get_emission_rate(), 'check changed emission rate')

  -- check emission lifetime
  test:assert_equals(-1, psystem:get_emitter_lifetime(), 'check def emitter life')
  psystem:set_emitter_lifetime(10)
  test:assert_equals(10, psystem:get_emitter_lifetime(), 'check changed emitter life')

  -- check insert mode
  test:assert_equals('top', psystem:get_insert_mode(), 'check def insert mode')
  psystem:set_insert_mode('bottom')
  psystem:set_insert_mode('random')
  test:assert_equals('random', psystem:get_insert_mode(), 'check change insert mode')

  -- check linear acceleration
  local xmin1, ymin1, xmax1, ymax1 = psystem:get_linear_acceleration()
  test:assert_equals(0, xmin1, 'check def lin acceleration xmin')
  test:assert_equals(0, ymin1, 'check def lin acceleration ymin')
  test:assert_equals(0, xmax1, 'check def lin acceleration xmax')
  test:assert_equals(0, ymax1, 'check def lin acceleration ymax')
  psystem:set_linear_acceleration(1, 2, 3, 4)
  local xmin2, ymin2, xmax2, ymax2 = psystem:get_linear_acceleration()
  test:assert_equals(1, xmin2, 'check change lin acceleration xmin')
  test:assert_equals(2, ymin2, 'check change lin acceleration ymin')
  test:assert_equals(3, xmax2, 'check change lin acceleration xmax')
  test:assert_equals(4, ymax2, 'check change lin acceleration ymax')

  -- check linear damping
  local min3, max3 = psystem:get_linear_damping()
  test:assert_equals(0, min3, 'check def lin damping min')
  test:assert_equals(0, max3, 'check def lin damping max')
  psystem:set_linear_damping(1, 2)
  local min4, max4 = psystem:get_linear_damping()
  test:assert_equals(1, min4, 'check change lin damping min')
  test:assert_equals(2, max4, 'check change lin damping max')

  -- check offset
  local ox1, oy1 = psystem:get_offset()
  test:assert_equals(0.5, ox1, 'check def offset x') -- 0.5 cos middle of pixel image which is 1x1
  test:assert_equals(0.5, oy1, 'check def offset y')
  psystem:set_offset(0, 10)
  local ox2, oy2 = psystem:get_offset()
  test:assert_equals(0, ox2, 'check change offset x')
  test:assert_equals(10, oy2, 'check change offset y')

  -- check lifetime (we set it earlier)
  local min5, max5 = psystem:get_particle_lifetime()
  test:assert_equals(1, min5, 'check p lifetime min')
  test:assert_equals(2, max5, 'check p lifetime max')

  -- check position
  local x1, y1 = psystem:get_position()
  test:assert_equals(0, x1, 'check emitter x')
  test:assert_equals(0, y1, 'check emitter y')
  psystem:set_position(10, 12)
  local x2, y2 = psystem:get_position()
  test:assert_equals(10, x2, 'check set emitter x')
  test:assert_equals(12, y2, 'check set emitter y')

  -- check quads
  test:assert_equals(0, #psystem:get_quads(), 'check def quads')
  psystem:set_quads({quad1})
  psystem:set_quads(quad1, quad2)
  test:assert_equals(2, #psystem:get_quads(), 'check set quads')

  -- check radial acceleration
  local min6, max6 = psystem:get_radial_acceleration()
  test:assert_equals(0, min6, 'check def rad accel min')
  test:assert_equals(0, max6, 'check def rad accel max')
  psystem:set_radial_acceleration(1, 2)
  local min7, max7 = psystem:get_radial_acceleration()
  test:assert_equals(1, min7, 'check change rad accel min')
  test:assert_equals(2, max7, 'check change rad accel max')

  -- check rotation
  local min8, max8 = psystem:get_rotation()
  test:assert_equals(0, min8, 'check def rot min')
  test:assert_equals(0, max8, 'check def rot max')
  psystem:set_rotation(90 * (math.pi/180), 180 * (math.pi/180))
  local min8, max8 = psystem:get_rotation()
  test:assert_equals(math.floor(math.pi/2*100), math.floor(min8*100), 'check set rot min')
  test:assert_equals(math.floor(math.pi*100), math.floor(max8*100), 'check set rot max')

  -- check variation
  test:assert_equals(0, psystem:get_size_variation(), 'check def variation')
  psystem:set_size_variation(1)
  test:assert_equals(1, psystem:get_size_variation(), 'check change variation')

  -- check sizes
  test:assert_equals(1, #{psystem:get_sizes()}, 'check def size')
  psystem:set_sizes(1, 2, 4, 1, 3, 2)
  local sizes = {psystem:get_sizes()}
  test:assert_equals(6, #sizes, 'check set sizes')
  test:assert_equals(3, sizes[5], 'check set size')

  -- check speed
  local min9, max9 = psystem:get_speed()
  test:assert_equals(0, min9, 'check def speed min')
  test:assert_equals(0, max9, 'check def speed max')
  psystem:set_speed(1, 10)
  local min10, max10 = psystem:get_speed()
  test:assert_equals(1, min10, 'check change speed min')
  test:assert_equals(10, max10, 'check change speed max')

  -- check variation + spin
  local variation = psystem:get_spin_variation()
  test:assert_equals(0, variation, 'check def spin variation')
  psystem:set_spin_variation(1)
  test:assert_equals(1, psystem:get_spin_variation(), 'check change spin variation')
  psystem:set_spin(1, 2)
  local min11, max11 = psystem:get_spin()
  test:assert_equals(1, min11, 'check change spin min')
  test:assert_equals(2, max11, 'check change spin max')

  -- check spread
  test:assert_equals(0, psystem:get_spread(), 'check def spread')
  psystem:set_spread(90 * (math.pi/180))
  test:assert_equals(math.floor(math.pi/2*100), math.floor(psystem:get_spread()*100), 'check change spread')

  -- tangential acceleration
  local min12, max12 = psystem:get_tangential_acceleration()
  test:assert_equals(0, min12, 'check def tan accel min')
  test:assert_equals(0, max12, 'check def tan accel max')
  psystem:set_tangential_acceleration(1, 2)
  local min13, max13 = psystem:get_tangential_acceleration()
  test:assert_equals(1, min13, 'check change tan accel min')
  test:assert_equals(2, max13, 'check change tan accel max')

  -- check texture
  test:assert_not_equals(nil, psystem:get_texture(), 'check texture obj')
  test:assert_object(psystem:get_texture())
  psystem:set_texture(love.graphics.new_image('resources/love.png'))
  test:assert_object(psystem:get_texture())

  -- try a graphics test!
  -- hard to get exactly because of the variation but we can use some pixel 
  -- tolerance and volume to try and cover the randomness
  local psystem2 = love.graphics.new_particle_system(image, 5000)
  psystem2:set_emission_area('uniform', 2, 64)
  psystem2:set_colors(1, 0, 0, 1)
  psystem2:set_direction(0 * math.pi/180)
  psystem2:set_emitter_lifetime(100)
  psystem2:set_emission_rate(5000)
  local psystem3 = psystem2:clone()
  psystem3:set_position(64, 0)
  psystem3:set_colors(0, 1, 0, 1)
  psystem3:set_direction(180 * (math.pi/180))
  psystem2:start()
  psystem3:start()
  psystem2:update(1)
  psystem3:update(1)
  local canvas = love.graphics.new_canvas(64, 64)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.draw(psystem2, 0, 0)
    love.graphics.draw(psystem3, 0, 0)
  love.graphics.set_canvas()
  -- this should result in a bunch of red pixels on the left 2px of the canvas
  -- and a bunch of green pixels on the right 2px of the canvas
  local imgdata = love.graphics.readback_texture(canvas)
  test.pixel_tolerance = 1
  test:compare_img(imgdata)
  
end


-- Quad (love.graphics.new_quad)
love.test.graphics.Quad = function(test)

  -- create quad obj
  local texture = love.graphics.new_image('resources/love.png')
  local quad = love.graphics.new_quad(0, 0, 32, 32, texture)
  test:assert_object(quad)

  -- check properties
  test:assert_equals(1, quad:get_layer(), 'check default layer')
  quad:set_layer(2)
  test:assert_equals(2, quad:get_layer(), 'check changed layer')
  local sw, sh = quad:get_texture_dimensions()
  test:assert_equals(64, sw, 'check texture w')
  test:assert_equals(64, sh, 'check texture h')

  -- check drawing and viewport changes
  local canvas = love.graphics.new_canvas(64, 64)
  love.graphics.set_canvas(canvas)
    love.graphics.draw(texture, quad, 0, 0)
    quad:set_viewport(32, 32, 32, 32, 64, 64)
    love.graphics.draw(texture, quad, 32, 32)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)

end


-- Shader (love.graphics.new_shader)
love.test.graphics.Shader = function(test)

  -- check valid shader
  local pixelcode1 = [[
    uniform Image tex2;
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) { 
      vec4 texturecolor = Texel(tex2, texture_coords); 
      return texturecolor * color;
    }
  ]]
  local vertexcode1 = [[
    vec4 position(mat4 transform_projection, vec4 vertex_position) { 
      return transform_projection * vertex_position; 
    }
  ]]
  local shader1 = love.graphics.new_shader(pixelcode1, vertexcode1, {debugname = 'testshader'})
  test:assert_object(shader1)
  test:assert_equals('', shader1:get_warnings(), 'check shader valid')
  test:assert_false(shader1:has_uniform('tex1'), 'check invalid uniform')
  test:assert_true(shader1:has_uniform('tex2'), 'check valid uniform')
  test:assert_equals('testshader', shader1:get_debug_name())

  -- check invalid shader
  local pixelcode2 = [[
    uniform float ww;
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) { 
      vec4 texturecolor = Texel(tex, texture_coords);
      float unused = ww * 3 * color;
      return texturecolor * color;
    }
  ]]
  local res, err = pcall(love.graphics.new_shader, pixelcode2, vertexcode1)
  test:assert_not_equals(nil, err, 'check shader compile fails')

  -- check using a shader to draw + sending uniforms
  -- shader will return a given color if overwrite set to 1, otherwise def. draw
  local pixelcode3 = [[
    uniform vec4 col;
    uniform float overwrite;
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) { 
      vec4 texcol = Texel(tex, texture_coords); 
      if (overwrite == 1.0) {
        return col;
      } else {
        return texcol * color;
      }
    }
  ]]
  local shader3 = love.graphics.new_shader(pixelcode3, vertexcode1)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.push("all")
    love.graphics.set_canvas(canvas)
    -- set color to yellow
    love.graphics.set_color(1, 1, 0, 1)
    -- turn shader 'on' and use red to draw
    shader3:send('overwrite', 1)
    shader3:send_color('col', {1, 0, 0, 1})
    love.graphics.set_shader(shader3)
      love.graphics.rectangle('fill', 0, 0, 8, 8)
    love.graphics.set_shader()
    -- turn shader 'off' and draw again
    shader3:send('overwrite', 0)
    love.graphics.set_shader(shader3)
      love.graphics.rectangle('fill', 8, 8, 8, 8)
  love.graphics.pop()

  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)

  -- test some uncommon paths for shader uniforms
  local shader4 = love.graphics.new_shader[[
    uniform bool booleans[5];
    vec4 effect(vec4 vcolor, Image tex, vec2 tc, vec2 pc) {
      return booleans[3] ? vec4(0, 1, 0, 0) : vec4(1, 0, 0, 0);
    }
  ]]

  shader4:send("booleans", false, true, true)

  local shader5 = love.graphics.new_shader[[
    uniform sampler2D textures[5];
    vec4 effect(vec4 vcolor, Image tex, vec2 tc, vec2 pc) {
      return Texel(textures[2], tc) + Texel(textures[3], tc);
    }
  ]]

  local canvas2 = love.graphics.new_canvas(1, 1)
  love.graphics.set_canvas(canvas2)
  love.graphics.clear(0, 0.5, 0, 1)
  love.graphics.set_canvas()

  shader5:send("textures", canvas2, canvas2, canvas2, canvas2, canvas2)

  local shader6 = love.graphics.new_shader[[
    struct Data {
      bool boolValue;
      float floatValue;
      sampler2D tex;
    };

    uniform Data data;
    uniform Data dataArray[3];

    vec4 effect(vec4 vcolor, Image tex, vec2 tc, vec2 pc) {
      return (data.boolValue && dataArray[1].boolValue) ? Texel(dataArray[0].tex, tc) : vec4(0.0, 0.0, 0.0, 0.0);
    }
  ]]

  shader6:send("data.boolValue", true)
  shader6:send("dataArray[1].boolValue", true)
  shader6:send("dataArray[0].tex", canvas2)

  local shader7 = love.graphics.new_shader[[
    uniform vec3 vec3s[3];

    vec4 effect(vec4 vcolor, Image tex, vec2 tc, vec2 pc) {
      return vec4(vec3s[1], 1.0);
    }
  ]]

  shader7:send("vec3s", {0, 0, 1}, {0, 1, 0}, {1, 0, 0})

  local canvas3 = love.graphics.new_canvas(16, 16)
  love.graphics.push("all")
    love.graphics.set_canvas(canvas3)
    love.graphics.set_shader(shader7)
    love.graphics.rectangle("fill", 0, 0, 16, 16)
  love.graphics.pop()
  local imgdata2 = love.graphics.readback_texture(canvas3)
  test:compare_img(imgdata2)

  if love.graphics.get_supported().glsl3 then
    local shader8 = love.graphics.new_shader[[
      #pragma language glsl3
      #ifdef GL_ES
        precision highp float;
      #endif

      varying vec4 VaryingUnused1;
      varying mat3 VaryingMatrix;
      flat varying ivec4 VaryingInt;

      #ifdef VERTEX
      layout(location = 0) in vec4 VertexPosition;
      layout(location = 1) in ivec4 IntAttributeUnused;

      void vertexmain()
      {
        VaryingMatrix = mat3(vec3(1, 0, 0), vec3(0, 1, 0), vec3(0, 0, 1));
        VaryingInt = ivec4(1, 1, 1, 1);
        love_Position = TransformProjectionMatrix * VertexPosition;
      }
      #endif

      #ifdef PIXEL
      out ivec4 outData;

      void pixelmain()
      {
        outData = ivec4(VaryingMatrix[1][1] > 0.0 ? 1 : 0, 1, VaryingInt.x, 1);
      }
      #endif
    ]]

    local canvas4 = love.graphics.new_canvas(16, 16, {format="rgba8i"})
      love.graphics.push("all")
      love.graphics.set_blend_mode("none")
      love.graphics.set_canvas(canvas4)
      love.graphics.set_shader(shader8)
      love.graphics.rectangle("fill", 0, 0, 16, 16)
    love.graphics.pop()

    local intimagedata = love.graphics.readback_texture(canvas4)
    local imgdata3 = love.image.new_image_data(16, 16, "rgba8")
    for y=0, 15 do
      for x=0, 15 do
        local ir, ig, ib, ia = intimagedata:get_int8(4 * (y * 16 + x), 4)
        imgdata3:set_pixel(x, y, ir, ig, ib, ia)
      end
    end
    test:compare_img(imgdata3)
  else
    test:assert_true(true, "skip shader IO test")
  end
end


-- SpriteBatch (love.graphics.new_sprite_batch)
love.test.graphics.SpriteBatch = function(test)

  -- create batch
  local texture1 = love.graphics.new_image('resources/cubemap.png')
  local texture2 = love.graphics.new_image('resources/love.png')
  local quad1 = love.graphics.new_quad(32, 12, 1, 1, texture2) -- lovepink
  local quad2 = love.graphics.new_quad(32, 32, 1, 1, texture2) -- white
  local sbatch = love.graphics.new_sprite_batch(texture1, 5000)
  test:assert_object(sbatch)

  -- check initial count
  test:assert_equals(0, sbatch:get_count(), 'check batch size')

  -- check buffer size
  test:assert_equals(5000, sbatch:get_buffer_size(), 'check batch size')

  -- check height/width/texture
  test:assert_equals(texture1:get_width(), sbatch:get_texture():getWidth(), 'check texture match w')
  test:assert_equals(texture1:get_height(), sbatch:get_texture():getHeight(), 'check texture match h')
  sbatch:set_texture(texture2)
  test:assert_equals(texture2:get_width(), sbatch:get_texture():getWidth(), 'check texture change w')
  test:assert_equals(texture2:get_height(), sbatch:get_texture():getHeight(), 'check texture change h')

  -- check colors
  local r1, g1, b1, a1 = sbatch:get_color()
  test:assert_equals(1, r1, 'check initial color r')
  test:assert_equals(1, g1, 'check initial color g')
  test:assert_equals(1, b1, 'check initial color b')
  test:assert_equals(1, a1, 'check initial color a')
  sbatch:set_color(1, 0, 0, 1)
  local r2, g2, b2, a2 = sbatch:get_color()
  test:assert_equals(1, r2, 'check set color r')
  test:assert_equals(0, g2, 'check set color g')
  test:assert_equals(0, b2, 'check set color b')
  test:assert_equals(1, a2, 'check set color a')

  -- check adding sprites
  local offset_x = 0
  local offset_y = 0
  local color = 'white'
  sbatch:set_color(1, 1, 1, 1)
  local sprites = {}
  for s=1,4096 do
    local spr = sbatch:add(quad1, offset_x, offset_y, 0, 1, 1)
    table.insert(sprites, {spr, offset_x, offset_y})
    offset_x = offset_x + 1
    if s % 64 == 0 then
      -- alternate row colors
      if color == 'white' then
        color = 'red'
        sbatch:set_color(1, 0, 0, 1)
      else
        color = 'white'
        sbatch:set_color(1, 1, 1, 1)
      end
      offset_y = offset_y + 1
      offset_x = 0
    end
  end
  test:assert_equals(4096, sbatch:get_count())

  -- test drawing and setting
  local canvas = love.graphics.new_canvas(64, 64)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.draw(sbatch, 0, 0)
  love.graphics.set_canvas()
  local imgdata1 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata1)

  -- use set to change some sprites
  for s=1,2048 do
    sbatch:set(sprites[s][1], quad2, sprites[s][2], sprites[s][3]+1, 0, 1, 1)
  end
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.draw(sbatch, 0, 0)
  love.graphics.set_canvas()
  local imgdata2 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata2)

  -- set drawRange and redraw
  sbatch:set_draw_range(1025, 2048)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.draw(sbatch, 0, 0)
  love.graphics.set_canvas()
  local imgdata3 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata3)

  -- clear and redraw
  sbatch:clear()
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.draw(sbatch, 0, 0)
  love.graphics.set_canvas()
  local imgdata4 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata4)

  -- array texture sbatch
  local texture3 = love.graphics.new_array_image({
    'resources/love.png',
    'resources/loveinv.png'
  })
  local asbatch = love.graphics.new_sprite_batch(texture3, 4096)
  local quad3 = love.graphics.new_quad(32, 52, 1, 1, texture3) -- loveblue
  sprites = {}
  for s=1,4096 do
    local spr = asbatch:add_layer(1, quad3, 0, s, math.floor(s/64), 1, 1)
    table.insert(sprites, {spr, s, math.floor(s/64)})
  end
  test:assert_equals(4096, asbatch:get_count(), 'check max batch size applies')
  for s=1,2048 do
    asbatch:set_layer(sprites[s][1], 2, sprites[s][2], sprites[s][3], 0, 1, 1)
  end
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.draw(asbatch, 0, 0)
  love.graphics.set_canvas()
  local imgdata5 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata5)

end


-- Text (love.graphics.new_text_batch)
love.test.graphics.Text = function(test)

  -- setup text object
  local font = love.graphics.new_font('resources/font.ttf', 8)
  local plaintext = love.graphics.new_text_batch(font, 'test')
  test:assert_object(plaintext)

  -- check height/width/dimensions
  test:assert_equals(font:get_height(), plaintext:get_font():getHeight(), 'check font matches')
  local tw, th = plaintext:get_dimensions()
  test:assert_equals(24, tw, 'check initial dim w')
  test:assert_equals(8, th, 'check initial dim h')
  test:assert_equals(tw, plaintext:get_width(), 'check initial dim w')
  test:assert_equals(th, plaintext:get_height(), 'check initial dim h')

  -- check changing text effects dimensions
  plaintext:add('more text', 100, 0, 0)
  test:assert_equals(49, plaintext:get_dimensions(), 'check adding text')
  plaintext:set('test')
  test:assert_equals(24, plaintext:get_dimensions(), 'check resetting text')
  plaintext:clear()
  test:assert_equals(0, plaintext:get_dimensions(), 'check clearing text')

  -- check drawing + setting more complex text
  local colortext = love.graphics.new_text_batch(font, {{1, 0, 0, 1}, 'test'})
  test:assert_object(colortext)
  colortext:setf('LÖVE is an *awesome* framework you can use to make 2D games in Lua', 60, 'right')
  colortext:addf({{1, 1, 0}, 'overlap'}, 1000, 'left')
  local font2 = love.graphics.new_font('resources/font.ttf', 8)
  colortext:set_font(font2)
  local canvas = love.graphics.new_canvas(64, 64)
  love.graphics.set_canvas(canvas)
    love.graphics.draw(colortext, 0, 10)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)

end


-- Video (love.graphics.new_video)
love.test.graphics.Video = function(test)

  -- create video obj
  local video = love.graphics.new_video('resources/sample.ogv')
  test:assert_object(video)

  -- check dimensions
  local w, h = video:get_dimensions()
  test:assert_equals(496, w, 'check vid dim w')
  test:assert_equals(502, h, 'check vid dim h')
  test:assert_equals(w, video:get_width(), 'check vid width match')
  test:assert_equals(h, video:get_height(), 'check vid height match')

  -- check filters
  local min1, mag1, ani1 = video:get_filter()
  test:assert_equals('nearest', min1, 'check def filter min')
  test:assert_equals('nearest', mag1, 'check def filter mag')
  test:assert_equals(1, ani1, 'check def filter ani')
  video:set_filter('linear', 'linear', 2)
  local min2, mag2, ani2 = video:get_filter()
  test:assert_equals('linear', min2, 'check changed filter min')
  test:assert_equals('linear', mag2, 'check changed filter mag')
  test:assert_equals(2, ani2, 'check changed filter ani')

  -- check video playing
  test:assert_false(video:is_playing(), 'check paused by default')
  test:assert_equals(0, video:tell(), 'check 0:00 by default')

  -- covered by their own obj tests in video but check returns obj
  local source = video:get_source()
  test:assert_object(source)
  local stream = video:get_stream()
  test:assert_object(stream)

  -- check playing / pausing / seeking states
  video:play()
  test:wait_seconds(0.25)
  video:pause()
  -- runners can be a bit funny and just not play anything sometimes
  if not GITHUB_RUNNER then
    test:assert_range(video:tell(), 0.2, 0.35, 'check video playing for 0.25s')
  end
  video:seek(0.2)
  test:assert_equals(0.2, video:tell(), 'check video seeking')
  video:rewind()
  test:assert_equals(0, video:tell(), 'check video rewind')
  video:set_filter('nearest', 'nearest', 1)

  -- check actuall drawing with the vid 
  local canvas = love.graphics.new_canvas(500, 500)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(1, 0, 0, 1)
    love.graphics.draw(video, 0, 0)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------DRAWING-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.graphics.arc
love.test.graphics.arc = function(test)
  -- draw some arcs using pi format
  local canvas = love.graphics.new_canvas(32, 32)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 1, 1, 1)
    love.graphics.arc('line', "pie", 16, 16, 16, 0 * (math.pi/180), 360 * (math.pi/180), 10)
    love.graphics.arc('fill', "pie", 16, 16, 16, 270 * (math.pi/180), 45 * (math.pi/180), 10)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.arc('line', "pie", 16, 16, 16, 0 * (math.pi/180), 90 * (math.pi/180), 10)
    love.graphics.set_color(1, 1, 0, 1)
    love.graphics.arc('line', "pie", 16, 16, 16, 180 * (math.pi/180), 135 * (math.pi/180), 10)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata1 = love.graphics.readback_texture(canvas)
  -- draw some arcs with open format
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 1, 1, 1)
    love.graphics.arc('line', "open", 16, 16, 16, 0 * (math.pi/180), 315 * (math.pi/180), 10)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.arc('fill', "open", 16, 16, 16, 0 * (math.pi/180), 180 * (math.pi/180), 10)
    love.graphics.set_color(1, 1, 0, 1)
    love.graphics.arc('fill', "open", 16, 16, 16, 180 * (math.pi/180), 270 * (math.pi/180), 10)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata2 = love.graphics.readback_texture(canvas)
  -- draw some arcs with closed format
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 1, 1, 1)
    love.graphics.arc('line', "closed", 16, 16, 16, 0 * (math.pi/180), 315 * (math.pi/180), 10)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.arc('fill', "closed", 16, 16, 16, 0 * (math.pi/180), 180 * (math.pi/180), 10)
    love.graphics.set_color(1, 1, 0, 1)
    love.graphics.arc('line', "closed", 16, 16, 16, 180 * (math.pi/180), 90 * (math.pi/180), 10)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata3 = love.graphics.readback_texture(canvas)
  if GITHUB_RUNNER and test:is_os('OS X') then
    -- on macosx runners, the arcs are not drawn as accurately at low res
    -- there's a couple pixels different in the curve of the arc but as we
    -- are at such a low resolution I think that can be expected
    -- on real hardware the test passes fine though  
    test:assert_true(true, 'skip test')
  else
    test:compare_img(imgdata1)
    test:compare_img(imgdata2)
    test:compare_img(imgdata3)
  end
end


-- love.graphics.circle
love.test.graphics.circle = function(test)
  -- draw some circles
  local canvas = love.graphics.new_canvas(32, 32)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 1, 1, 1)
    love.graphics.circle('fill', 16, 16, 16)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.circle('line', 16, 16, 16)
    love.graphics.set_color(1, 1, 0, 1)
    love.graphics.circle('fill', 16, 16, 8)
    love.graphics.set_color(0, 1, 0, 1)
    love.graphics.circle('fill', 16, 16, 4)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end



-- love.graphics.clear
love.test.graphics.clear = function(test)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.clear(1, 1, 0, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.discard
love.test.graphics.discard = function(test)
  -- from the docs: "on some desktops this may do nothing"
  test:skip_test('cant test this worked')
end


-- love.graphics.draw
love.test.graphics.draw = function(test)
  local canvas1 = love.graphics.new_canvas(32, 32)
  local canvas2 = love.graphics.new_canvas(32, 32)
  local transform = love.math.new_transform( )
  transform:translate(16, 0)
  transform:scale(0.5, 0.5)
  love.graphics.set_canvas(canvas1)
    love.graphics.clear(0, 0, 0, 1)
    -- img, offset
    love.graphics.draw(Logo.texture, Logo.img, 0, 0, 0, 1, 1, 16, 16)
  love.graphics.set_canvas()
  love.graphics.set_canvas(canvas2)
    love.graphics.clear(1, 0, 0, 1)
    -- canvas, scale, shear, transform obj
    love.graphics.draw(canvas1, 0, 0, 0, 1, 1, 0, 0, 2, 2)
    love.graphics.draw(canvas1, 0, 16, 0, 0.5, 0.5)
    love.graphics.draw(canvas1, 16, 16, 0, 0.5, 0.5)
    love.graphics.draw(canvas1, transform)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas2)
  test:compare_img(imgdata)
end


-- love.graphics.draw_instanced
love.test.graphics.draw_instanced = function(test)
  local image = love.graphics.new_image('resources/love.png')
  local vertices = {
		{ 0, 0, 0, 0, 1, 0, 0 },
		{ image:get_width(), 0, 1, 0, 0, 1, 0 },
		{ image:get_width(), image:get_height(), 1, 1, 0, 0, 1 },
		{ 0, image:get_height(), 0, 1, 1, 1, 0 },
  }
  local mesh = love.graphics.new_mesh(vertices, 'fan')
  local canvas = love.graphics.new_canvas(64, 64)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.draw_instanced(mesh, 1000, 0, 0, 0, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  -- need 1 tolerance here just cos of the amount of colors
  test.rgba_tolerance = 1
  test:compare_img(imgdata)
end


-- love.graphics.draw_layer
love.test.graphics.draw_layer = function(test)
  local image = love.graphics.new_array_image({
    'resources/love.png', 'resources/loveinv.png',
    'resources/love.png', 'resources/loveinv.png'
  })
  local canvas = love.graphics.new_canvas(64, 64)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.draw_layer(image, 1, 0, 0, 0, 1, 1)
    love.graphics.draw_layer(image, 2, 32, 0, 0, 0.5, 0.5)
    love.graphics.draw_layer(image, 4, 0, 32, 0, 0.5, 0.5)
    love.graphics.draw_layer(image, 3, 32, 32, 0, 2, 2, 16, 16)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.ellipse
love.test.graphics.ellipse = function(test)
  local canvas = love.graphics.new_canvas(32, 32)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.ellipse('fill', 16, 16, 16, 8)
    love.graphics.set_color(1, 1, 0, 1)
    love.graphics.ellipse('fill', 24, 24, 10, 24)
    love.graphics.set_color(1, 0, 1, 1)
    love.graphics.ellipse('fill', 16, 0, 8, 16)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.flush_batch
love.test.graphics.flush_batch = function(test)
  love.graphics.flush_batch()
  local initial = love.graphics.get_stats()['drawcalls']
  local canvas = love.graphics.new_canvas(32, 32)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, 32, 32)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  love.graphics.flush_batch()
  local after = love.graphics.get_stats()['drawcalls']
  test:assert_equals(initial+1, after, 'check drawcalls increased')
end


-- love.graphics.line
love.test.graphics.line = function(test)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.line(1,1,16,1,16,16,1,16,1,1)
    love.graphics.set_color(1, 1, 0, 1)
    love.graphics.line({0,0,8,8,16,0,8,8,16,16,8,8,0,16})
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.points
love.test.graphics.points = function(test)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.push("all")
    love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.translate(0.5, 0.5) -- draw points at the center of pixels
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.points(0,0,15,0,15,15,0,15,0,0)
    love.graphics.set_color(1, 1, 0, 1)
    love.graphics.points({1,1,7,7,14,1,7,8,14,14,8,8,1,14,8,7})
  love.graphics.pop()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.polygon
love.test.graphics.polygon = function(test)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.polygon("fill", 1, 1, 4, 5, 8, 10, 16, 2, 7, 3, 5, 16, 16, 16, 1, 8)
    love.graphics.set_color(1, 1, 0, 1)
    love.graphics.polygon("line", {2, 2, 4, 5, 3, 7, 8, 15, 12, 4, 5, 10})
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.print
love.test.graphics.print = function(test)
  love.graphics.set_font(Font)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.print('love', 0, 3, 0, 1, 1, 0, 0)
    love.graphics.set_color(0, 1, 0, 1)
    love.graphics.print('ooo', 0, 3, 0, 2, 2, 0, 0)
    love.graphics.set_color(0, 0, 1, 1)
    love.graphics.print('hello', 0, 3, 90*(math.pi/180), 1, 1, 0, 8)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.printf
love.test.graphics.printf = function(test)
  love.graphics.set_font(Font)
  local canvas = love.graphics.new_canvas(32, 32)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.printf('love', 0, 0, 8, "left")
    love.graphics.set_color(0, 1, 0, 1)
    love.graphics.printf('love', 0, 5, 16, "right")
    love.graphics.set_color(0, 0, 1, 1)
    love.graphics.printf('love', 0, 7, 32, "center")
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.rectangle
love.test.graphics.rectangle = function(test)
  -- setup, draw a 16x16 red rectangle with a blue central square
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, 16, 16)
    love.graphics.set_color(0, 0, 1, 1)
    love.graphics.rectangle('fill', 6, 6, 4, 4)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata1 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata1)
  -- clear canvas to do some line testing
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.rectangle('line', 1, 1, 15, 15) -- red border
    love.graphics.set_color(0, 0, 1, 1)
    love.graphics.rectangle('line', 1, 1, 2, 15) -- 3x16 left aligned blue outline
    love.graphics.set_color(0, 1, 0, 1)
    love.graphics.rectangle('line', 11, 1, 5, 15) -- 6x16 right aligned green outline
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata2 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata2)
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------OBJECT CREATION---------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.graphics.capture_screenshot
love.test.graphics.capture_screenshot = function(test)
  love.graphics.capture_screenshot('example-screenshot.png')
  test:wait_frames(1)
  -- need to wait until end of the frame for the screenshot
  test:assert_true(love.filesystem.exists('example-screenshot.png'))
  love.filesystem.remove('example-screenshot.png')
  -- test callback version
  local cbdata = nil
  local prevtextcommand = TextCommand
  TextCommand = "Capturing screenshot"
  love.graphics.capture_screenshot(function (idata)
    test:assert_not_equals(nil, idata, 'check we have image data')
    cbdata = idata
  end)
  test:wait_frames(1)
  TextCommand = prevtextcommand
  test:assert_not_nil(cbdata)

  if test:is_os('iOS', 'Android') then
    -- Mobile operating systems don't let us control the window resolution,
    -- so we can't compare the reference image properly.
    test:assert_true(true, 'skip test')
  else
    test:compare_img(cbdata)
  end
end


-- love.graphics.new_array_image
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_array_image = function(test)
  test:assert_object(love.graphics.new_array_image({
    'resources/love.png', 'resources/love2.png', 'resources/love3.png'
  }))
end

-- love.graphics.new_canvas
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_canvas = function(test)
  test:assert_object(love.graphics.new_canvas(16, 16, {
    type = '2d',
    format = 'normal',
    readable = true,
    msaa = 0,
    dpiscale = 1,
    mipmaps = 'none'
  }))
  test:assert_object(love.graphics.new_canvas(1000, 1000))
end


-- love.graphics.new_cube_image
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_cube_image = function(test)
  test:assert_object(love.graphics.new_cube_image('resources/cubemap.png', {
    mipmaps = false,
    linear = false
  }))
end


-- love.graphics.new_font
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_font = function(test)
  test:assert_object(love.graphics.new_font('resources/font.ttf'))
  test:assert_object(love.graphics.new_font('resources/font.ttf', 8, "normal", 1))
end


-- love.graphics.new_image
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_image = function(test)
  test:assert_object(love.graphics.new_image('resources/love.png', {
    mipmaps = false,
    linear = false,
    dpiscale = 1
  }))
end


-- love.graphics.new_image_font
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_image_font = function(test)
  test:assert_object(love.graphics.new_image_font('resources/love.png', 'ABCD', 1))
end


-- love.graphics.new_mesh
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_mesh = function(test)
  test:assert_object(love.graphics.new_mesh({{1, 1, 0, 0, 1, 1, 1, 1}}, 'fan', 'dynamic'))
end


-- love.graphics.new_particle_system
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_particle_system = function(test)
  local imgdata = love.graphics.new_image('resources/love.png')
  test:assert_object(love.graphics.new_particle_system(imgdata, 1000))
end


-- love.graphics.new_quad
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_quad = function(test)
  local imgdata = love.graphics.new_image('resources/love.png')
  test:assert_object(love.graphics.new_quad(0, 0, 16, 16, imgdata))
end


-- love.graphics.new_shader
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_shader = function(test)
  local pixelcode = [[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) { 
      vec4 texturecolor = Texel(tex, texture_coords); 
      return texturecolor * color;
    }
  ]]
  local vertexcode = [[
    vec4 position(mat4 transform_projection, vec4 vertex_position) { 
      return transform_projection * vertex_position; 
    }
  ]]
  test:assert_object(love.graphics.new_shader(pixelcode, vertexcode))
end


-- love.graphics.new_sprite_batch
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_sprite_batch = function(test)
  local imgdata = love.graphics.new_image('resources/love.png')
  test:assert_object(love.graphics.new_sprite_batch(imgdata, 1000))
end


-- love.graphics.new_text_batch
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_text_batch = function(test)
  local font = love.graphics.new_font('resources/font.ttf')
  test:assert_object(love.graphics.new_text_batch(font, 'helloworld'))
end


-- love.graphics.new_texture
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_texture = function(test)
  local imgdata = love.image.new_image_data('resources/love.png')
  test:assert_object(love.graphics.new_texture(imgdata))
end


-- love.graphics.new_video
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_video = function(test)
  test:assert_object(love.graphics.new_video('resources/sample.ogv', {
    audio = false,
    dpiscale = 1
  }))
end


-- love.graphics.new_volume_image
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.graphics.new_volume_image = function(test)
  test:assert_object(love.graphics.new_volume_image({
    'resources/love.png', 'resources/love2.png', 'resources/love3.png'
  }, {
    mipmaps = false,
    linear = false
  }))
end


-- love.graphics.validate_shader
love.test.graphics.validate_shader = function(test)
  local pixelcode = [[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) { 
      vec4 texturecolor = Texel(tex, texture_coords); 
      return texturecolor * color;
    }
  ]]
  local vertexcode = [[
    vec4 position(mat4 transform_projection, vec4 vertex_position) { 
      return transform_projection * vertex_position; 
    }
  ]]
  -- check made up code first
  local status, _ = love.graphics.validate_shader(true, 'nothing here', 'or here')
  test:assert_false(status, 'check invalid shader code')
  -- check real code 
  status, _ = love.graphics.validate_shader(true, pixelcode, vertexcode)
  test:assert_true(status, 'check valid shader code')
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
---------------------------------GRAPHICS STATE---------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.graphics.get_background_color
love.test.graphics.get_background_color = function(test)
  -- check default bg is black
  local r, g, b, a = love.graphics.get_background_color()
  test:assert_equals(0, r, 'check default background r')
  test:assert_equals(0, g, 'check default background g')
  test:assert_equals(0, b, 'check default background b')
  test:assert_equals(1, a, 'check default background a')
  -- check set value returns correctly
  love.graphics.set_background_color(1, 1, 1, 0)
  r, g, b, a = love.graphics.get_background_color()
  test:assert_equals(1, r, 'check updated background r')
  test:assert_equals(1, g, 'check updated background g')
  test:assert_equals(1, b, 'check updated background b')
  test:assert_equals(0, a, 'check updated background a')
  love.graphics.set_background_color(0, 0, 0, 1) -- reset
end


-- love.graphics.get_blend_mode
love.test.graphics.get_blend_mode = function(test)
  -- check default blend mode
  local mode, alphamode = love.graphics.get_blend_mode()
  test:assert_equals('alpha', mode, 'check default blend mode')
  test:assert_equals('alphamultiply', alphamode, 'check default alpha blend')
  -- check set mode returns correctly
  love.graphics.set_blend_mode('add', 'premultiplied')
  mode, alphamode = love.graphics.get_blend_mode()
  test:assert_equals('add', mode, 'check changed blend mode')
  test:assert_equals('premultiplied', alphamode, 'check changed alpha blend')
  love.graphics.set_blend_mode('alpha', 'alphamultiply') -- reset
end


-- love.graphics.get_canvas
love.test.graphics.get_canvas = function(test)
  -- by default should be nil if drawing to real screen
  test:assert_equals(nil, love.graphics.get_canvas(), 'check no canvas set')
  -- should return not nil when we target a canvas
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
  test:assert_object(love.graphics.get_canvas())
  love.graphics.set_canvas()
end


-- love.graphics.get_color
love.test.graphics.get_color = function(test)
  -- by default should be white
  local r, g, b, a = love.graphics.get_color()
  test:assert_equals(1, r, 'check default color r')
  test:assert_equals(1, g, 'check default color g')
  test:assert_equals(1, b, 'check default color b')
  test:assert_equals(1, a, 'check default color a')
  -- check set color is returned correctly
  love.graphics.set_color(0, 0, 0, 0)
  r, g, b, a = love.graphics.get_color()
  test:assert_equals(0, r, 'check changed color r')
  test:assert_equals(0, g, 'check changed color g')
  test:assert_equals(0, b, 'check changed color b')
  test:assert_equals(0, a, 'check changed color a')
  love.graphics.set_color(1, 1, 1, 1) -- reset
end


-- love.graphics.get_color_mask
love.test.graphics.get_color_mask = function(test)
  -- by default should all be active
  local r, g, b, a = love.graphics.get_color_mask()
  test:assert_true(r, 'check default color mask r')
  test:assert_true(g, 'check default color mask g')
  test:assert_true(b, 'check default color mask b')
  test:assert_true(a, 'check default color mask a')
  -- check set color mask is returned correctly
  love.graphics.set_color_mask(false, false, true, false)
  r, g, b, a = love.graphics.get_color_mask()
  test:assert_false(r, 'check changed color mask r')
  test:assert_false(g, 'check changed color mask g')
  test:assert_true( b, 'check changed color mask b')
  test:assert_false(a, 'check changed color mask a')
  love.graphics.set_color_mask(true, true, true, true) -- reset
end


-- love.graphics.get_default_filter
love.test.graphics.get_default_filter = function(test)
  -- we set this already for testsuite so we know what it should be
  local min, mag, anisotropy = love.graphics.get_default_filter()
  test:assert_equals('nearest', min, 'check default filter min')
  test:assert_equals('nearest', mag, 'check default filter mag')
  test:assert_equals(1, anisotropy, 'check default filter mag')
end


-- love.graphics.get_depth_mode
love.test.graphics.get_depth_mode = function(test)
  -- by default should be always/write
  local comparemode, write = love.graphics.get_depth_mode()
  test:assert_equals('always', comparemode, 'check default compare depth')
  test:assert_false(write, 'check default depth buffer write')
end


-- love.graphics.get_font
love.test.graphics.get_font = function(test)
  test:assert_object(love.graphics.get_font())
end


-- love.graphics.get_front_face_winding
love.test.graphics.get_front_face_winding = function(test)
  -- check default winding
  test:assert_equals('ccw', love.graphics.get_front_face_winding())
  -- check setting value changes it correctly
  love.graphics.set_front_face_winding('cw')
  test:assert_equals('cw', love.graphics.get_front_face_winding())
  love.graphics.set_front_face_winding('ccw') -- reset
end


-- love.graphics.get_line_join
love.test.graphics.get_line_join = function(test)
  -- check default line join
  test:assert_equals('miter', love.graphics.get_line_join())
  -- check set value returned correctly
  love.graphics.set_line_join('none')
  test:assert_equals('none', love.graphics.get_line_join())
  love.graphics.set_line_join('miter') -- reset
end


-- love.graphics.get_line_style
love.test.graphics.get_line_style = function(test)
  -- we know this should be as testsuite sets it!
  test:assert_equals('rough', love.graphics.get_line_style())
  -- check set value returned correctly
  love.graphics.set_line_style('smooth')
  test:assert_equals('smooth', love.graphics.get_line_style())
  love.graphics.set_line_style('rough') -- reset
end


-- love.graphics.get_line_width
love.test.graphics.get_line_width = function(test)
  -- we know this should be as testsuite sets it!
  test:assert_equals(1, love.graphics.get_line_width())
  -- check set value returned correctly
  love.graphics.set_line_width(10)
  test:assert_equals(10, love.graphics.get_line_width())
  love.graphics.set_line_width(1) -- reset
end


-- love.graphics.get_mesh_cull_mode
love.test.graphics.get_mesh_cull_mode = function(test)
  -- get default mesh culling
  test:assert_equals('none', love.graphics.get_mesh_cull_mode())
  -- check set value returned correctly
  love.graphics.set_mesh_cull_mode('front')
  test:assert_equals('front', love.graphics.get_mesh_cull_mode())
  love.graphics.set_mesh_cull_mode('back') -- reset
end


-- love.graphics.get_point_size
love.test.graphics.get_point_size = function(test)
  -- get default point size
  test:assert_equals(1, love.graphics.get_point_size())
  -- check set value returned correctly
  love.graphics.set_point_size(10)
  test:assert_equals(10, love.graphics.get_point_size())
  love.graphics.set_point_size(1) -- reset
end


-- love.graphics.get_scissor
love.test.graphics.get_scissor = function(test)
  -- should be no scissor atm
  local x, y, w, h = love.graphics.get_scissor()
  test:assert_equals(nil, x, 'check no scissor')
  test:assert_equals(nil, y, 'check no scissor')
  test:assert_equals(nil, w, 'check no scissor')
  test:assert_equals(nil, h, 'check no scissor')
  -- check set value returned correctly
  love.graphics.set_scissor(0, 0, 16, 16)
  x, y, w, h = love.graphics.get_scissor()
  test:assert_equals(0, x, 'check scissor set')
  test:assert_equals(0, y, 'check scissor set')
  test:assert_equals(16, w, 'check scissor set')
  test:assert_equals(16, h, 'check scissor set')
  love.graphics.set_scissor() -- reset
end


-- love.graphics.get_shader
love.test.graphics.get_shader = function(test)
  -- should be no shader active
  test:assert_equals(nil, love.graphics.get_shader(), 'check no active shader')
end


-- love.graphics.get_stack_depth
love.test.graphics.get_stack_depth = function(test)
  -- by default should be none
  test:assert_equals(0, love.graphics.get_stack_depth(), 'check no transforms in stack')
  -- now add 3
  love.graphics.push()
  love.graphics.push()
  love.graphics.push()
  test:assert_equals(3, love.graphics.get_stack_depth(), 'check 3 transforms in stack')
  -- now remove 2
  love.graphics.pop()
  love.graphics.pop()
  test:assert_equals(1, love.graphics.get_stack_depth(), 'check 1 transforms in stack')
  -- now back to 0
  love.graphics.pop()
  test:assert_equals(0, love.graphics.get_stack_depth(), 'check no transforms in stack')
end


-- love.graphics.get_stencil_state
love.test.graphics.get_stencil_state = function(test)
  -- check default vals
  local action, comparemode, value = love.graphics.get_stencil_state( )
  test:assert_equals('keep', action, 'check default stencil action')
  test:assert_equals('always', comparemode, 'check default stencil compare')
  test:assert_equals(0, value, 'check default stencil value')
  -- check set stencil values is returned
  love.graphics.set_stencil_state('replace', 'less', 255)
  local action, comparemode, value = love.graphics.get_stencil_state()
  test:assert_equals('replace', action, 'check changed stencil action')
  test:assert_equals('less', comparemode, 'check changed stencil compare')
  test:assert_equals(255, value, 'check changed stencil value')
  love.graphics.set_stencil_state() -- reset
end


-- love.graphics.intersect_scissor
love.test.graphics.intersect_scissor = function(test)
  -- make a scissor for the left half, then interset to make the top half
  -- then we should be able to fill the canvas with red and only top 4x4 is filled
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()
    love.graphics.set_scissor(0, 0, 8, 16)
    love.graphics.intersect_scissor(0, 0, 4, 4)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, 16, 16)
    love.graphics.set_color(1, 1, 1, 1)
    love.graphics.set_scissor()
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.is_active
love.test.graphics.is_active = function(test)
  test:assert_true(love.graphics.is_active(), 'check graphics is active') -- i mean if you got this far
end


-- love.graphics.is_gamma_correct
love.test.graphics.is_gamma_correct = function(test)
  -- we know the config so know this is false
  test:assert_not_nil(love.graphics.is_gamma_correct())
end


-- love.graphics.is_wireframe
love.test.graphics.is_wireframe = function(test)
  local name, version, vendor, device = love.graphics.get_renderer_info()
  if string.match(name, 'OpenGL ES') then
    test:skip_test('Wireframe not supported on OpenGL ES')
  else
    -- check off by default
    test:assert_false(love.graphics.is_wireframe(), 'check no wireframe by default')
    -- check on when enabled
    love.graphics.set_wireframe(true)
    test:assert_true(love.graphics.is_wireframe(), 'check wireframe is set')
    love.graphics.set_wireframe(false) -- reset
  end
end


-- love.graphics.reset
love.test.graphics.reset = function(test)
  -- reset should reset current canvas and any colors/scissor
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_background_color(0, 0, 1, 1)
  love.graphics.set_color(0, 1, 0, 1)
  love.graphics.set_canvas(canvas)
  love.graphics.reset()
  local r, g, b, a = love.graphics.get_background_color()
  test:assert_equals(1, r+g+b+a, 'check background reset')
  r, g, b, a = love.graphics.get_color()
  test:assert_equals(4, r+g+b+a, 'check color reset')
  test:assert_equals(nil, love.graphics.get_canvas(), 'check canvas reset')
  love.graphics.set_default_filter("nearest", "nearest")
  love.graphics.set_line_style('rough')
  love.graphics.set_point_size(1)
  love.graphics.set_line_width(1)
end


-- love.graphics.set_background_color
love.test.graphics.set_background_color = function(test)
  -- check background is set
  love.graphics.set_background_color(1, 0, 0, 1)
  local r, g, b, a = love.graphics.get_background_color()
  test:assert_equals(1, r, 'check set bg r')
  test:assert_equals(0, g, 'check set bg g')
  test:assert_equals(0, b, 'check set bg b')
  test:assert_equals(1, a, 'check set bg a')
  love.graphics.set_background_color(0, 0, 0, 1)
end


-- love.graphics.set_blend_mode
love.test.graphics.set_blend_mode = function(test)
  -- create fully white canvas, then draw diff. pixels through blendmodes
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0.5, 0.5, 0.5, 1)
    love.graphics.set_blend_mode('add', 'alphamultiply')
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    love.graphics.set_blend_mode('subtract', 'alphamultiply')
    love.graphics.set_color(1, 1, 1, 0.5)
    love.graphics.rectangle('fill', 15, 0, 1, 1)
    love.graphics.set_blend_mode('multiply', 'premultiplied')
    love.graphics.set_color(0, 1, 0, 1)
    love.graphics.rectangle('fill', 15, 15, 1, 1)
    love.graphics.set_blend_mode('replace', 'premultiplied')
    love.graphics.set_color(0, 0, 1, 0.5)
    love.graphics.rectangle('fill', 0, 15, 1, 1)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  love.graphics.set_blend_mode('alpha', 'alphamultiply') -- reset 
  -- need 1rgba tolerance here on some machines
  test.rgba_tolerance = 1
  test:compare_img(imgdata)
end


-- love.graphics.set_canvas
love.test.graphics.set_canvas = function(test)
  -- make 2 canvas, set to each, draw one to the other, check output
  local canvas1 = love.graphics.new_canvas(16, 16)
  local canvas2 = love.graphics.new_canvas(16, 16, {mipmaps = "auto"})
  love.graphics.set_canvas(canvas1)
    test:assert_equals(canvas1, love.graphics.get_canvas(), 'check canvas 1 set')
    love.graphics.clear(1, 0, 0, 1)
  love.graphics.set_canvas(canvas2)
    test:assert_equals(canvas2, love.graphics.get_canvas(), 'check canvas 2 set')
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.draw(canvas1, 0, 0)
  love.graphics.set_canvas()
  test:assert_equals(nil, love.graphics.get_canvas(), 'check no canvas set')
  local imgdata = love.graphics.readback_texture(canvas2)
  test:compare_img(imgdata)
  local imgdata2 = love.graphics.readback_texture(canvas2, 1, 2) -- readback mipmap
  test:compare_img(imgdata2)
end


-- love.graphics.set_color
love.test.graphics.set_color = function(test)
  -- set colors, draw rect, check color 
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    local r, g, b, a = love.graphics.get_color()
    test:assert_equals(1, r, 'check r set')
    test:assert_equals(0, g, 'check g set')
    test:assert_equals(0, b, 'check b set')
    test:assert_equals(1, a, 'check a set')

    love.graphics.rectangle('fill', 0, 0, 16, 1)
    love.graphics.set_color(1, 1, 0, 1)
    love.graphics.rectangle('fill', 0, 1, 16, 1)
    love.graphics.set_color(0, 1, 0, 0.5)
    love.graphics.rectangle('fill', 0, 2, 16, 1)
    love.graphics.set_color(0, 0, 1, 1)
    love.graphics.rectangle('fill', 0, 3, 16, 1)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.set_color_mask
love.test.graphics.set_color_mask = function(test)
  -- set mask, draw stuff, check output pixels
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    -- mask off blue
    love.graphics.set_color_mask(true, true, false, true)
    local r, g, b, a = love.graphics.get_color_mask()
    test:assert_equals(r, true, 'check r mask')
    test:assert_equals(g, true, 'check g mask')
    test:assert_equals(b, false, 'check b mask')
    test:assert_equals(a, true, 'check a mask')
    -- draw "black" which should then turn to yellow
    love.graphics.set_color(1, 1, 1, 1)
    love.graphics.rectangle('fill', 0, 0, 16, 16)
    love.graphics.set_color_mask(true, true, true, true)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.set_default_filter
love.test.graphics.set_default_filter = function(test)
  -- check setting filter val works
  love.graphics.set_default_filter('linear', 'linear', 1)
  local min, mag, anisotropy = love.graphics.get_default_filter()
  test:assert_equals('linear', min, 'check default filter min')
  test:assert_equals('linear', mag, 'check default filter mag')
  test:assert_equals(1, anisotropy, 'check default filter mag')
  love.graphics.set_default_filter('nearest', 'nearest', 1) -- reset
end


-- love.graphics.set_depth_mode
love.test.graphics.set_depth_mode = function(test)
  -- check documented modes are valid
  local comparemode, write = love.graphics.get_depth_mode()
  local modes = {
    'equal', 'notequal', 'less', 'lequal', 'gequal',
    'greater', 'never', 'always'
  }
  for m=1,#modes do
    love.graphics.set_depth_mode(modes[m], true)
    test:assert_equals(modes[m], love.graphics.get_depth_mode(), 'check depth mode ' .. modes[m] .. ' set')
  end
  love.graphics.set_depth_mode(comparemode, write)
  -- @TODO better graphics drawing specific test
end


-- love.graphics.set_font
love.test.graphics.set_font = function(test)
  -- set font doesnt return anything so draw with the test font
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_font(Font)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.print('love', 0, 3)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.set_front_face_winding
love.test.graphics.set_front_face_winding = function(test)
  -- check documented modes are valid
  local original = love.graphics.get_front_face_winding()
  love.graphics.set_front_face_winding('cw')
  test:assert_equals('cw', love.graphics.get_front_face_winding(), 'check ffw cw set')
  love.graphics.set_front_face_winding('ccw')
  test:assert_equals('ccw', love.graphics.get_front_face_winding(), 'check ffw ccw set')
  love.graphics.set_front_face_winding(original)
  -- @TODO better graphics drawing specific test

  local shader = love.graphics.new_shader[[
vec4 effect(vec4 c, Image tex, vec2 tc, vec2 pc) {
  return gl_FrontFacing ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0); 
}
  ]]
  local dummyimg = love.graphics.new_image(love.image.new_image_data(1, 1))

  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.push("all")
    love.graphics.set_canvas(canvas)
    love.graphics.set_shader(shader)
    love.graphics.draw(dummyimg, 0, 0, 0, 16, 16)
  love.graphics.pop()

  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.set_line_join
love.test.graphics.set_line_join = function(test)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_font(Font)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    local line = {0,1,8,1,8,8}
    love.graphics.set_line_style('rough')
    love.graphics.set_line_width(2)
    love.graphics.set_color(1, 0, 0)
    love.graphics.set_line_join('bevel')
    love.graphics.line(line)
    love.graphics.translate(0, 4)
    love.graphics.set_color(1, 1, 0)
    love.graphics.set_line_join('none')
    love.graphics.line(line)
    love.graphics.translate(0, 4)
    love.graphics.set_color(0, 0, 1)
    love.graphics.set_line_join('miter')
    love.graphics.line(line)
    love.graphics.set_color(1, 1, 1)
    love.graphics.set_line_width(1)
    love.graphics.origin()
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.set_line_style
love.test.graphics.set_line_style = function(test)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_font(Font)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0)
    local line = {0,1,16,1}
    love.graphics.set_line_style('rough')
    love.graphics.line(line)
    love.graphics.translate(0, 4)
    love.graphics.set_line_style('smooth')
    love.graphics.line(line)
    love.graphics.set_line_style('rough')
    love.graphics.set_color(1, 1, 1)
    love.graphics.origin()
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  -- linux runner needs a 1/255 tolerance for the blend between a rough line + bg 
  if GITHUB_RUNNER and test:is_os('Linux') then
    test.rgba_tolerance = 1
  end
  test:compare_img(imgdata)
end


-- love.graphics.set_line_width
love.test.graphics.set_line_width = function(test)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_font(Font)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    local line = {0,1,8,1,8,8}
    love.graphics.set_color(1, 0, 0)
    love.graphics.set_line_width(2)
    love.graphics.line(line)
    love.graphics.translate(0, 4)
    love.graphics.set_color(1, 1, 0)
    love.graphics.set_line_width(3)
    love.graphics.line(line)
    love.graphics.translate(0, 4)
    love.graphics.set_color(0, 0, 1)
    love.graphics.set_line_width(4)
    love.graphics.line(line)
    love.graphics.set_color(1, 1, 1)
    love.graphics.set_line_width(1)
    love.graphics.origin()
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.set_mesh_cull_mode
love.test.graphics.set_mesh_cull_mode = function(test)
  -- check documented modes are valid
  local original = love.graphics.get_mesh_cull_mode()
  local modes = {'back', 'front', 'none'}
  for m=1,#modes do
    love.graphics.set_mesh_cull_mode(modes[m])
    test:assert_equals(modes[m], love.graphics.get_mesh_cull_mode(), 'check mesh cull mode ' .. modes[m] .. ' was set')
  end
  love.graphics.set_mesh_cull_mode(original)
  -- @TODO better graphics drawing specific test
end


-- love.graphics.set_scissor
love.test.graphics.set_scissor = function(test)
  -- make a scissor for the left half
  -- then we should be able to fill the canvas with red and only left is filled
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()
    love.graphics.set_scissor(0, 0, 8, 16)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, 16, 16)
    love.graphics.set_color(1, 1, 1, 1)
    love.graphics.set_scissor()
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.set_shader
love.test.graphics.set_shader = function(test)
  -- make a shader that will only ever draw yellow
  local pixelcode = [[
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) { 
      vec4 texturecolor = Texel(tex, texture_coords); 
      return vec4(1.0,1.0,0.0,1.0);
    }
  ]]
  local vertexcode = [[
    vec4 position(mat4 transform_projection, vec4 vertex_position) { 
      return transform_projection * vertex_position; 
    }
  ]]
  local shader = love.graphics.new_shader(pixelcode, vertexcode)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_shader(shader)
      -- draw red rectangle
      love.graphics.set_color(1, 0, 0, 1)
      love.graphics.rectangle('fill', 0, 0, 16, 16)
    love.graphics.set_shader()
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.set_stencil_state
love.test.graphics.set_stencil_state = function(test)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas({canvas, stencil=true})
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_stencil_state('replace', 'always', 1)
    love.graphics.circle('fill', 8, 8, 6)
    love.graphics.set_stencil_state('keep', 'greater', 0)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, 16, 16)
    love.graphics.set_color(1, 1, 1, 1)
    love.graphics.set_stencil_state()
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.set_wireframe
love.test.graphics.set_wireframe = function(test)
  local name, version, vendor, device = love.graphics.get_renderer_info()
  if string.match(name, 'OpenGL ES') then
    test:skip_test('Wireframe not supported on OpenGL ES')
  else
    -- check wireframe outlines
    love.graphics.set_wireframe(true)
    local canvas = love.graphics.new_canvas(16, 16)
    love.graphics.set_canvas(canvas)
      love.graphics.clear(0, 0, 0, 1)
      love.graphics.set_color(1, 1, 0, 1)
      love.graphics.rectangle('fill', 2, 2, 13, 13)
      love.graphics.set_color(1, 1, 1, 1)
    love.graphics.set_canvas()
    love.graphics.set_wireframe(false)
    local imgdata = love.graphics.readback_texture(canvas)
    -- on macOS runners wireframes are drawn 1px off from the target
    if GITHUB_RUNNER and test:is_os('OS X') then
      test.pixel_tolerance = 1
    end
    test:compare_img(imgdata)
  end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-------------------------------COORDINATE SYSTEM--------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.graphics.apply_transform
love.test.graphics.apply_transform = function(test)
  -- use transform object to translate the drawn rectangle
  local transform = love.math.new_transform()
  transform:translate(10, 0)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.apply_transform(transform)
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.inverse_transform_point
love.test.graphics.inverse_transform_point = function(test)
  -- start with 0, 0
  local sx, sy = love.graphics.inverse_transform_point(0, 0)
  test:assert_equals(0, sx, 'check starting x is 0')
  test:assert_equals(0, sy, 'check starting y is 0')
  -- check translation effects the point 
  love.graphics.translate(1, 5)
  sx, sy = love.graphics.inverse_transform_point(1, 5)
  test:assert_equals(0, sx, 'check transformed x is 0')
  test:assert_equals(0, sy, 'check transformed y is 0')
  love.graphics.origin()
end


-- love.graphics.origin
love.test.graphics.origin = function(test)
  -- if we do some translations and scaling
  -- using .origin() should reset it all and draw the pixel at 0,0
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()
    love.graphics.translate(10, 10)
    love.graphics.scale(1, 1)
    love.graphics.shear(20, 20)
    love.graphics.origin()
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.pop
love.test.graphics.pop = function(test)
  -- if we push at the start, and then run a pop
  -- it should reset it all and draw the pixel at 0,0
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.push()
    love.graphics.translate(10, 10)
    love.graphics.scale(1, 1)
    love.graphics.shear(20, 20)
    love.graphics.pop()
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.push
love.test.graphics.push = function(test)
  -- if we push at the start, do some stuff, then another push
  -- 1 pop should only go back 1 push and draw the pixel at 1, 1
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.push()
    love.graphics.scale(1, 1)
    love.graphics.shear(20, 20)
    love.graphics.push()
    love.graphics.translate(1, 1)
    love.graphics.pop()
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    love.graphics.set_color(1, 1, 1, 1)
    love.graphics.pop()
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.replace_transform
love.test.graphics.replace_transform = function(test)
  -- if use transform object to translate
  -- set some normal transforms first which should get overwritten
  local transform = love.math.new_transform()
  transform:translate(10, 0)
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.scale(2, 2)
    love.graphics.translate(10, 10)
    love.graphics.replace_transform(transform)
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.rotate
love.test.graphics.rotate = function(test)
  -- starting at 0,0, we rotate by 90deg and then draw
  -- we can then check the drawn rectangle is rotated
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.translate(4, 0)
    love.graphics.rotate(90 * (math.pi/180))
    love.graphics.rectangle('fill', 0, 0, 4, 4)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.scale
love.test.graphics.scale = function(test)
  -- starting at 0,0, we scale by 4x and then draw
  -- we can then check the drawn rectangle covers the whole canvas
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.scale(4, 4)
    love.graphics.rectangle('fill', 0, 0, 4, 4)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


-- love.graphics.shear
love.test.graphics.shear = function(test)
  -- starting at 0,0, we shear by 2x and then draw
  -- we can then check the drawn rectangle has moved over
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.shear(2, 0)
    love.graphics.rectangle('fill', 0, 0, 4, 4)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata1 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata1)
  -- same again at 0,0, we shear by 2y and then draw
  -- we can then check the drawn rectangle has moved down
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.shear(0, 2)
    love.graphics.rectangle('fill', 0, 0, 4, 4)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata2 = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata2)
end


-- love.graphics.transform_point
love.test.graphics.transform_point = function(test)
  -- start with 0, 0
  local sx, sy = love.graphics.transform_point(0, 0)
  test:assert_equals(0, sx, 'check starting x is 0')
  test:assert_equals(0, sy, 'check starting y is 0')
  -- check translation effects the point 
  love.graphics.translate(1, 5)
  sx, sy = love.graphics.transform_point(0, 0)
  test:assert_equals(1, sx, 'check transformed x is 0')
  test:assert_equals(5, sy, 'check transformed y is 10')
end


-- love.graphics.translate
love.test.graphics.translate = function(test)
  -- starting at 0,0, we translate 4 times and draw a pixel at each point
  -- we can then check the 4 points are now red
  local canvas = love.graphics.new_canvas(16, 16)
  love.graphics.set_canvas(canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.set_color(1, 0, 0, 1)
    love.graphics.translate(5, 0)
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    love.graphics.translate(0, 5)
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    love.graphics.translate(-5, 0)
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    love.graphics.translate(0, -5)
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    love.graphics.set_color(1, 1, 1, 1)
  love.graphics.set_canvas()
  local imgdata = love.graphics.readback_texture(canvas)
  test:compare_img(imgdata)
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-------------------------------------WINDOW-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.graphics.get_dpi_scale
-- @NOTE hardware dependent so can't check result
love.test.graphics.get_dpi_scale = function(test)
  test:assert_not_nil(love.graphics.get_dpi_scale())
end


-- love.graphics.get_dimensions
love.test.graphics.get_dimensions = function(test)
  -- check graphics dimensions match window dimensions 
  local gwidth, gheight = love.graphics.get_dimensions()
  local wwidth, wheight, _ = love.window.get_mode()
  test:assert_equals(wwidth, gwidth, 'check graphics dimension w matches window w')
  test:assert_equals(wheight, gheight, 'check graphics dimension h matches window h')
end


-- love.graphics.get_height
love.test.graphics.get_height = function(test)
  -- check graphics height match window height 
  local wwidth, wheight, _ = love.window.get_mode()
  test:assert_equals(wheight, love.graphics.get_height(), 'check graphics h matches window h')
end


-- love.graphics.get_pixel_dimensions
love.test.graphics.get_pixel_dimensions = function(test)
  -- check graphics dimensions match window dimensions relative to dpi
  local dpi = love.graphics.get_dpi_scale()
  local gwidth, gheight = love.graphics.get_pixel_dimensions()
  local wwidth, wheight, _ = love.window.get_mode()
  test:assert_equals(wwidth, gwidth/dpi, 'check graphics pixel dpi w matches window w')
  test:assert_equals(wheight, gheight/dpi, 'check graphics pixel dpi h matches window h')
end


-- love.graphics.get_pixel_height
love.test.graphics.get_pixel_height = function(test)
  -- check graphics height match window height relative to dpi
  local dpi = love.graphics.get_dpi_scale()
  local wwidth, wheight, _ = love.window.get_mode()
  test:assert_equals(wheight,love.graphics.get_pixel_height()/dpi, 'check graphics pixel dpi h matches window h')
end


-- love.graphics.get_pixel_width
love.test.graphics.get_pixel_width = function(test)
  -- check graphics width match window width relative to dpi
  local dpi = love.graphics.get_dpi_scale()
  local wwidth, wheight, _ = love.window.get_mode()
  test:assert_equals(wwidth, love.graphics.get_width()/dpi, 'check graphics pixel dpi w matches window w')
end


-- love.graphics.get_width
love.test.graphics.get_width = function(test)
  -- check graphics width match window width 
  local wwidth, wheight, _ = love.window.get_mode()
  test:assert_equals(wwidth, love.graphics.get_width(), 'check graphics w matches window w')
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-------------------------------SYSTEM INFORMATION-------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.graphics.get_texture_formats
love.test.graphics.get_texture_formats = function(test)
  local formats = {
    'hdr', 'r8i', 'r8ui', 'r16i', 'r16ui', 'r32i', 'r32ui', 'rg8i', 'rg8ui',
    'rg16i', 'rg16ui', 'rg32i', 'rg32ui', 'bgra8', 'r8', 'rgba8i', 'rgba8ui',
    'rgba16i', 'rg8', 'rgba32i', 'rgba32ui', 'rgba8', 'DXT1', 'r16', 'DXT5',
    'rg16', 'BC4s', 'rgba16', 'BC5s', 'r16f', 'BC6hs', 'BC7', 'PVR1rgb2',
    'rg16f', 'PVR1rgba2', 'rgba16f', 'ETC1', 'r32f', 'ETC2rgba', 'rg32f',
    'EACr', 'rgba32f', 'EACrg', 'rgba4', 'ASTC4x4', 'ASTC5x4', 'rgb5a1',
    'ASTC6x5', 'rgb565', 'ASTC8x5', 'ASTC8x6', 'rgb10a2', 'ASTC10x5',
    'rg11b10f', 'ASTC10x8', 'ASTC10x10', 'ASTC12x10', 'ASTC12x12', 'normal',
    'srgba8', 'la8', 'ASTC10x6', 'ASTC8x8', 'ASTC6x6', 'ASTC5x5', 'EACrgs',
    'EACrs', 'ETC2rgba1', 'ETC2rgb', 'PVR1rgba4', 'PVR1rgb4', 'BC6h',
    'BC5', 'BC4', 'DXT3', 'rgba16ui', 'bgra8srgb',
    'depth16', 'depth24', 'depth32f', 'depth24stencil8', 'depth32fstencil8', 'stencil8'
  }
  local supported = love.graphics.get_texture_formats({ canvas = true })
  test:assert_not_nil(supported)
  for f=1,#formats do
    test:assert_not_equals(nil, supported[formats[f] ], 'expected a key for format: ' .. formats[f])
  end
end


-- love.graphics.get_renderer_info
-- @NOTE hardware dependent so best can do is nil checking
love.test.graphics.get_renderer_info = function(test)
  local name, version, vendor, device = love.graphics.get_renderer_info()
  test:assert_not_nil(name)
  test:assert_not_nil(version)
  test:assert_not_nil(vendor)
  test:assert_not_nil(device)
end


-- love.graphics.get_stats
-- @NOTE cant really predict some of these so just nil check for most
love.test.graphics.get_stats = function(test)
  local stattypes = {
    'drawcalls', 'canvasswitches', 'texturememory', 'shaderswitches',
    'drawcallsbatched', 'textures', 'fonts'
  }
  local stats = love.graphics.get_stats()
  for s=1,#stattypes do
    test:assert_not_equals(nil, stats[stattypes[s] ], 'expected a key for stat: ' .. stattypes[s])
  end
end


-- love.graphics.get_supported
love.test.graphics.get_supported = function(test)
  -- cant check values as hardware dependent but we can check the keys in the 
  -- table match what the documentation lists
  local gfs = {
    'clampzero', 'lighten', 'glsl3', 'instancing', 'fullnpot', 
    'pixelshaderhighp', 'shaderderivatives', 'indirectdraw',
    'copytexturetobuffer', 'multicanvasformats', 
    'clampone', 'glsl4'
  }
  local features = love.graphics.get_supported()
  for g=1,#gfs do
    test:assert_not_equals(nil, features[gfs[g] ], 'expected a key for graphic feature: ' .. gfs[g])
  end
end


-- love.graphics.get_system_limits
love.test.graphics.get_system_limits = function(test)
  -- cant check values as hardware dependent but we can check the keys in the 
  -- table match what the documentation lists
  local glimits = {
    'texelbuffersize', 'shaderstoragebuffersize', 'threadgroupsx', 
    'threadgroupsy', 'pointsize', 'texturesize', 'texturelayers', 'volumetexturesize',
    'cubetexturesize', 'anisotropy', 'texturemsaa', 'multicanvas', 'threadgroupsz'
  }
  local limits = love.graphics.get_system_limits()
  for g=1,#glimits do
    test:assert_not_equals(nil, limits[glimits[g] ], 'expected a key for system limit: ' .. glimits[g])
  end
end


-- love.graphics.get_texture_types
love.test.graphics.get_texture_types = function(test)
  -- cant check values as hardware dependent but we can check the keys in the 
  -- table match what the documentation lists
  local ttypes = {
    '2d', 'array', 'cube', 'volume'
  }
  local types = love.graphics.get_texture_types()
  for t=1,#ttypes do
    test:assert_not_equals(nil, types[ttypes[t] ], 'expected a key for texture type: ' .. ttypes[t])
  end
end

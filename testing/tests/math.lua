-- love.math


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------OBJECTS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- BezierCurve (love.math.new_bezier_curve)
love.test.math.BezierCurve = function(test)

  -- create obj
  local curve = love.math.new_bezier_curve(1, 1, 2, 2, 3, 1)
  local px, py = curve:get_control_point(2)
  test:assert_object(curve)

  -- check initial properties
  test:assert_coords({2, 2}, {px, py}, 'check point x/y')
  test:assert_equals(3, curve:get_control_point_count(), 'check 3 points')
  test:assert_equals(2, curve:get_degree(), 'check degree is points-1')

  -- check some values on the curve
  test:assert_equals(1, curve:evaluate(0), 'check curve evaluation 0')
  test:assert_range(curve:evaluate(0.1), 1.2, 1.3, 'check curve evaluation 0.1')
  test:assert_range(curve:evaluate(0.2), 1.4, 1.5, 'check curve evaluation 0.2')
  test:assert_range(curve:evaluate(0.5), 2, 2.1, 'check curve evaluation 0.5')
  test:assert_equals(3, curve:evaluate(1), 'check curve evaluation 1')

  -- check derivative
  local deriv = curve:get_derivative()
  test:assert_object(deriv)
  test:assert_equals(2, deriv:get_control_point_count(), 'check deriv points')
  test:assert_range(deriv:evaluate(0.1), 2, 2.1, 'check deriv evaluation 0.1')

  -- check segment
  local segment = curve:get_segment(0, 0.5)
  test:assert_object(segment)
  test:assert_equals(3, segment:get_control_point_count(), 'check segment points')
  test:assert_range(segment:evaluate(0.1), 1, 1.1, 'check segment evaluation 0.1')

  -- mess with control points
  curve:remove_control_point(2)
  curve:insert_control_point(4, 1, -1)
  curve:insert_control_point(5, 3, -1)
  curve:insert_control_point(6, 2, -1)
  curve:set_control_point(2, 3, 2)
  test:assert_equals(5, curve:get_control_point_count(), 'check 3 points still')
  local px1, py1 = curve:get_control_point(1)
  local px2, py2 = curve:get_control_point(3)
  local px3, py3 = curve:get_control_point(5)
  test:assert_coords({1, 1}, {px1, py1}, 'check modified point 1')
  test:assert_coords({5, 3}, {px2, py2}, 'check modified point 1')
  test:assert_coords({3, 1}, {px3, py3}, 'check modified point 1')

  -- check render lists
  local coords1 = curve:render(5)
  local coords2 = curve:render_segment(0, 0.1, 5)
  test:assert_equals(196, #coords1, 'check coords')
  test:assert_equals(20, #coords2, 'check segment coords')

  -- check translation values
  px, py = curve:get_control_point(2)
  test:assert_coords({3, 2}, {px, py}, 'check pretransform x/y')
  curve:rotate(90 * (math.pi/180), 0, 0)
  px, py = curve:get_control_point(2)
  test:assert_coords({-2, 3}, {px, py}, 'check rotated x/y')
  curve:scale(2, 0, 0)
  px, py = curve:get_control_point(2)
  test:assert_coords({-4, 6}, {px, py}, 'check scaled x/y')
  curve:translate(5, -5)
  px, py = curve:get_control_point(2)
  test:assert_coords({1, 1}, {px, py}, 'check translated x/y')

end


-- RandomGenerator (love.math.RandomGenerator)
-- @NOTE as this checks random numbers the chances this fails is very unlikely, but not 0...
-- if you've managed to proc it congrats! your prize is to rerun the testsuite again
love.test.math.RandomGenerator = function(test)

  -- create object
  local rng1 = love.math.new_random_generator(3418323524, 20529293)
  test:assert_object(rng1)

  -- check set properties
  local low, high = rng1:get_seed()
  test:assert_equals(3418323524, low, 'check seed low')
  test:assert_equals(20529293, high, 'check seed high')

  -- check states
  local rng2 = love.math.new_random_generator(1448323524, 10329293)
  test:assert_not_equals(rng1:random(), rng2:random(), 'check not matching states')
  test:assert_not_equals(rng1:random_normal(), rng2:random_normal(), 'check not matching states')

  -- check setting state works
  rng2:set_state(rng1:get_state())
  test:assert_equals(rng1:random(), rng2:random(), 'check now matching')

  -- check overwriting seed works, should change output
  rng1:set_seed(os.time())
  test:assert_not_equals(rng1:random(), rng2:random(), 'check not matching states')
  test:assert_not_equals(rng1:random_normal(), rng2:random_normal(), 'check not matching states')

end


-- Transform (love.math.Transform)
love.test.math.Transform = function(test)

  -- create obj
  local transform = love.math.new_transform(0, 0, 0, 1, 1, 0, 0, 0, 0)
  test:assert_object(transform)

  -- set some values and check the matrix and transformPoint values
  transform:translate(10, 8)
  transform:scale(2, 3)
  transform:rotate(90*(math.pi/180))
  transform:shear(1, 2)
  local px, py = transform:transform_point(1, 1)
  test:assert_coords({4, 14}, {px, py}, 'check transformation methods')
  transform:reset()
  px, py = transform:transform_point(1, 1)
  test:assert_coords({1, 1}, {px, py}, 'check reset')

  -- apply a transform to another transform
  local transform2 = love.math.new_transform()
  transform2:translate(5, 3)
  transform:apply(transform2)
  px, py = transform:transform_point(1, 1)
  test:assert_coords({6, 4}, {px, py}, 'check apply other transform')

  -- check cloning a transform
  local transform3 = transform:clone()
  px, py = transform3:transform_point(1, 1)
  test:assert_coords({6, 4}, {px, py}, 'check clone transform')

  -- check inverse and inverseTransform
  transform:reset()
  transform:translate(-14, 6)
  local ipx, ipy = transform:inverse_transform_point(0, 0)
  transform:inverse()
  px, py = transform:transform_point(0, 0)
  test:assert_coords({-px, -py}, {ipx, ipy}, 'check inverse points transform')

  -- check matrix manipulation
  transform:set_transformation(0, 0, 0, 1, 1, 0, 0, 0, 0)
  transform:translate(4, 4)
  local m1, m2, m3, m4, m5, m6, m7, m8, 
    m9, m10, m11, m12, m13, m14, m15, m16 = transform:get_matrix()
  test:assert_equals(4, m4, 'check translate matrix x')
  test:assert_equals(4, m8, 'check translate matrix y')
  transform:set_matrix(m1, m2, m3, 3, m5, m6, m7, 1, m9, m10, m11, m12, m13, m14, m15, m16)
  px, py = transform:transform_point(1, 1)
  test:assert_coords({4, 2}, {px, py}, 'check set matrix')

  -- check affine vs non affine
  transform:reset()
  test:assert_true(transform:is_affine2_d_transform(), 'check affine 1')
  transform:translate(4, 3)
  test:assert_true(transform:is_affine2_d_transform(), 'check affine 2')
  transform:set_matrix(1, 3, 4, 5.5, 1, 4.5, 2, 1, 3.4, 5.1, 4.1, 13, 1, 1, 2, 3)
  test:assert_false(transform:is_affine2_d_transform(), 'check not affine')

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.math.color_from_bytes
love.test.math.color_from_bytes = function(test)
  -- check random value
  local r1, g1, b1, a1 = love.math.color_from_bytes(51, 51, 51, 51)
  test:assert_equals(r1, 0.2, 'check r from bytes')
  test:assert_equals(g1, 0.2, 'check g from bytes')
  test:assert_equals(b1, 0.2, 'check b from bytes')
  test:assert_equals(a1, 0.2, 'check a from bytes')
  -- check "max" value
  local r2, g2, b2, a2 = love.math.color_from_bytes(255, 255, 255, 255)
  test:assert_equals(r2, 1, 'check r from bytes')
  test:assert_equals(g2, 1, 'check g from bytes')
  test:assert_equals(b2, 1, 'check b from bytes')
  test:assert_equals(a2, 1, 'check a from bytes')
  -- check "min" value
  local r3, g3, b3, a3 = love.math.color_from_bytes(0, 0, 0, 0)
  test:assert_equals(r3, 0, 'check r from bytes')
  test:assert_equals(g3, 0, 'check g from bytes')
  test:assert_equals(b3, 0, 'check b from bytes')
  test:assert_equals(a3, 0, 'check a from bytes')
end


-- love.math.color_to_bytes
love.test.math.color_to_bytes = function(test)
  -- check random value
  local r1, g1, b1, a1 = love.math.color_to_bytes(0.2, 0.2, 0.2, 0.2)
  test:assert_equals(r1, 51, 'check bytes from r')
  test:assert_equals(g1, 51, 'check bytes from g')
  test:assert_equals(b1, 51, 'check bytes from b')
  test:assert_equals(a1, 51, 'check bytes from a')
  -- check "max" value
  local r2, g2, b2, a2 = love.math.color_to_bytes(1, 1, 1, 1)
  test:assert_equals(r2, 255, 'check bytes from r')
  test:assert_equals(g2, 255, 'check bytes from g')
  test:assert_equals(b2, 255, 'check bytes from b')
  test:assert_equals(a2, 255, 'check bytes from a')
  -- check "min" value
  local r3, g3, b3, a3 = love.math.color_to_bytes(0, 0, 0, 0)
  test:assert_equals(r3, 0, 'check bytes from r')
  test:assert_equals(g3, 0, 'check bytes from g')
  test:assert_equals(b3, 0, 'check bytes from b')
  test:assert_equals(a3, 0, 'check bytes from a')
end


-- love.math.gamma_to_linear
-- @NOTE I tried doing the same formula as the source from MathModule.cpp
-- but get test failues due to slight differences
love.test.math.gamma_to_linear = function(test)
  local lr, lg, lb = love.math.gamma_to_linear(1, 0.8, 0.02)
  --local eg = ((0.8 + 0.055) / 1.055)^2.4
  --local eb = 0.02 / 12.92
  test:assert_greater_equal(0, lr, 'check gamma r to linear')
  test:assert_greater_equal(0, lg, 'check gamma g to linear')
  test:assert_greater_equal(0, lb, 'check gamma b to linear')
end


-- love.math.get_random_seed
-- @NOTE whenever i run this high is always 0, is that intended?
love.test.math.get_random_seed = function(test)
  local low, high = love.math.get_random_seed()
  test:assert_greater_equal(0, low, 'check random seed low')
  test:assert_greater_equal(0, high, 'check random seed high')
end


-- love.math.get_random_state
love.test.math.get_random_state = function(test)
  test:assert_not_nil(love.math.get_random_state())
end


-- love.math.is_convex
love.test.math.is_convex = function(test)
  local isconvex = love.math.is_convex({0, 0, 1, 0, 1, 1, 1, 0, 0, 0}) -- square
  local notconvex = love.math.is_convex({1, 2, 2, 4, 3, 4, 2, 1, 3, 1}) -- weird shape
  test:assert_true(isconvex, 'check polygon convex')
  test:assert_false(notconvex, 'check polygon not convex')
end


-- love.math.linear_to_gammer
-- @NOTE I tried doing the same formula as the source from MathModule.cpp
-- but get test failues due to slight differences
love.test.math.linear_to_gamma = function(test)
  local gr, gg, gb = love.math.linear_to_gamma(1, 0.8, 0.001)
  --local eg = 1.055 * (0.8^1/2.4) - 0.055
  --local eb = 0.001 * 12.92
  test:assert_greater_equal(0, gr, 'check linear r to gamme')
  test:assert_greater_equal(0, gg, 'check linear g to gamme')
  test:assert_greater_equal(0, gb, 'check linear b to gamme')
end


-- love.math.new_bezier_curve
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.math.new_bezier_curve = function(test)
  test:assert_object(love.math.new_bezier_curve({0, 0, 0, 1, 1, 1, 2, 1}))
end


-- love.math.new_random_generator
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.math.new_random_generator = function(test)
  test:assert_object(love.math.new_random_generator())
end


-- love.math.new_transform
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.math.new_transform = function(test)
  test:assert_object(love.math.new_transform())
end


-- love.math.perlin_noise
love.test.math.perlin_noise = function(test)
  -- check some noise values
  -- output should be consistent if given the same input
  local noise1 = love.math.perlin_noise(100)
  local noise2 = love.math.perlin_noise(1, 10)
  local noise3 = love.math.perlin_noise(1043, 31.123, 999)
  local noise4 = love.math.perlin_noise(99.222, 10067, 8, 1843)
  test:assert_range(noise1, 0.5, 0.51, 'check noise 1 dimension')
  test:assert_range(noise2, 0.5, 0.51, 'check noise 2 dimensions')
  test:assert_range(noise3, 0.56, 0.57, 'check noise 3 dimensions')
  test:assert_range(noise4, 0.52, 0.53, 'check noise 4 dimensions')
end


-- love.math.simplex_noise
love.test.math.simplex_noise = function(test)
  -- check some noise values
  -- output should be consistent if given the same input
  local noise1 = love.math.simplex_noise(100)
  local noise2 = love.math.simplex_noise(1, 10)
  local noise3 = love.math.simplex_noise(1043, 31.123, 999)
  local noise4 = love.math.simplex_noise(99.222, 10067, 8, 1843)
  -- rounded to avoid floating point issues 
  test:assert_range(noise1, 0.5, 0.51, 'check noise 1 dimension')
  test:assert_range(noise2, 0.47, 0.48, 'check noise 2 dimensions')
  test:assert_range(noise3, 0.26, 0.27, 'check noise 3 dimensions')
  test:assert_range(noise4, 0.53, 0.54, 'check noise 4 dimensions')
end


-- love.math.random
love.test.math.random = function(test)
  -- check some random ranges
  love.math.set_random_seed(123)
  test:assert_range(love.math.random(), 0.37068322251462, 0.37068322251464, "check random algorithm")
  test:assert_equals(love.math.random(10), 4, "check single random param")
  test:assert_equals(love.math.random(15, 100), 92, "check two random params")
end


-- love.math.random_normal
love.test.math.random_normal = function(test)
  love.math.set_random_seed(1234)
  test:assert_range(love.math.random_normal(1, 2), 1.0813614997253, 1.0813614997255, 'check randomNormal two params')
end


-- love.math.set_random_seed
-- @NOTE same with getRandomSeed, high is always 0 when I tested it?
love.test.math.set_random_seed = function(test)
  love.math.set_random_seed(9001)
  local low, high = love.math.get_random_seed()
  test:assert_equals(9001, low, 'check seed low set')
  test:assert_equals(0, high, 'check seed high set')
end


-- love.math.set_random_state
love.test.math.set_random_state = function(test)
  -- check setting state matches value returned
  local rs1 = love.math.get_random_state()
  love.math.set_random_state(rs1)
  local rs2 = love.math.get_random_state()
  test:assert_equals(rs1, rs2, 'check random state set')
end


-- love.math.triangulate
love.test.math.triangulate = function(test)
  local triangles1 = love.math.triangulate({0, 0, 1, 0, 1, 1, 1, 0, 0, 0}) -- square
  local triangles2 = love.math.triangulate({1, 2, 2, 4, 3, 4, 2, 1, 3, 1}) -- weird shape
  test:assert_equals(3, #triangles1, 'check polygon triangles')
  test:assert_equals(3, #triangles2, 'check polygon triangles')
end

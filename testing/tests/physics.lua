-- love.physics


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
----------------------------------OBJECTS---------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- Body (love.physics.new_body)
love.test.physics.Body = function(test)

  -- create body
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 0, 0, 'static')
  local body2 = love.physics.new_body(world, 30, 30, 'dynamic')
  love.physics.new_rectangle_shape(body1, 5, 5, 10, 10)
  love.physics.new_rectangle_shape(body2, 5, 5, 10, 10)
  test:assert_object(body1)

  -- check shapes
  test:assert_equals(1, #body1:get_shapes(), 'check shapes total 1')
  test:assert_equals(1, #body2:get_shapes(), 'check shapes total 2')
  test:assert_not_equals(nil, body1:get_shape(), 'check shape 1')
  test:assert_not_equals(nil, body2:get_shape(), 'check shape 2')

  -- check body active
  test:assert_true(body1:is_active(), 'check active by def')

  -- check body bullet
  test:assert_false(body1:is_bullet(), 'check not bullet by def')
  body1:set_bullet(true)
  test:assert_true(body1:is_bullet(), 'check set bullet')

  -- check fixed rotation
  test:assert_false(body1:is_fixed_rotation(), 'check fix rot def')
  body1:set_fixed_rotation(true)
  test:assert_true(body1:is_fixed_rotation(), 'check set fix rot')

  -- check sleeping/waking
  test:assert_true(body1:is_sleeping_allowed(), 'check sleep def')
  body1:set_sleeping_allowed(false)
  test:assert_false(body1:is_sleeping_allowed(), 'check set sleep')
  body1:set_sleeping_allowed(true)
  world:update(1)
  test:assert_false(body1:is_awake(), 'check fell asleep')
  body1:set_sleeping_allowed(false)
  body1:set_type('dynamic')
  test:assert_true(body1:is_awake(), 'check waking up')

  -- check touching
  test:assert_false(body1:is_touching(body2))
  body2:set_position(5, 5)
  world:update(1)
  test:assert_true(body1:is_touching(body2))

  -- check children lists
  test:assert_equals(1, #body1:get_contacts(), 'check contact list')
  test:assert_equals(0, #body1:get_joints(), 'check joints list')
  love.physics.new_distance_joint(body1, body2, 5, 5, 10, 10, true)
  test:assert_equals(1, #body1:get_joints(), 'check joints list')

  -- check local points
  local x, y = body1:get_local_center()
  test:assert_range(x, 5, 6, 'check local center x')
  test:assert_range(y, 5, 6, 'check local center y')
  local lx, ly = body1:get_local_point(10, 10)
  test:assert_range(lx, 10, 11, 'check local point x')
  test:assert_range(ly, 9, 10, 'check local point y')
  local lx1, ly1, lx2, ly2 = body1:get_local_points(0, 5, 5, 10)
  test:assert_range(lx1, 0, 1, 'check local points x 1')
  test:assert_range(ly1, 3, 4, 'check local points y 1')
  test:assert_range(lx2, 5, 6, 'check local points x 2')
  test:assert_range(ly2, 9, 10, 'check local points y 2')

  -- check world points
  local wx, wy = body1:get_world_point(10.4, 9)
  test:assert_range(wx, 10, 11, 'check world point x')
  test:assert_range(wy, 10, 11, 'check world point y')
  local wx1, wy1, wx2, wy2 = body1:get_world_points(0.4, 4, 5.4, 9)
  test:assert_range(wx1, 0, 1, 'check world points x 1')
  test:assert_range(wy1, 5, 6, 'check world points y 1')
  test:assert_range(wx2, 5, 6, 'check world points x 2')
  test:assert_range(wy2, 10, 11, 'check world points y 2')

  -- check angular damping + velocity
  test:assert_equals(0, body1:get_angular_damping(), 'check angular damping')
  test:assert_equals(0, body1:get_angular_velocity(), 'check angular velocity')

  -- check world props
  test:assert_object(body1:get_world())
  test:assert_equals(2, body1:get_world():getBodyCount(), 'check world count')
  local cx, cy = body1:get_world_center()
  test:assert_range(cx, 4, 5, 'check world center x')
  test:assert_range(cy, 6, 7, 'check world center y')
  local vx, vy = body1:get_world_vector(5, 10)
  test:assert_equals(5, vx, 'check vector x')
  test:assert_equals(10, vy, 'check vector y')

  -- check inertia
  test:assert_range(body1:get_inertia(), 5, 6, 'check inertia')

  -- check angle
  test:assert_equals(0, body1:get_angle(), 'check def angle')
  body1:set_angle(90 * (math.pi/180))
  test:assert_equals(math.floor(math.pi/2*100), math.floor(body1:get_angle()*100), 'check set angle')

  -- check gravity scale
  test:assert_equals(1, body1:get_gravity_scale(), 'check def grav')
  body1:set_gravity_scale(2)
  test:assert_equals(2, body1:get_gravity_scale(), 'check change grav')

  -- check damping
  test:assert_equals(0, body1:get_linear_damping(), 'check def lin damping')
  body1:set_linear_damping(0.1)
  test:assert_range(body1:get_linear_damping(), 0, 0.2, 'check change lin damping')

  -- check velocity
  local x2, y2 = body1:get_linear_velocity()
  test:assert_equals(1, x2, 'check def lin velocity x')
  test:assert_equals(1, y2, 'check def lin velocity y')
  body1:set_linear_velocity(4, 5)
  local x3, y3 = body1:get_linear_velocity()
  test:assert_equals(4, x3, 'check change lin velocity x')
  test:assert_equals(5, y3, 'check change lin velocity y')

  -- check mass 
  test:assert_range(body1:get_mass(), 0.1, 0.2, 'check def mass')
  body1:set_mass(10)
  test:assert_equals(10, body1:get_mass(), 'check change mass')
  body1:set_mass_data(3, 5, 10, 1)
  local x4, y4, mass4, inertia4 = body1:get_mass_data()
  test:assert_equals(3, x4, 'check mass data change x')
  test:assert_equals(5, y4, 'check mass data change y')
  test:assert_equals(10, mass4, 'check mass data change mass')
  test:assert_range(inertia4, 340, 341, 'check mass data change inertia')
  body1:reset_mass_data()
  local x5, y5, mass5, inertia5 = body1:get_mass_data()
  test:assert_range(x5, 5, 6, 'check mass data reset x')
  test:assert_range(y5, 5, 6, 'check mass data reset y')
  test:assert_range(mass5, 0.1, 0.2, 'check mass data reset mass')
  test:assert_range(inertia5, 5, 6, 'check mass data reset inertia')
  test:assert_false(body1:has_custom_mass_data())

  -- check position
  local x6, y6 = body1:get_position()
  test:assert_range(x6, -1, 0, 'check position x')
  test:assert_range(y6, 0, 1, 'check position y')
  body1:set_position(10, 4)
  local x7, y7 = body1:get_position()
  test:assert_equals(x7, 10, 'check set position x')
  test:assert_equals(y7, 4, 'check set position y')

  -- check type
  test:assert_equals('dynamic', body1:get_type(), 'check type match')
  body1:set_type('kinematic')
  body1:set_type('static')
  test:assert_equals('static', body1:get_type(), 'check type change')

  -- check userdata
  test:assert_equals(nil, body1:get_user_data(), 'check user data')
  body1:set_user_data({ love = 'cool' })
  test:assert_equals('cool', body1:get_user_data().love, 'check set user data')

  -- check x/y direct
  test:assert_equals(10, math.floor(body1:get_x()), 'check get x')
  test:assert_equals(4, math.floor(body1:get_y()), 'check get y')
  body1:set_x(0)
  body1:set_y(0)
  test:assert_equals(0, body1:get_x(), 'check get x')
  test:assert_equals(0, body1:get_y(), 'check get y')

  -- apply angular impulse
  local vel = body2:get_angular_velocity()
  test:assert_range(vel, 0, 0, 'check velocity before')
  body2:apply_angular_impulse(10)
  local vel1 = body2:get_angular_velocity()
  test:assert_range(vel1, 5, 6, 'check velocity after 1')

  -- apply standard force
  local ang1 = body2:get_angle()
  test:assert_range(ang1, 0.1, 0.2, 'check initial angle 1')
  body2:apply_force(2, 3)
  world:update(2)
  local vel2 = body2:get_angular_velocity()
  local ang2 = body2:get_angle()
  test:assert_range(ang2, -0.1, 0, 'check angle after 2')
  test:assert_range(vel2, 1, 2, 'check velocity after 2')

  -- apply linear impulse
  body2:apply_linear_impulse(-4, -59)
  world:update(1)
  local ang3 = body2:get_angle()
  local vel3 = body2:get_angular_velocity()
  test:assert_range(ang3, -2, -1, 'check angle after 3')
  test:assert_range(vel3, 0, 1, 'check velocity after 3')

  -- apply torque
  body2:apply_torque(4)
  world:update(2)
  local ang4 = body2:get_angle()
  local vel4 = body2:get_angular_velocity()
  test:assert_range(ang4, -1, 0, 'check angle after 4')
  test:assert_range(vel4, 0, 1, 'check velocity after 4')

  -- check destroy
  test:assert_false(body1:is_destroyed(), 'check not destroyed')
  body1:destroy()
  test:assert_true(body1:is_destroyed(), 'check destroyed')

end


-- Contact (love.physics.World:get_contacts)
love.test.physics.Contact = function(test)

  -- create a setup so we can access some contact objects
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 0, 0, 'dynamic')
  local body2 = love.physics.new_body(world, 10, 10, 'dynamic')
  local rectangle1 = love.physics.new_rectangle_shape(body1, 0, 0, 10, 10)
  local rectangle2 = love.physics.new_rectangle_shape(body2, 0, 0, 10, 10)
  rectangle1:set_user_data('rec1')
  rectangle2:set_user_data('rec2')

  -- used to check for collisions + no. of collisions
  local collided = false
  local pass = 1

  -- set callback for contact start 
  world:set_callbacks(
    function(shape_a, shape_b, contact)
      collided = true

      -- check contact object
      test:assert_object(contact)

      -- check child indices
      local indexA, indexB = contact:get_children()
      test:assert_equals(1, indexA, 'check child indice a')
      test:assert_equals(1, indexB, 'check child indice b')

      -- check shapes match using userdata
      local shapeA, shapeB = contact:get_shapes()
      test:assert_equals(shape_a:get_user_data(), shapeA:get_user_data(), 'check shape a matches')
      test:assert_equals(shape_b:get_user_data(), shapeB:get_user_data(), 'check shape b matches')

      -- check normal pos
      local nx, ny = contact:get_normal()
      test:assert_equals(1, nx, 'check normal x')
      test:assert_equals(0, ny, 'check normal y')

      -- check actual pos
      local px1, py1, px2, py2 = contact:get_positions()
      test:assert_range(px1, 5, 6, 'check collide x 1')
      test:assert_range(py1, 5, 6, 'check collide y 1')
      test:assert_range(px2, 5, 6, 'check collide x 2')
      test:assert_range(py2, 5, 6, 'check collide y 2')

      -- check touching
      test:assert_true(contact:is_touching(), 'check touching')

      -- check enabled (we pass through twice to test on/off)
      test:assert_equals(pass == 1, contact:is_enabled(), 'check enabled for pass ' .. tostring(pass))

      -- check friction
      test:assert_range(contact:get_friction(), 0.2, 0.3, 'check def friction')
      contact:set_friction(0.1)
      test:assert_range(contact:get_friction(), 0.1, 0.2, 'check set friction')
      contact:reset_friction()
      test:assert_range(contact:get_friction(), 0.2, 0.3, 'check reset friction')

      -- check restitution
      test:assert_equals(0, contact:get_restitution(), 'check def restitution')
      contact:set_restitution(1)
      test:assert_equals(1, contact:get_restitution(), 'check set restitution')
      contact:reset_restitution()
      test:assert_equals(0, contact:get_restitution(), 'check reset restitution')
      pass = pass + 1

    end, function() end, function(shape_a, shape_b, contact) 
      if pass > 2 then
        contact:set_enabled(false)
      end
    end, function() end
  )

  -- check bodies collided
  world:update(1)
  test:assert_true(collided, 'check bodies collided')

  -- update again for enabled check
  world:update(1)
  test:assert_equals(2, pass, 'check ran twice')

end


-- Joint (love.physics.new_distance_joint)
love.test.physics.Joint = function(test)

  -- make joint
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 10, 10, 'dynamic')
  local body2 = love.physics.new_body(world, 20, 20, 'dynamic')
  local joint = love.physics.new_distance_joint(body1, body2, 10, 10, 20, 20, true)
  test:assert_object(joint)

  -- check type
  test:assert_equals('distance', joint:get_type(), 'check joint type')

  -- check not destroyed
  test:assert_false(joint:is_destroyed(), 'check not destroyed')


  -- check reaction props
  world:update(1)
  local rx1, ry1 = joint:get_reaction_force(1)
  test:assert_equals(0, rx1, 'check reaction force x')
  test:assert_equals(0, ry1, 'check reaction force y')
  local rx2, ry2 = joint:get_reaction_torque(1)
  test:assert_equals(0, rx2, 'check reaction torque x')
  test:assert_equals(nil, ry2, 'check reaction torque y')

  -- check body pointer
  local b1, b2 = joint:get_bodies()
  test:assert_equals(body1:get_x(), b1:get_x(), 'check body 1')
  test:assert_equals(body2:get_x(), b2:get_x(), 'check body 2')

  -- check joint anchors
  local x1, y1, x2, y2 = joint:get_anchors()
  test:assert_range(x1, 10, 11, 'check anchor x1')
  test:assert_range(y1, 10, 11, 'check anchor y1')
  test:assert_range(x2, 20, 21, 'check anchor x2')
  test:assert_range(y2, 20, 21, 'check anchor y2')
  test:assert_true(joint:get_collide_connected(), 'check not colliding')

  -- test userdata
  test:assert_equals(nil, joint:get_user_data(), 'check no data by def')
  joint:set_user_data('hello')
  test:assert_equals('hello', joint:get_user_data(), 'check set userdata')

  -- destroy
  joint:destroy()
  test:assert_true(joint:is_destroyed(), 'check destroyed')

end


-- Shape (love.physics.new_circle_shape)
-- @NOTE in 12.0 fixtures have been merged into shapes
love.test.physics.Shape = function(test)

  -- create shape
  local world = love.physics.new_world(0, 0, false)
  local body1 = love.physics.new_body(world, 0, 0, 'dynamic')
  local shape1 = love.physics.new_rectangle_shape(body1, 5, 5, 10, 10)
  test:assert_object(shape1)

  -- check child count
  test:assert_equals(1, shape1:get_child_count(), 'check child count')

  -- check radius
  test:assert_range(shape1:get_radius(), 0, 0.4, 'check radius')

  -- check type match
  test:assert_equals('polygon', shape1:get_type(), 'check rectangle type')

  -- check body pointer
  test:assert_equals(0, shape1:get_body():getX(), 'check body link')

  -- check category 
  test:assert_equals(1, shape1:get_category(), 'check def category')
  shape1:set_category(3, 5, 6)
  local categories = {shape1:get_category()}
  test:assert_equals(14, categories[1] + categories[2] + categories[3], 'check set category')

  -- check sensor prop
  test:assert_false(shape1:is_sensor(), 'check sensor def')
  shape1:set_sensor(true)
  test:assert_true(shape1:is_sensor(), 'check set sensor')
  shape1:set_sensor(false)

  -- check not destroyed
  test:assert_false(shape1:is_destroyed(), 'check not destroyed')

  -- check user data
  test:assert_equals(nil, shape1:get_user_data(), 'check no user data')
  shape1:set_user_data({ test = 14 })
  test:assert_equals(14, shape1:get_user_data().test, 'check user data set')

  -- check bounding box
  -- polygons have an additional skin radius to help with collisions
  -- so this wont be 0, 0, 10, 10 as you'd think but has an additional 0.3 padding
  local topLeftX, topLeftY, bottomRightX, bottomRightY = shape1:compute_aabb(0, 0, 0, 1)
  local tlx, tly, brx, bry = shape1:get_bounding_box(1)
  test:assert_equals(topLeftX, tlx, 'check bbox methods match tlx')
  test:assert_equals(topLeftY, tly, 'check bbox methods match tly')
  test:assert_equals(bottomRightX, brx, 'check bbox methods match brx')
  test:assert_equals(bottomRightY, bry, 'check bbox methods match bry')
  test:assert_equals(topLeftX, topLeftY, 'check bbox tl 1')
  test:assert_range(topLeftY, -0.3, -0.2, 'check bbox tl 2')
  test:assert_equals(bottomRightX, bottomRightY, 'check bbox br 1')
  test:assert_range(bottomRightX, 10.3, 10.4, 'check bbox br 2')

  -- check density
  test:assert_equals(1, shape1:get_density(), 'check def density')
  shape1:set_density(5)
  test:assert_equals(5, shape1:get_density(), 'check set density')

  -- check mass
  local x1, y1, mass1, inertia1 = shape1:get_mass_data()
  test:assert_range(x1, 5, 5.1, 'check shape mass pos x')
  test:assert_range(y1, 5, 5.1, 'check shape mass pos y')
  test:assert_range(mass1, 0.5, 0.6, 'check mass at 1 density')
  test:assert_range(inertia1, 0, 0.1, 'check intertia at 1 density')
  local x2, y2, mass2, inertia2 = shape1:compute_mass(1000)
  test:assert_range(mass2, 111, 112, 'check mass at 1000 density')
  test:assert_range(inertia2, 7407, 7408, 'check intertia at 1000 density')

  -- check friction
  test:assert_range(shape1:get_friction(), 0.2, 0.3, 'check def friction')
  shape1:set_friction(1)
  test:assert_equals(1, shape1:get_friction(), 'check set friction')

  -- check restitution
  test:assert_equals(0, shape1:get_restitution(), 'check def restitution')
  shape1:set_restitution(0.5)
  test:assert_range(shape1:get_restitution(), 0.5, 0.6, 'check set restitution')

  -- check points
  local bodyp = love.physics.new_body(world, 0, 0, 'dynamic')
  local shape2 = love.physics.new_rectangle_shape(bodyp, 5, 5, 10, 10)
  test:assert_true(shape2:test_point(5, 5), 'check point 5,5')
  test:assert_true(shape2:test_point(10, 10, 0, 15, 15), 'check point 15,15 after translate 10,10')
  test:assert_false(shape2:test_point(5, 5, 90, 10, 10), 'check point 10,10 after translate 5,5,90')
  test:assert_false(shape2:test_point(10, 10, 90, 5, 5), 'check point 5,5 after translate 10,10,90')
  test:assert_false(shape2:test_point(15, 15), 'check point 15,15')

  -- check ray cast
  local xn1, yn1, fraction1 = shape2:ray_cast(-20, -20, 20, 20, 100, 0, 0, 0, 1)
  test:assert_not_equals(nil, xn1, 'check ray 1 x')
  test:assert_not_equals(nil, xn1, 'check ray 1 y')
  local xn2, yn2, fraction2 = shape2:ray_cast(10, 10, -150, -150, 100, 0, 0, 0, 1)
  test:assert_equals(nil, xn2, 'check ray 2 x')
  test:assert_equals(nil, yn2, 'check ray 2 y')

  -- check filtering
  test:assert_equals(nil, shape2:get_mask(), 'check no mask')
  shape2:set_mask(1, 2, 3)
  test:assert_equals(3, #{shape2:get_mask()}, 'check set mask')
  test:assert_equals(0, shape2:get_group_index(), 'check no index')
  shape2:set_group_index(-1)
  test:assert_equals(-1, shape2:get_group_index(), 'check set index')
  local cat, mask, group = shape2:get_filter_data()
  test:assert_equals(1, cat, 'check filter cat')
  test:assert_equals(65528, mask, 'check filter mask')
  test:assert_equals(-1, group, 'check filter group')

  -- check destroyed
  shape1:destroy()
  test:assert_true(shape1:is_destroyed(), 'check destroyed')
  shape2:destroy()

  -- run some collision checks using filters, setup new shapes 
  local body2 = love.physics.new_body(world, 5, 5, 'dynamic')
  local shape3 = love.physics.new_rectangle_shape(body1, 0, 0, 10, 10)
  local shape4 = love.physics.new_rectangle_shape(body2, 0, 0, 10, 10)
  local collisions = 0
  world:set_callbacks(
    function() collisions = collisions + 1 end,
    function() end,
    function() end,
    function() end
  )

  -- same positive group do collide
  shape3:set_group_index(1)
  shape4:set_group_index(1)
  world:update(1)
  test:assert_equals(1, collisions, 'check positive group collide')

  -- check negative group dont collide
  shape3:set_group_index(-1)
  shape4:set_group_index(-1)
  body2:set_position(20, 20); world:update(1); body2:set_position(0, 0); world:update(1)
  test:assert_equals(1, collisions, 'check negative group collide')

  -- check masks do collide
  shape3:set_group_index(0)
  shape4:set_group_index(0)
  shape3:set_category(2)
  shape4:set_mask(3)
  body2:set_position(20, 20); world:update(1); body2:set_position(0, 0); world:update(1)
  test:assert_equals(2, collisions, 'check mask collide')

  -- check masks not colliding
  shape3:set_category(2)
  shape4:set_mask(2, 4, 6)
  body2:set_position(20, 20); world:update(1); body2:set_position(0, 0); world:update(1)
  test:assert_equals(2, collisions, 'check mask not collide')

end


-- World (love.physics.new_world)
love.test.physics.World = function(test)

  -- create new world
  local world = love.physics.new_world(0, 0, false)
  local body1 = love.physics.new_body(world, 0, 0, 'dynamic')
  local rectangle1 = love.physics.new_rectangle_shape(body1, 0, 0, 10, 10)
  test:assert_object(world)

  -- check bodies in world
  test:assert_equals(1, #world:get_bodies(), 'check 1 body')
  test:assert_equals(0, world:get_bodies()[1]:getX(), 'check body prop x')
  test:assert_equals(0, world:get_bodies()[1]:getY(), 'check body prop y')
  world:translate_origin(-10, -10) -- check affects bodies
  test:assert_range(world:get_bodies()[1]:getX(), 9, 11, 'check body prop change x')
  test:assert_range(world:get_bodies()[1]:getY(), 9, 11, 'check body prop change y')
  test:assert_equals(1, world:get_body_count(), 'check 1 body count')

  -- check shapes in world
  test:assert_equals(1, #world:get_shapes_in_area(0, 0, 10, 10), 'check shapes in area #1')
  test:assert_equals(0, #world:get_shapes_in_area(20, 20, 30, 30), 'check shapes in area #1')

  -- check world status
  test:assert_false(world:is_locked(), 'check not updating')
  test:assert_false(world:is_sleeping_allowed(), 'check no sleep (till brooklyn)')
  world:set_sleeping_allowed(true)
  test:assert_true(world:is_sleeping_allowed(), 'check can sleep')

  -- check world objects
  test:assert_equals(0, #world:get_joints(), 'check no joints')
  test:assert_equals(0, world:get_joint_count(), 'check no joints count')
  test:assert_equals(0, world:get_gravity(), 'check def gravity')
  test:assert_equals(0, #world:get_contacts(), 'check no contacts')
  test:assert_equals(0, world:get_contact_count(), 'check no contact count')

  -- check callbacks are called
  local beginContact, endContact, preSolve, postSolve = world:get_callbacks()
  test:assert_equals(nil, beginContact, 'check no begin contact callback')
  test:assert_equals(nil, endContact, 'check no end contact callback')
  test:assert_equals(nil, preSolve, 'check no pre solve callback')
  test:assert_equals(nil, postSolve, 'check no post solve callback')
  local beginContactCheck = false
  local endContactCheck = false
  local preSolveCheck = false
  local postSolveCheck = false
  local collisions = 0
  world:set_callbacks(
    function() beginContactCheck = true; collisions = collisions + 1 end,
    function() endContactCheck = true end,
    function() preSolveCheck = true end,
    function() postSolveCheck = true end
  )

  -- setup so we can collide stuff to call the callbacks
  local body2 = love.physics.new_body(world, 10, 10, 'dynamic')
  local rectangle2 = love.physics.new_rectangle_shape(body2, 0, 0, 10, 10)
  test:assert_false(beginContactCheck, 'check world didnt update after adding body')
  world:update(1)
  test:assert_true(beginContactCheck, 'check contact start')
  test:assert_true(preSolveCheck, 'check pre solve')
  test:assert_true(postSolveCheck, 'check post solve')
  body2:set_position(100, 100)
  world:update(1)
  test:assert_true(endContactCheck, 'check contact end')

  -- check point checking
  local shapes = 0
  world:query_shapes_in_area(0, 0, 10, 10, function(x)
    shapes = shapes + 1
  end)
  test:assert_equals(1, shapes, 'check shapes in area')

  -- check raycast
  world:ray_cast(0, 0, 200, 200, function(x)
    shapes = shapes + 1
    return 1
  end)
  test:assert_equals(3, shapes, 'check shapes in raycast')
  test:assert_equals(world:ray_cast_closest(0, 0, 200, 200), rectangle1, 'check closest raycast')
  test:assert_not_equals(nil, world:ray_cast_any(0, 0, 200, 200), 'check any raycast')

  -- change collision logic
  test:assert_equals(nil, world:get_contact_filter(), 'check def filter')
  world:update(1)
  world:set_contact_filter(function(s1, s2)
    return false -- nothing collides
  end)
  body2:set_position(10, 10)
  world:update(1)
  test:assert_equals(1, collisions, 'check collision logic change')

  -- check gravity
  world:set_gravity(1, 1)
  test:assert_equals(1, world:get_gravity(), 'check grav change')

  -- check destruction
  test:assert_false(world:is_destroyed(), 'check not destroyed')
  world:destroy()
  test:assert_true(world:is_destroyed(), 'check world destroyed')

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------------------METHODS-------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


-- love.physics.get_distance
love.test.physics.get_distance = function(test)
  -- setup two fixtues to check
  local world = love.physics.new_world(0, 0, false)
  local body = love.physics.new_body(world, 10, 10, 'static')
  local shape1 = love.physics.new_edge_shape(body, 0, 0, 5, 5)
  local shape2 = love.physics.new_edge_shape(body, 10, 10, 15, 15)
  -- check distance between them
  test:assert_range(love.physics.get_distance(shape1, shape2), 6, 7, 'check distance matches')
end


-- love.physics.get_meter
love.test.physics.get_meter = function(test)
  -- check value set is returned
  love.physics.set_meter(30)
  test:assert_equals(30, love.physics.get_meter(), 'check meter matches')
end


-- love.physics.new_body
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_body = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body = love.physics.new_body(world, 10, 10, 'static')
  test:assert_object(body)
end


-- love.physics.new_chain_shape
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_chain_shape = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body = love.physics.new_body(world, 10, 10, 'static')
  test:assert_object(love.physics.new_chain_shape(body, true, 0, 0, 1, 0, 1, 1, 0, 1))
end


-- love.physics.new_circle_shape
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_circle_shape = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body = love.physics.new_body(world, 10, 10, 'static')
  test:assert_object(love.physics.new_circle_shape(body, 10))
end


-- love.physics.new_distance_joint
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_distance_joint = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 10, 10, 'static')
  local body2 = love.physics.new_body(world, 20, 20, 'static')
  local obj = love.physics.new_distance_joint(body1, body2, 10, 10, 20, 20, true)
  test:assert_object(obj)
end


-- love.physics.new_edge_shape
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_edge_shape = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body = love.physics.new_body(world, 10, 10, 'static')
  local obj = love.physics.new_edge_shape(body, 0, 0, 10, 10)
  test:assert_object(obj)
end


-- love.physics.new_friction_joint
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_friction_joint = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 10, 10, 'static')
  local body2 = love.physics.new_body(world, 20, 20, 'static')
  local obj = love.physics.new_friction_joint(body1, body2, 15, 15, true)
  test:assert_object(obj)
end


-- love.physics.new_gear_joint
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_gear_joint = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 10, 10, 'dynamic')
  local body2 = love.physics.new_body(world, 20, 20, 'dynamic')
  local body3 = love.physics.new_body(world, 30, 30, 'dynamic')
  local body4 = love.physics.new_body(world, 40, 40, 'dynamic')
  local joint1 = love.physics.new_prismatic_joint(body1, body2, 10, 10, 20, 20, true)
  local joint2 = love.physics.new_prismatic_joint(body3, body4, 30, 30, 40, 40, true)
  local obj = love.physics.new_gear_joint(joint1, joint2, 1, true)
  test:assert_object(obj)
end


-- love.physics.new_motor_joint
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_motor_joint = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 10, 10, 'static')
  local body2 = love.physics.new_body(world, 20, 20, 'static')
  local obj = love.physics.new_motor_joint(body1, body2, 1)
  test:assert_object(obj)
end


-- love.physics.new_mouse_joint
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_mouse_joint = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body = love.physics.new_body(world, 10, 10, 'static')
  local obj = love.physics.new_mouse_joint(body, 10, 10)
  test:assert_object(obj)
end


-- love.physics.new_polygon_shape
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_polygon_shape = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body = love.physics.new_body(world, 10, 10, 'static')
  local obj = love.physics.new_polygon_shape(body, {0, 0, 2, 3, 2, 1, 3, 1, 5, 1})
  test:assert_object(obj)
end


-- love.physics.new_prismatic_joint
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_prismatic_joint = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 10, 10, 'static')
  local body2 = love.physics.new_body(world, 20, 20, 'static')
  local obj = love.physics.new_prismatic_joint(body1, body2, 10, 10, 20, 20, true)
  test:assert_object(obj)
end


-- love.physics.new_pulley_joint
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_pulley_joint = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 10, 10, 'static')
  local body2 = love.physics.new_body(world, 20, 20, 'static')
  local obj = love.physics.new_pulley_joint(body1, body2, 10, 10, 20, 20, 15, 15, 25, 25, 1, true)
  test:assert_object(obj)
end


-- love.physics.new_rectangle_shape
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_rectangle_shape = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body = love.physics.new_body(world, 10, 10, 'static')
  local shape1 = love.physics.new_rectangle_shape(body, 10, 20)
  local shape2 = love.physics.new_rectangle_shape(body, 10, 10, 40, 30, 10)
  test:assert_object(shape1)
  test:assert_object(shape2)
end


-- love.physics.new_revolute_joint
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_revolute_joint = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 10, 10, 'static')
  local body2 = love.physics.new_body(world, 20, 20, 'static')
  local obj = love.physics.new_revolute_joint(body1, body2, 10, 10, true)
  test:assert_object(obj)
end


-- love.physics.new_rope_joint
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_rope_joint = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 10, 10, 'static')
  local body2 = love.physics.new_body(world, 20, 20, 'static')
  local obj = love.physics.new_rope_joint(body1, body2, 10, 10, 20, 20, 50, true)
  test:assert_object(obj)
end


-- love.physics.new_weld_joint
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_weld_joint = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 10, 10, 'static')
  local body2 = love.physics.new_body(world, 20, 20, 'static')
  local obj = love.physics.new_weld_joint(body1, body2, 10, 10, true)
  test:assert_object(obj)
end


-- love.physics.new_wheel_joint
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_wheel_joint = function(test)
  local world = love.physics.new_world(1, 1, true)
  local body1 = love.physics.new_body(world, 10, 10, 'static')
  local body2 = love.physics.new_body(world, 20, 20, 'static')
  local obj = love.physics.new_wheel_joint(body1, body2, 10, 10, 5, 5, true)
  test:assert_object(obj)
end


-- love.physics.new_world
-- @NOTE this is just basic nil checking, objs have their own test method
love.test.physics.new_world = function(test)
  local world = love.physics.new_world(1, 1, true)
  test:assert_object(world)
end


-- love.physics.set_meter
love.test.physics.set_meter = function(test)
  -- set initial meter
  local world = love.physics.new_world(1, 1, true)
  love.physics.set_meter(30)
  local body = love.physics.new_body(world, 300, 300, "dynamic")
  -- check changing meter changes pos value relatively
  love.physics.set_meter(10)
  local x, y = body:get_position()
  test:assert_equals(100, x, 'check pos x')
  test:assert_equals(100, y, 'check pos y')
end

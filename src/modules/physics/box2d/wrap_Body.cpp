/**
 * Copyright (c) 2006-2024 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 **/

#include "wrap_Body.h"
#include "wrap_Physics.h"
#include "wrap_Shape.h"

namespace love
{
namespace physics
{
namespace box2d
{

Body *luax_checkbody(lua_State *L, int idx)
{
	Body *b = luax_checktype<Body>(L, idx);
	if (b->body == 0)
		luaL_error(L, "Attempt to use destroyed body.");
	return b;
}

int w_Body_getX(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_pushnumber(L, t->getX());
	return 1;
}

int w_Body_getY(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_pushnumber(L, t->getY());
	return 1;
}

int w_Body_getAngle(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_pushnumber(L, t->getAngle());
	return 1;
}

int w_Body_getPosition(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);

	float x_o, y_o;
	t->getPosition(x_o, y_o);
	lua_pushnumber(L, x_o);
	lua_pushnumber(L, y_o);

	return 2;
}

int w_Body_getTransform(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);

	float x_o, y_o;
	t->getPosition(x_o, y_o);
	lua_pushnumber(L, x_o);
	lua_pushnumber(L, y_o);
	lua_pushnumber(L, t->getAngle());

	return 3;
}

int w_Body_getLinearVelocity(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);

	float x_o, y_o;
	t->getLinearVelocity(x_o, y_o);
	lua_pushnumber(L, x_o);
	lua_pushnumber(L, y_o);

	return 2;
}

int w_Body_getWorldCenter(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);

	float x_o, y_o;
	t->getWorldCenter(x_o, y_o);
	lua_pushnumber(L, x_o);
	lua_pushnumber(L, y_o);

	return 2;
}

int w_Body_getLocalCenter(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);

	float x_o, y_o;
	t->getLocalCenter(x_o, y_o);
	lua_pushnumber(L, x_o);
	lua_pushnumber(L, y_o);

	return 2;
}

int w_Body_getAngularVelocity(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_pushnumber(L, t->getAngularVelocity());
	return 1;
}

int w_Body_getKinematicState(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	b2Vec2 pos_o, vel_o;
	float a_o, da_o;
	t->getKinematicState(pos_o, a_o, vel_o, da_o);
	lua_pushnumber(L, pos_o.x);
	lua_pushnumber(L, pos_o.y);
	lua_pushnumber(L, a_o);
	lua_pushnumber(L, vel_o.x);
	lua_pushnumber(L, vel_o.y);
	lua_pushnumber(L, da_o);
	return 6;
}

int w_Body_getMass(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_pushnumber(L, t->getMass());
	return 1;
}

int w_Body_getInertia(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_pushnumber(L, t->getInertia());
	return 1;
}

int w_Body_getMassData(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_remove(L, 1);
	return t->getMassData(L);
}

int w_Body_hasCustomMassData(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	luax_pushboolean(L, t->hasCustomMassData());
	return 1;
}

int w_Body_getAngularDamping(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_pushnumber(L, t->getAngularDamping());
	return 1;
}

int w_Body_getLinearDamping(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_pushnumber(L, t->getLinearDamping());
	return 1;
}

int w_Body_getGravityScale(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_pushnumber(L, t->getGravityScale());
	return 1;
}

int w_Body_getType(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	const char *type = "";
	Body::getConstant(t->getType(), type);
	lua_pushstring(L, type);
	return 1;
}

int w_Body_applyLinearImpulse(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float jx = (float)luaL_checknumber(L, 2);
	float jy = (float)luaL_checknumber(L, 3);

	int nargs = lua_gettop(L);

	if (nargs <= 3 || (nargs == 4 && lua_type(L, 4) == LUA_TBOOLEAN))
	{
		bool awake = luax_optboolean(L, 4, true);
		t->applyLinearImpulse(jx, jy, awake);
	}
	else if (nargs >= 5)
	{
		float rx = (float)luaL_checknumber(L, 4);
		float ry = (float)luaL_checknumber(L, 5);
		bool awake = luax_optboolean(L, 6, true);
		t->applyLinearImpulse(jx, jy, rx, ry, awake);
	}
	else
	{
		return luaL_error(L, "Wrong number of parameters.");
	}

	return 0;
}

int w_Body_applyAngularImpulse(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float i = (float)luaL_checknumber(L, 2);
	bool awake = luax_optboolean(L, 3, true);
	t->applyAngularImpulse(i, awake);
	return 0;
}

int w_Body_applyTorque(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float arg = (float)luaL_checknumber(L, 2);
	bool awake = luax_optboolean(L, 3, true);
	t->applyTorque(arg, awake);
	return 0;
}

int w_Body_applyForce(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float fx = (float)luaL_checknumber(L, 2);
	float fy = (float)luaL_checknumber(L, 3);

	int nargs = lua_gettop(L);

	if (nargs <= 3 || (nargs == 4 && lua_type(L, 4) == LUA_TBOOLEAN))
	{
		bool awake = luax_optboolean(L, 4, true);
		t->applyForce(fx, fy, awake);
	}
	else if (lua_gettop(L) >= 5)
	{
		float rx = (float)luaL_checknumber(L, 4);
		float ry = (float)luaL_checknumber(L, 5);
		bool awake = luax_optboolean(L, 6, true);
		t->applyForce(fx, fy, rx, ry, awake);
	}
	else
	{
		return luaL_error(L, "Wrong number of parameters.");
	}

	return 0;
}

int w_Body_setX(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	luax_catchexcept(L, [&](){ t->setX(arg1); });
	return 0;
}

int w_Body_setY(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	luax_catchexcept(L, [&](){ t->setY(arg1); });
	return 0;
}

int w_Body_setTransform(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float x = (float)luaL_checknumber(L, 2);
	float y = (float)luaL_checknumber(L, 3);
	float angle = (float)luaL_checknumber(L, 4);
	luax_catchexcept(L, [&](){
		t->setPosition(x, y);
		t->setAngle(angle);
	});
	return 0;
}

int w_Body_setLinearVelocity(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	float arg2 = (float)luaL_checknumber(L, 3);
	t->setLinearVelocity(arg1, arg2);
	return 0;
}

int w_Body_setAngle(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	luax_catchexcept(L, [&](){ t->setAngle(arg1); });
	return 0;
}

int w_Body_setAngularVelocity(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	t->setAngularVelocity(arg1);
	return 0;
}

int w_Body_setPosition(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	float arg2 = (float)luaL_checknumber(L, 3);
	luax_catchexcept(L, [&](){ t->setPosition(arg1, arg2); });
	return 0;
}

int w_Body_setKinematicState(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float x = (float)luaL_checknumber(L, 2);
	float y = (float)luaL_checknumber(L, 3);
	float a = (float)luaL_checknumber(L, 4);
	float dx = (float)luaL_checknumber(L, 5);
	float dy = (float)luaL_checknumber(L, 6);
	float da = (float)luaL_checknumber(L, 7);
	luax_catchexcept(L, [&](){ t->setKinematicState(b2Vec2(x, y), a, b2Vec2(dx, dy), da); });
	return 0;
}

int w_Body_resetMassData(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	luax_catchexcept(L, [&](){ t->resetMassData(); });
	return 0;
}

int w_Body_setMassData(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float x = (float)luaL_checknumber(L, 2);
	float y = (float)luaL_checknumber(L, 3);
	float m = (float)luaL_checknumber(L, 4);
	float i = (float)luaL_checknumber(L, 5);
	luax_catchexcept(L, [&](){ t->setMassData(x, y, m, i); });
	return 0;
}

int w_Body_setMass(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float m = (float)luaL_checknumber(L, 2);
	luax_catchexcept(L, [&](){ t->setMass(m); });
	return 0;
}

int w_Body_setInertia(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float i = (float)luaL_checknumber(L, 2);
	luax_catchexcept(L, [&](){ t->setInertia(i); });
	return 0;
}

int w_Body_setAngularDamping(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	t->setAngularDamping(arg1);
	return 0;
}

int w_Body_setLinearDamping(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	t->setLinearDamping(arg1);
	return 0;
}

int w_Body_setGravityScale(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	t->setGravityScale(arg1);
	return 0;
}

int w_Body_setType(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	const char *typeStr = luaL_checkstring(L, 2);
	Body::Type type;
	Body::getConstant(typeStr, type);
	luax_catchexcept(L, [&](){ t->setType(type); });
	return 0;
}

int w_Body_getWorldPoint(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);

	float x = (float)luaL_checknumber(L, 2);
	float y = (float)luaL_checknumber(L, 3);
	float x_o, y_o;
	t->getWorldPoint(x, y, x_o, y_o);
	lua_pushnumber(L, x_o);
	lua_pushnumber(L, y_o);

	return 2;
}

int w_Body_getWorldVector(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);

	float x = (float)luaL_checknumber(L, 2);
	float y = (float)luaL_checknumber(L, 3);
	float x_o, y_o;
	t->getWorldVector(x, y, x_o, y_o);
	lua_pushnumber(L, x_o);
	lua_pushnumber(L, y_o);

	return 2;
}

int w_Body_getWorldPoints(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_remove(L, 1);
	return t->getWorldPoints(L);
}

int w_Body_getLocalPoint(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);

	float x = (float)luaL_checknumber(L, 2);
	float y = (float)luaL_checknumber(L, 3);
	float x_o, y_o;
	t->getLocalPoint(x, y, x_o, y_o);
	lua_pushnumber(L, x_o);
	lua_pushnumber(L, y_o);

	return 2;
}

int w_Body_getLocalVector(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);

	float x = (float)luaL_checknumber(L, 2);
	float y = (float)luaL_checknumber(L, 3);
	float x_o, y_o;
	t->getLocalVector(x, y, x_o, y_o);
	lua_pushnumber(L, x_o);
	lua_pushnumber(L, y_o);

	return 2;
}

int w_Body_getLocalPoints(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_remove(L, 1);
	return t->getLocalPoints(L);
}

int w_Body_getLinearVelocityFromWorldPoint(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);

	float x = (float)luaL_checknumber(L, 2);
	float y = (float)luaL_checknumber(L, 3);
	float x_o, y_o;
	t->getLinearVelocityFromWorldPoint(x, y, x_o, y_o);
	lua_pushnumber(L, x_o);
	lua_pushnumber(L, y_o);

	return 2;
}

int w_Body_getLinearVelocityFromLocalPoint(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);

	float x = (float)luaL_checknumber(L, 2);
	float y = (float)luaL_checknumber(L, 3);
	float x_o, y_o;
	t->getLinearVelocityFromLocalPoint(x, y, x_o, y_o);
	lua_pushnumber(L, x_o);
	lua_pushnumber(L, y_o);

	return 2;
}

int w_Body_isBullet(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	luax_pushboolean(L, t->isBullet());
	return 1;
}

int w_Body_setBullet(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	bool b = luax_checkboolean(L, 2);
	t->setBullet(b);
	return 0;
}

int w_Body_isActive(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	luax_pushboolean(L, t->isEnabled());
	return 1;
}

int w_Body_isAwake(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	luax_pushboolean(L, t->isAwake());
	return 1;
}

int w_Body_setSleepingAllowed(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	bool b = luax_checkboolean(L, 2);
	t->setSleepingAllowed(b);
	return 0;
}

int w_Body_isSleepingAllowed(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_pushboolean(L, t->isSleepingAllowed());
	return 1;
}

int w_Body_setActive(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	bool b = luax_checkboolean(L, 2);
	luax_catchexcept(L, [&](){ t->setEnabled(b); });
	return 0;
}

int w_Body_setAwake(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	bool b = luax_checkboolean(L, 2);
	t->setAwake(b);
	return 0;
}

int w_Body_setFixedRotation(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	bool b = luax_checkboolean(L, 2);
	luax_catchexcept(L, [&](){ t->setFixedRotation(b); });
	return 0;
}

int w_Body_isFixedRotation(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	bool b = t->isFixedRotation();
	luax_pushboolean(L, b);
	return 1;
}

int w_Body_isTouching(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	Body *other = luax_checkbody(L, 2);
	luax_pushboolean(L, t->isTouching(other));
	return 1;
}

int w_Body_getWorld(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	World *world = t->getWorld();
	luax_pushtype(L, world);
	return 1;
}

int w_Body_getShape(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	Shape *s = t->getShape();
	if (s)
		luax_pushshape(L, s);
	else
		lua_pushnil(L);
	return 1;
}

int w_Body_getShapes(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_remove(L, 1);
	int n = 0;
	luax_catchexcept(L, [&](){ n = t->getShapes(L); });
	return n;
}

int w_Body_getFixtures(lua_State *L)
{
	luax_markdeprecated(L, 1, "Body:getFixtures", API_METHOD, DEPRECATED_REPLACED, "Body:getShapes");
	return w_Body_getShapes(L);
}

int w_Body_getJoints(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_remove(L, 1);
	int n = 0;
	luax_catchexcept(L, [&](){ n = t->getJoints(L); });
	return n;
}

int w_Body_getContacts(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_remove(L, 1);
	int n = 0;
	luax_catchexcept(L, [&](){ n = t->getContacts(L); });
	return n;
}

int w_Body_destroy(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	luax_catchexcept(L, [&](){ t->destroy(); });
	return 0;
}

int w_Body_isDestroyed(lua_State *L)
{
	Body *b = luax_checktype<Body>(L, 1);
	luax_pushboolean(L, b->body == nullptr);
	return 1;
}

int w_Body_setUserData(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_remove(L, 1);
	return t->setUserData(L);
}

int w_Body_getUserData(lua_State *L)
{
	Body *t = luax_checkbody(L, 1);
	lua_remove(L, 1);
	return t->getUserData(L);
}

static const luaL_Reg w_Body_functions[] =
{
	{ "get_x", w_Body_getX },
	{ "get_y", w_Body_getY },
	{ "get_angle", w_Body_getAngle },
	{ "get_position", w_Body_getPosition },
	{ "get_transform", w_Body_getTransform },
	{ "set_transform", w_Body_setTransform },
	{ "get_linear_velocity", w_Body_getLinearVelocity },
	{ "get_world_center", w_Body_getWorldCenter },
	{ "get_local_center", w_Body_getLocalCenter },
	{ "get_angular_velocity", w_Body_getAngularVelocity },
	{ "get_kinematic_state", w_Body_getKinematicState },
	{ "get_mass", w_Body_getMass },
	{ "get_inertia", w_Body_getInertia },
	{ "get_mass_data", w_Body_getMassData },
	{ "has_custom_mass_data", w_Body_hasCustomMassData },
	{ "get_angular_damping", w_Body_getAngularDamping },
	{ "get_linear_damping", w_Body_getLinearDamping },
	{ "get_gravity_scale", w_Body_getGravityScale },
	{ "get_type", w_Body_getType },
	{ "apply_linear_impulse", w_Body_applyLinearImpulse },
	{ "apply_angular_impulse", w_Body_applyAngularImpulse },
	{ "apply_torque", w_Body_applyTorque },
	{ "apply_force", w_Body_applyForce },
	{ "set_x", w_Body_setX },
	{ "set_y", w_Body_setY },
	{ "set_linear_velocity", w_Body_setLinearVelocity },
	{ "set_angle", w_Body_setAngle },
	{ "set_angular_velocity", w_Body_setAngularVelocity },
	{ "set_position", w_Body_setPosition },
	{ "set_kinematic_state", w_Body_setKinematicState },
	{ "reset_mass_data", w_Body_resetMassData },
	{ "set_mass_data", w_Body_setMassData },
	{ "set_mass", w_Body_setMass },
	{ "set_inertia", w_Body_setInertia },
	{ "set_angular_damping", w_Body_setAngularDamping },
	{ "set_linear_damping", w_Body_setLinearDamping },
	{ "set_gravity_scale", w_Body_setGravityScale },
	{ "set_type", w_Body_setType },
	{ "get_world_point", w_Body_getWorldPoint },
	{ "get_world_vector", w_Body_getWorldVector },
	{ "get_world_points", w_Body_getWorldPoints },
	{ "get_local_point", w_Body_getLocalPoint },
	{ "get_local_vector", w_Body_getLocalVector },
	{ "get_local_points", w_Body_getLocalPoints },
	{ "get_linear_velocity_from_world_point", w_Body_getLinearVelocityFromWorldPoint },
	{ "get_linear_velocity_from_local_point", w_Body_getLinearVelocityFromLocalPoint },
	{ "is_bullet", w_Body_isBullet },
	{ "set_bullet", w_Body_setBullet },
	{ "is_active", w_Body_isActive },
	{ "is_awake", w_Body_isAwake },
	{ "set_sleeping_allowed", w_Body_setSleepingAllowed },
	{ "is_sleeping_allowed", w_Body_isSleepingAllowed },
	{ "set_active", w_Body_setActive },
	{ "set_awake", w_Body_setAwake },
	{ "set_fixed_rotation", w_Body_setFixedRotation },
	{ "is_fixed_rotation", w_Body_isFixedRotation },
	{ "is_touching", w_Body_isTouching },
	{ "get_world", w_Body_getWorld },
	{ "get_shape", w_Body_getShape },
	{ "get_shapes", w_Body_getShapes },
	{ "get_joints", w_Body_getJoints },
	{ "get_contacts", w_Body_getContacts },
	{ "destroy", w_Body_destroy },
	{ "is_destroyed", w_Body_isDestroyed },
	{ "set_user_data", w_Body_setUserData },
	{ "get_user_data", w_Body_getUserData },

	// Deprecated
	{ "get_fixtures", w_Body_getFixtures },

	{ 0, 0 }
};

extern "C" int luaopen_body(lua_State *L)
{
	return luax_register_type(L, &Body::type, w_Body_functions, nullptr);
}

} // box2d
} // physics
} // love

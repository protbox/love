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

#include "wrap_MotorJoint.h"

namespace love
{
namespace physics
{
namespace box2d
{

MotorJoint *luax_checkmotorjoint(lua_State *L, int idx)
{
	MotorJoint *j = luax_checktype<MotorJoint>(L, idx);
	if (!j->isValid())
		luaL_error(L, "Attempt to use destroyed joint.");
	return j;
}

int w_MotorJoint_setLinearOffset(lua_State *L)
{
	MotorJoint *t = luax_checkmotorjoint(L, 1);
	float x = (float) luaL_checknumber(L, 2);
	float y = (float) luaL_checknumber(L, 3);
	t->setLinearOffset(x, y);
	return 0;
}

int w_MotorJoint_getLinearOffset(lua_State *L)
{
	MotorJoint *t = luax_checkmotorjoint(L, 1);
	return t->getLinearOffset(L);
}

int w_MotorJoint_setAngularOffset(lua_State *L)
{
	MotorJoint *t = luax_checkmotorjoint(L, 1);
	float arg1 = (float) luaL_checknumber(L, 2);
	t->setAngularOffset(arg1);
	return 0;
}

int w_MotorJoint_getAngularOffset(lua_State *L)
{
	MotorJoint *t = luax_checkmotorjoint(L, 1);
	lua_pushnumber(L, t->getAngularOffset());
	return 1;
}

int w_MotorJoint_setMaxForce(lua_State *L)
{
	MotorJoint *t = luax_checkmotorjoint(L, 1);
	float arg1 = (float) luaL_checknumber(L, 2);
	luax_catchexcept(L, [&](){ t->setMaxForce(arg1); });
	return 0;
}

int w_MotorJoint_getMaxForce(lua_State *L)
{
	MotorJoint *t = luax_checkmotorjoint(L, 1);
	lua_pushnumber(L, t->getMaxForce());
	return 1;
}

int w_MotorJoint_setMaxTorque(lua_State *L)
{
	MotorJoint *t = luax_checkmotorjoint(L, 1);
	float arg1 = (float) luaL_checknumber(L, 2);
	luax_catchexcept(L, [&](){ t->setMaxTorque(arg1); });
	return 0;
}

int w_MotorJoint_getMaxTorque(lua_State *L)
{
	MotorJoint *t = luax_checkmotorjoint(L, 1);
	lua_pushnumber(L, t->getMaxTorque());
	return 1;
}

int w_MotorJoint_setCorrectionFactor(lua_State *L)
{
	MotorJoint *t = luax_checkmotorjoint(L, 1);
	float arg1 = (float) luaL_checknumber(L, 2);
	luax_catchexcept(L, [&](){ t->setCorrectionFactor(arg1); });
	return 0;
}

int w_MotorJoint_getCorrectionFactor(lua_State *L)
{
	MotorJoint *t = luax_checkmotorjoint(L, 1);
	lua_pushnumber(L, t->getCorrectionFactor());
	return 1;
}

static const luaL_Reg w_MotorJoint_functions[] =
{
	{ "set_linear_offset", w_MotorJoint_setLinearOffset },
	{ "get_linear_offset", w_MotorJoint_getLinearOffset },
	{ "set_angular_offset", w_MotorJoint_setAngularOffset },
	{ "get_angular_offset", w_MotorJoint_getAngularOffset },
	{ "set_max_force", w_MotorJoint_setMaxForce },
	{ "get_max_force", w_MotorJoint_getMaxForce },
	{ "set_max_torque", w_MotorJoint_setMaxTorque },
	{ "get_max_torque", w_MotorJoint_getMaxTorque },
	{ "set_correction_factor", w_MotorJoint_setCorrectionFactor },
	{ "get_correction_factor", w_MotorJoint_getCorrectionFactor },
	{ 0, 0 }
};

extern "C" int luaopen_motorjoint(lua_State *L)
{
	return luax_register_type(L, &MotorJoint::type, w_Joint_functions, w_MotorJoint_functions, nullptr);
}


} // box2d
} // phyics
} // love

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

#include "wrap_WheelJoint.h"

namespace love
{
namespace physics
{
namespace box2d
{

WheelJoint *luax_checkwheeljoint(lua_State *L, int idx)
{
	WheelJoint *j = luax_checktype<WheelJoint>(L, idx);
	if (!j->isValid())
		luaL_error(L, "Attempt to use destroyed joint.");
	return j;
}

int w_WheelJoint_getJointTranslation(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	lua_pushnumber(L, t->getJointTranslation());
	return 1;
}

int w_WheelJoint_getJointSpeed(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	lua_pushnumber(L, t->getJointSpeed());
	return 1;
}

int w_WheelJoint_setMotorEnabled(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	bool arg1 = luax_checkboolean(L, 2);
	t->setMotorEnabled(arg1);
	return 0;
}

int w_WheelJoint_isMotorEnabled(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	luax_pushboolean(L, t->isMotorEnabled());
	return 1;
}

int w_WheelJoint_setMotorSpeed(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	t->setMotorSpeed(arg1);
	return 0;
}

int w_WheelJoint_getMotorSpeed(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	lua_pushnumber(L, t->getMotorSpeed());
	return 1;
}

int w_WheelJoint_setMaxMotorTorque(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	t->setMaxMotorTorque(arg1);
	return 0;
}

int w_WheelJoint_getMaxMotorTorque(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	lua_pushnumber(L, t->getMaxMotorTorque());
	return 1;
}

int w_WheelJoint_getMotorTorque(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	float dt = (float)luaL_checknumber(L, 2);
	lua_pushnumber(L, t->getMotorTorque(dt));
	return 1;
}

int w_WheelJoint_setStiffness(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	t->setStiffness(arg1);
	return 0;
}

int w_WheelJoint_getStiffness(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	lua_pushnumber(L, t->getStiffness());
	return 1;
}

int w_WheelJoint_setDamping(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	t->setDamping(arg1);
	return 0;
}

int w_WheelJoint_getDamping(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	lua_pushnumber(L, t->getDamping());
	return 1;
}

int w_WheelJoint_getAxis(lua_State *L)
{
	WheelJoint *t = luax_checkwheeljoint(L, 1);
	lua_remove(L, 1);
	return t->getAxis(L);
}

static const luaL_Reg w_WheelJoint_functions[] =
{
	{ "get_joint_translation", w_WheelJoint_getJointTranslation },
	{ "get_joint_speed", w_WheelJoint_getJointSpeed },
	{ "set_motor_enabled", w_WheelJoint_setMotorEnabled },
	{ "is_motor_enabled", w_WheelJoint_isMotorEnabled },
	{ "set_motor_speed", w_WheelJoint_setMotorSpeed },
	{ "get_motor_speed", w_WheelJoint_getMotorSpeed },
	{ "set_max_motor_torque", w_WheelJoint_setMaxMotorTorque },
	{ "get_max_motor_torque", w_WheelJoint_getMaxMotorTorque },
	{ "get_motor_torque", w_WheelJoint_getMotorTorque },
	{ "set_spring_stiffness", w_WheelJoint_setStiffness },
	{ "get_spring_stiffness", w_WheelJoint_getStiffness },
	{ "set_spring_damping", w_WheelJoint_setDamping },
	{ "get_spring_damping", w_WheelJoint_getDamping },
	{ "set_stiffness", w_WheelJoint_setStiffness },
	{ "get_stiffness", w_WheelJoint_getStiffness },
	{ "set_damping", w_WheelJoint_setDamping },
	{ "get_damping", w_WheelJoint_getDamping },
	{ "get_axis", w_WheelJoint_getAxis },
	{ 0, 0 }
};

extern "C" int luaopen_wheeljoint(lua_State *L)
{
	return luax_register_type(L, &WheelJoint::type, w_Joint_functions, w_WheelJoint_functions, nullptr);
}

} // box2d
} // physics
} // love

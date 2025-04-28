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

#include "wrap_World.h"

namespace love
{
namespace physics
{
namespace box2d
{

World *luax_checkworld(lua_State *L, int idx)
{
	World *w = luax_checktype<World>(L, idx);
	if (!w->isValid())
		luaL_error(L, "Attempt to use destroyed world.");
	return w;
}

int w_World_update(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	float dt = (float)luaL_checknumber(L, 2);

	// Make sure the world callbacks are using the calling Lua thread.
	t->setCallbacksL(L);

	if (lua_isnoneornil(L, 3))
		luax_catchexcept(L, [&](){ t->update(dt); });
	else
	{
		int velocityiterations = (int) luaL_checkinteger(L, 3);
		int positioniterations = (int) luaL_checkinteger(L, 4);
		luax_catchexcept(L, [&](){ t->update(dt, velocityiterations, positioniterations); });
	}

	return 0;
}

int w_World_setCallbacks(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	return t->setCallbacks(L);
}

int w_World_getCallbacks(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	return t->getCallbacks(L);
}

int w_World_setContactFilter(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	return t->setContactFilter(L);
}

int w_World_getContactFilter(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	return t->getContactFilter(L);
}

int w_World_setGravity(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	float arg2 = (float)luaL_checknumber(L, 3);
	t->setGravity(arg1, arg2);
	return 0;
}

int w_World_getGravity(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	return t->getGravity(L);
}

int w_World_translateOrigin(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	float arg1 = (float)luaL_checknumber(L, 2);
	float arg2 = (float)luaL_checknumber(L, 3);
	luax_catchexcept(L, [&](){ t->translateOrigin(arg1, arg2); });
	return 0;
}

int w_World_setSleepingAllowed(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	bool b = luax_checkboolean(L, 2);
	t->setSleepingAllowed(b);
	return 0;
}

int w_World_isSleepingAllowed(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	luax_pushboolean(L, t->isSleepingAllowed());
	return 1;
}

int w_World_isLocked(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	luax_pushboolean(L, t->isLocked());
	return 1;
}

int w_World_getBodyCount(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_pushinteger(L, t->getBodyCount());
	return 1;
}

int w_World_getJointCount(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_pushinteger(L, t->getJointCount());
	return 1;
}

int w_World_getContactCount(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_pushinteger(L, t->getContactCount());
	return 1;
}

int w_World_getBodies(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	int ret = 0;
	luax_catchexcept(L, [&](){ ret = t->getBodies(L); });
	return ret;
}

int w_World_getJoints(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	int ret = 0;
	luax_catchexcept(L, [&](){ ret = t->getJoints(L); });
	return ret;
}

int w_World_getContacts(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	int ret = 0;
	luax_catchexcept(L, [&](){ ret = t->getContacts(L); });
	return ret;
}

int w_World_queryShapesInArea(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	return t->queryShapesInArea(L);
}

int w_World_queryBoundingBox(lua_State *L)
{
	luax_markdeprecated(L, 1, "World:queryBoundingBox", API_METHOD, DEPRECATED_RENAMED, "World:queryShapesInArea");
	return w_World_queryShapesInArea(L);
}

int w_World_getShapesInArea(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	int ret = 0;
	luax_catchexcept(L, [&](){ ret = t->getShapesInArea(L); });
	return ret;
}

int w_World_rayCast(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	int ret = 0;
	luax_catchexcept(L, [&](){ ret = t->rayCast(L); });
	return ret;
}

int w_World_rayCastAny(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	int ret = 0;
	luax_catchexcept(L, [&]() { ret = t->rayCastAny(L); });
	return ret;
}

int w_World_rayCastClosest(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	lua_remove(L, 1);
	int ret = 0;
	luax_catchexcept(L, [&]() { ret = t->rayCastClosest(L); });
	return ret;
}

int w_World_destroy(lua_State *L)
{
	World *t = luax_checkworld(L, 1);
	luax_catchexcept(L, [&](){ t->destroy(); });
	return 0;
}

int w_World_isDestroyed(lua_State *L)
{
	World *w = luax_checktype<World>(L, 1);
	luax_pushboolean(L, !w->isValid());
	return 1;
}

static const luaL_Reg w_World_functions[] =
{
	{ "update", w_World_update },
	{ "set_callbacks", w_World_setCallbacks },
	{ "get_callbacks", w_World_getCallbacks },
	{ "set_contact_filter", w_World_setContactFilter },
	{ "get_contact_filter", w_World_getContactFilter },
	{ "set_gravity", w_World_setGravity },
	{ "get_gravity", w_World_getGravity },
	{ "translate_origin", w_World_translateOrigin },
	{ "set_sleeping_allowed", w_World_setSleepingAllowed },
	{ "is_sleeping_allowed", w_World_isSleepingAllowed },
	{ "is_locked", w_World_isLocked },
	{ "get_body_count", w_World_getBodyCount },
	{ "get_joint_count", w_World_getJointCount },
	{ "get_contact_count", w_World_getContactCount },
	{ "get_bodies", w_World_getBodies },
	{ "get_joints", w_World_getJoints },
	{ "get_contacts", w_World_getContacts },
	{ "query_shapes_in_area", w_World_queryShapesInArea },
	{ "get_shapes_in_area", w_World_getShapesInArea },
	{ "ray_cast", w_World_rayCast },
	{ "ray_cast_any", w_World_rayCastAny },
	{ "ray_cast_closest", w_World_rayCastClosest },
	{ "destroy", w_World_destroy },
	{ "is_destroyed", w_World_isDestroyed },

	// Deprecated
	{ "query_bounding_box", w_World_queryBoundingBox },

	{ 0, 0 }
};

extern "C" int luaopen_world(lua_State *L)
{
	return luax_register_type(L, &World::type, w_World_functions, nullptr);
}

} // box2d
} // physics
} // love

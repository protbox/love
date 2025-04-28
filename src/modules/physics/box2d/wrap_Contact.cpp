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

#include "wrap_Contact.h"
#include "wrap_Shape.h"

namespace love
{
namespace physics
{
namespace box2d
{

Contact *luax_checkcontact(lua_State *L, int idx)
{
	Contact *c = luax_checktype<Contact>(L, idx);
	if (!c->isValid())
		luaL_error(L, "Attempt to use destroyed contact.");
	return c;
}

int w_Contact_getPositions(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	return t->getPositions(L);
}

int w_Contact_getNormal(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	return t->getNormal(L);
}

int w_Contact_getFriction(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	lua_pushnumber(L, t->getFriction());
	return 1;
}

int w_Contact_getRestitution(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	lua_pushnumber(L, t->getRestitution());
	return 1;
}

int w_Contact_isEnabled(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	lua_pushboolean(L, t->isEnabled());
	return 1;
}

int w_Contact_isTouching(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	lua_pushboolean(L, t->isTouching());
	return 1;
}

int w_Contact_setFriction(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	float f = (float)luaL_checknumber(L, 2);
	t->setFriction(f);
	return 0;
}

int w_Contact_setRestitution(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	float r = (float)luaL_checknumber(L, 2);
	t->setRestitution(r);
	return 0;
}

int w_Contact_setEnabled(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	bool e = luax_checkboolean(L, 2);
	t->setEnabled(e);
	return 0;
}

int w_Contact_resetFriction(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	t->resetFriction();
	return 0;
}

int w_Contact_resetRestitution(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	t->resetRestitution();
	return 0;
}

int w_Contact_setTangentSpeed(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	float speed = (float) luaL_checknumber(L, 2);
	t->setTangentSpeed(speed);
	return 0;
}

int w_Contact_getTangentSpeed(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	lua_pushnumber(L, t->getTangentSpeed());
	return 1;
}

int w_Contact_getChildren(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	int a, b;
	t->getChildren(a, b);
	lua_pushnumber(L, a + 1);
	lua_pushnumber(L, b + 1);
	return 2;
}

int w_Contact_getShapes(lua_State *L)
{
	Contact *t = luax_checkcontact(L, 1);
	Shape *a = nullptr;
	Shape *b = nullptr;
	luax_catchexcept(L, [&](){ t->getShapes(a, b); });

	luax_pushshape(L, a);
	luax_pushshape(L, b);
	return 2;
}

int w_Contact_getFixtures(lua_State *L)
{
	luax_markdeprecated(L, 1, "Contact:getFixtures", API_METHOD, DEPRECATED_REPLACED, "Contact:getShapes");
	return w_Contact_getShapes(L);
}

int w_Contact_isDestroyed(lua_State *L)
{
	Contact *c = luax_checktype<Contact>(L, 1);
	luax_pushboolean(L, !c->isValid());
	return 1;
}

static const luaL_Reg w_Contact_functions[] =
{
	{ "get_positions", w_Contact_getPositions },
	{ "get_normal", w_Contact_getNormal },
	{ "get_friction", w_Contact_getFriction },
	{ "get_restitution", w_Contact_getRestitution },
	{ "is_enabled", w_Contact_isEnabled },
	{ "is_touching", w_Contact_isTouching },
	{ "set_friction", w_Contact_setFriction },
	{ "set_restitution", w_Contact_setRestitution },
	{ "set_enabled", w_Contact_setEnabled },
	{ "reset_friction", w_Contact_resetFriction },
	{ "reset_restitution", w_Contact_resetRestitution },
	{ "set_tangent_speed", w_Contact_setTangentSpeed },
	{ "get_tangent_speed", w_Contact_getTangentSpeed },
	{ "get_children", w_Contact_getChildren },
	{ "get_shapes", w_Contact_getShapes },
	{ "is_destroyed", w_Contact_isDestroyed },

	// Deprecated
	{ "get_fixtures", w_Contact_getFixtures },

	{ 0, 0 }
};

extern "C" int luaopen_contact(lua_State *L)
{
	return luax_register_type(L, &Contact::type, w_Contact_functions, nullptr);
}

} // box2d
} // physics
} // love

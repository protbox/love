R"luastring"--(
-- DO NOT REMOVE THE ABOVE LINE. It is used to load this file as a C++ string.
-- There is a matching delimiter at the bottom of the file.

--[[
Copyright (c) 2006-2024 LOVE Development Team

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
--]]

local Data_mt, ffifuncspointer_str = ...
local Data = Data_mt.__index

local type, error = type, error

if type(jit) ~= "table" then return end

local status, ffi = pcall(require, "ffi")
if not status then return end

pcall(ffi.cdef, [[
typedef struct Proxy Proxy;

typedef struct FFI_Data
{
	void *(*getFFIPointer)(Proxy *p);
} FFI_Data;
]])

local ffifuncs = ffi.cast("const FFI_Data **", ffifuncspointer_str)[0]

-- Overwrite placeholder method with the FFI implementation.

function Data:get_ffi_pointer()
	-- TODO: This should ideally be handled inside the C function
	if self == nil then error("bad argument #1 to 'getFFIPointer' (Data expected, got no value)", 2) end
	return ffifuncs.getFFIPointer(self)
end

-- DO NOT REMOVE THE NEXT LINE. It is used to load this file as a C++ string.
--)luastring"--"

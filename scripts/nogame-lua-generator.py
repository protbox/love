#!/usr/bin/env python3
"""
LÖVE nogame.lua.h Generator
Generates a C header file with a byte array containing the contents of a Lua file.
Use this to create a new nogame.lua.h after converting the Lua code to snake_case.
"""

import os
import sys

def create_header_from_lua(lua_file_path, header_file_path):
    """Generate a C header file with a byte array from a Lua file."""
    # Read the lua file
    with open(lua_file_path, 'rb') as f:
        lua_content = f.read()
    
    # Generate the byte array string
    bytes_per_line = 8
    byte_array_lines = []
    
    for i in range(0, len(lua_content), bytes_per_line):
        line_bytes = lua_content[i:i+bytes_per_line]
        hex_values = [f"0x{b:02x}" for b in line_bytes]
        byte_array_lines.append("    " + ", ".join(hex_values) + ",")
    
    byte_array_str = "\n".join(byte_array_lines)
    
    # Create the header file content
    header_content = f"""
// Auto-generated from {os.path.basename(lua_file_path)}
// This file contains the Snake Case version of the nogame.lua screen
#ifndef LOVE_NOGAME_LUA_H
#define LOVE_NOGAME_LUA_H

// [nogame.lua]
const unsigned char nogame_lua[] = {{
{byte_array_str}
}};

const unsigned int nogame_lua_size = sizeof(nogame_lua);

#endif // LOVE_NOGAME_LUA_H
"""
    
    # Write the header file
    with open(header_file_path, 'w') as f:
        f.write(header_content)
    
    print(f"Generated {header_file_path} from {lua_file_path}")
    return True

def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <path_to_nogame.lua> <output_header_file>")
        sys.exit(1)
    
    lua_file_path = sys.argv[1]
    header_file_path = sys.argv[2]
    
    if not os.path.isfile(lua_file_path):
        print(f"Error: {lua_file_path} is not a file.")
        sys.exit(1)
    
    print(f"Generating {header_file_path} from {lua_file_path}...")
    create_header_from_lua(lua_file_path, header_file_path)
    print("Done!")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
LÖVE nogame.lua.h Converter
Extracts the embedded Lua code from nogame.lua.h, converts camelCase to snake_case,
and generates a new byte array for the header file.
"""

import os
import re
import sys
import binascii

def camel_to_snake(camel_str):
    """Convert a camelCase string to snake_case."""
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', camel_str)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def extract_byte_array(header_content):
    """Extract the byte array definition from the header file."""
    # Find the byte array definition
    match = re.search(r'const\s+unsigned\s+char\s+nogame_lua\[\]\s*=\s*\{([^}]+)\};', header_content, re.DOTALL)
    if not match:
        return None
    
    # Extract the bytes
    byte_str = match.group(1).strip()
    bytes_list = []
    
    # Parse the hex bytes
    for hex_val in re.findall(r'0x[0-9a-fA-F]+', byte_str):
        bytes_list.append(int(hex_val, 16))
    
    return bytes(bytes_list)

def generate_byte_array(data):
    """Generate a formatted byte array string from binary data."""
    result = []
    bytes_per_line = 8  # Adjust this for formatting
    
    for i in range(0, len(data), bytes_per_line):
        line_bytes = data[i:i+bytes_per_line]
        hex_values = [f"0x{b:02x}" for b in line_bytes]
        result.append("    " + ", ".join(hex_values) + ",")
    
    return "\n".join(result)

def convert_love_calls(lua_code):
    """Convert love.module.functionName calls to love.module.function_name in Lua code."""
    pattern = r'(love(?:\.[a-zA-Z0-9_]+)+)\.([a-z][a-zA-Z0-9_]*)'
    
    def replace_func(match):
        module_path = match.group(1)
        func_name = match.group(2)
        
        if re.search(r'[a-z]', func_name) and re.search(r'[A-Z]', func_name):
            snake_name = camel_to_snake(func_name)
            return f'{module_path}.{snake_name}'
        else:
            return match.group(0)
    
    return re.sub(pattern, replace_func, lua_code)

def process_nogame_header(file_path, dry_run=False):
    """Process the nogame.lua.h file to convert the embedded Lua code."""
    with open(file_path, 'r', encoding='utf-8') as f:
        header_content = f.read()
    
    # Extract the byte array
    byte_data = extract_byte_array(header_content)
    if byte_data is None:
        print(f"Error: Could not find byte array in {file_path}")
        return False
    
    # Convert to Lua code string
    try:
        lua_code = byte_data.decode('utf-8')
    except UnicodeDecodeError:
        print(f"Error: Could not decode byte array as UTF-8 in {file_path}")
        return False
    
    # Convert love.module.functionName calls
    modified_lua = convert_love_calls(lua_code)
    
    # If no changes were made or it's a dry run
    if modified_lua == lua_code or dry_run:
        if dry_run and modified_lua != lua_code:
            print(f"Would modify embedded Lua code in {file_path}")
        return modified_lua != lua_code
    
    # Generate new byte array
    new_bytes = modified_lua.encode('utf-8')
    new_byte_array = generate_byte_array(new_bytes)
    
    # Replace the byte array in the header file
    new_header = re.sub(
        r'const\s+unsigned\s+char\s+nogame_lua\[\]\s*=\s*\{[^}]+\};',
        f'const unsigned char nogame_lua[] = {{\n{new_byte_array}\n}};',
        header_content,
        flags=re.DOTALL
    )
    
    # Write the modified header file
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_header)
    
    print(f"Modified embedded Lua code in {file_path}")
    return True

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <path_to_nogame.lua.h> [--dry-run]")
        sys.exit(1)
    
    file_path = sys.argv[1]
    dry_run = "--dry-run" in sys.argv
    
    if not os.path.isfile(file_path):
        print(f"Error: {file_path} is not a file.")
        sys.exit(1)
    
    if dry_run:
        print(f"Analyzing {file_path} (dry run)...")
    else:
        print(f"Processing {file_path}...")
    
    modified = process_nogame_header(file_path, dry_run)
    
    if dry_run:
        if modified:
            print("\nDry run complete. The file would be modified.")
        else:
            print("\nDry run complete. No changes would be made.")
    else:
        if modified:
            print("\nConversion complete! The file was modified.")
        else:
            print("\nNo changes were necessary.")

if __name__ == "__main__":
    main()

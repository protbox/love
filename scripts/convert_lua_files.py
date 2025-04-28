#!/usr/bin/env python3
"""
Comprehensive LÖVE Lua File Converter
Converts camelCase function calls in Lua files to snake_case.
Handles all patterns: love.module.functionName, love_module.functionName,
love.module._functionName, and love_module._functionName
"""

import os
import re
import sys
from pathlib import Path

def camel_to_snake(camel_str):
    """Convert a camelCase string to snake_case."""
    # First handle the case where the first character is lowercase
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', camel_str)
    # Then handle the case where we have consecutive uppercase letters
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def process_lua_file(file_path, dry_run=False):
    """Process a single Lua file to convert love API calls."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern 1: matches love.module.functionName or love.module.submodule.functionName
    pattern1 = r'(love(?:\.[a-zA-Z0-9_]+)+)\.([a-z][a-zA-Z0-9_]*)'
    
    # Pattern 2: matches love_module.functionName
    pattern2 = r'(love_[a-zA-Z0-9_]+)\.([a-z][a-zA-Z0-9_]*)'
    
    # Pattern 3: matches love.module._functionName
    pattern3 = r'(love(?:\.[a-zA-Z0-9_]+)+)\.(_[a-z][a-zA-Z0-9_]*)'
    
    # Pattern 4: matches love_module._functionName
    pattern4 = r'(love_[a-zA-Z0-9_]+)\.(_[a-z][a-zA-Z0-9_]*)'
    
    # Function to handle replacements
    def replace_func(match):
        module_path = match.group(1)  # love.module or love_module
        func_name = match.group(2)    # functionName or _functionName
        
        # Only convert if the name is camelCase (has both lower and upper case)
        if re.search(r'[a-z]', func_name) and re.search(r'[A-Z]', func_name):
            # Preserve leading underscore if present
            if func_name.startswith('_'):
                snake_name = '_' + camel_to_snake(func_name[1:])
            else:
                snake_name = camel_to_snake(func_name)
            return f'{module_path}.{snake_name}'
        else:
            return match.group(0)  # Return unchanged if not camelCase

    # Apply all patterns
    modified_content = re.sub(pattern1, replace_func, content)
    modified_content = re.sub(pattern2, replace_func, modified_content)
    modified_content = re.sub(pattern3, replace_func, modified_content)
    modified_content = re.sub(pattern4, replace_func, modified_content)

    # Also handle method calls on objects (e.g., rng:randomNormal)
    method_pattern = r'([a-zA-Z0-9_]+):([a-z][a-zA-Z0-9_]*)'
    
    def replace_method(match):
        obj_name = match.group(1)
        method_name = match.group(2)
        
        if re.search(r'[a-z]', method_name) and re.search(r'[A-Z]', method_name):
            snake_method = camel_to_snake(method_name)
            return f'{obj_name}:{snake_method}'
        else:
            return match.group(0)
    
    modified_content = re.sub(method_pattern, replace_method, modified_content)

    # If changes were made and not a dry run, write the file
    if modified_content != content and not dry_run:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(modified_content)
        return True
    
    # For dry run, just report if changes would be made
    return modified_content != content

def find_lua_files(source_dir):
    """Find all .lua files in the given directory and subdirectories."""
    return list(Path(source_dir).glob('**/*.lua'))

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <love_source_directory> [--dry-run]")
        sys.exit(1)

    source_dir = sys.argv[1]
    dry_run = "--dry-run" in sys.argv

    if not os.path.isdir(source_dir):
        print(f"Error: {source_dir} is not a directory.")
        sys.exit(1)

    files = find_lua_files(source_dir)
    
    if not files:
        print(f"No .lua files found in {source_dir}")
        sys.exit(1)

    modified_count = 0
    
    print(f"Found {len(files)} .lua files")
    print(f"{'Analyzing' if dry_run else 'Processing'} files...")
    
    for file_path in files:
        modified = process_lua_file(file_path, dry_run)
        
        if modified:
            modified_count += 1
            file_str = str(file_path.relative_to(source_dir))
            if dry_run:
                print(f"Would modify: {file_str}")
            else:
                print(f"Modified: {file_str}")
    
    if dry_run:
        print(f"\nDry run complete. {modified_count} files would be modified.")
    else:
        print(f"\nConversion complete! Modified {modified_count} files.")

if __name__ == "__main__":
    main()

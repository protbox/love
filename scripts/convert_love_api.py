#!/usr/bin/env python3
"""
Comprehensive LÖVE Registration Table Converter
Converts camelCase function names in C++ registration tables to snake_case.
Handles both normal and underscore-prefixed function names.
Only modifies the string literals inside quotes, not the C++ function names.
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

def process_file(file_path, dry_run=False):
    """Process a single wrap_*.cpp file to convert registration tables."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find registration tables (luaL_Reg structures)
    # This pattern matches entries like: { "functionName", w_functionName } or { "_functionName", w__functionName }
    pattern = r'{\s*"((?:_)?[a-zA-Z][a-zA-Z0-9]*)"(\s*),\s*([a-zA-Z0-9_]+)\s*}'

    def replace_func(match):
        func_name = match.group(1)
        separator = match.group(2)
        cpp_func = match.group(3)
        
        # Only convert if the name is camelCase (has both lower and upper case)
        # Exclude the underscore prefix (if any) from the check
        check_name = func_name[1:] if func_name.startswith('_') else func_name
        if re.search(r'[a-z]', check_name) and re.search(r'[A-Z]', check_name):
            # Preserve leading underscore if present
            if func_name.startswith('_'):
                snake_name = '_' + camel_to_snake(func_name[1:])
            else:
                snake_name = camel_to_snake(func_name)
            return f'{{ "{snake_name}"{separator}, {cpp_func} }}'
        else:
            return match.group(0)  # Return unchanged if not camelCase

    modified_content = re.sub(pattern, replace_func, content)

    # If changes were made and not a dry run, write the file
    if modified_content != content and not dry_run:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(modified_content)
        return True
    
    # For dry run, just report if changes would be made
    return modified_content != content

def find_wrap_files(source_dir):
    """Find all wrap_*.cpp files in the given directory and subdirectories."""
    return list(Path(source_dir).glob('**/wrap_*.cpp'))

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <love_source_directory> [--dry-run]")
        sys.exit(1)

    source_dir = sys.argv[1]
    dry_run = "--dry-run" in sys.argv

    if not os.path.isdir(source_dir):
        print(f"Error: {source_dir} is not a directory.")
        sys.exit(1)

    files = find_wrap_files(source_dir)
    
    if not files:
        print(f"No wrap_*.cpp files found in {source_dir}")
        sys.exit(1)

    modified_count = 0
    
    print(f"Found {len(files)} wrap_*.cpp files")
    print(f"{'Analyzing' if dry_run else 'Processing'} files...")
    
    for file_path in files:
        modified = process_file(file_path, dry_run)
        
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

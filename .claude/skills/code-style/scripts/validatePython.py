#!/usr/bin/env python3
"""
**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: validatePython.py
Author: Jordan Yu
Date: 2024/11/07
Description:
    Validates Python files against RoyalTek coding standards
Notes:
    Checks for camelCase, file headers, and function documentation
**************************************************
"""

import sys
import re
import os
from pathlib import Path

# Validation rules
CAMEL_CASE_PATTERN = re.compile(r'^[a-z][a-zA-Z0-9]*$')
PASCAL_CASE_PATTERN = re.compile(r'^[A-Z][a-zA-Z0-9]*$')
UPPER_CASE_PATTERN = re.compile(r'^[A-Z][A-Z0-9_]*$')
FUNCTION_PATTERN = re.compile(r'^\s*def\s+([a-zA-Z_]\w*)\s*\(')
CLASS_PATTERN = re.compile(r'^\s*class\s+([a-zA-Z_]\w*)')
VARIABLE_PATTERN = re.compile(r'^\s*([a-zA-Z_]\w*)\s*=')

################################################
# Function Name: validateFile
# Author: Jordan Yu
# Date: 2024/11/07
# Description:
#     Validates a Python file against RoyalTek standards
# Parameters:
#     filePath (str) - Path to the Python file to validate
#     verbose (bool) - Whether to print detailed messages
# Return:
#     dict - Validation results with errors and warnings
# Notes:
#     Checks naming conventions, headers, and documentation
# Example:
#     results = validateFile("userManager.py", verbose=True)
################################################
def validateFile(filePath, verbose=False):
    # Parameter validation
    if not filePath or not os.path.exists(filePath):
        return {"errors": ["File not found"], "warnings": []}
    
    # Main logic
    errors = []
    warnings = []
    
    with open(filePath, 'r', encoding='utf-8') as file:
        content = file.read()
        lines = content.split('\n')
    
    # Check file header
    headerErrors = checkFileHeader(lines)
    errors.extend(headerErrors)
    
    # Check functions
    functionErrors = checkFunctions(lines)
    errors.extend(functionErrors)
    
    # Check naming conventions
    namingWarnings = checkNamingConventions(lines)
    warnings.extend(namingWarnings)
    
    if verbose:
        printResults(filePath, errors, warnings)
    
    # Return result
    return {
        "errors": errors,
        "warnings": warnings,
        "valid": len(errors) == 0
    }

################################################
# Function Name: checkFileHeader
# Author: Jordan Yu
# Date: 2024/11/07
# Description:
#     Checks if file has proper RoyalTek header
# Parameters:
#     lines (list) - List of file lines
# Return:
#     list - List of header-related errors
# Notes:
#     Looks for copyright and author information
# Example:
#     errors = checkFileHeader(fileLines)
################################################
def checkFileHeader(lines):
    # Parameter validation
    if not lines:
        return ["Empty file"]
    
    # Main logic
    errors = []
    headerFound = False
    
    # Check first 20 lines for header
    headerText = '\n'.join(lines[:20])
    
    if "RoyalTek Company Limited" not in headerText:
        errors.append("Missing RoyalTek copyright header")
    
    if "Author:" not in headerText:
        errors.append("Missing Author information in header")
    
    if "Date:" not in headerText:
        errors.append("Missing Date in header")
    
    if "File Name:" not in headerText:
        errors.append("Missing File Name in header")
    
    # Return result
    return errors

################################################
# Function Name: checkFunctions
# Author: Jordan Yu
# Date: 2024/11/07
# Description:
#     Checks if functions have proper documentation
# Parameters:
#     lines (list) - List of file lines
# Return:
#     list - List of function documentation errors
# Notes:
#     Ensures each function has RoyalTek format docs
# Example:
#     errors = checkFunctions(fileLines)
################################################
def checkFunctions(lines):
    # Parameter validation
    if not lines:
        return []
    
    # Main logic
    errors = []
    
    for i, line in enumerate(lines):
        match = FUNCTION_PATTERN.match(line)
        if match:
            functionName = match.group(1)
            
            # Check if function uses camelCase (except __special__)
            if not functionName.startswith('__'):
                if not CAMEL_CASE_PATTERN.match(functionName):
                    errors.append(f"Line {i+1}: Function '{functionName}' should use camelCase")
            
            # Check for documentation above function
            if i > 0:
                docFound = False
                for j in range(max(0, i-15), i):
                    if "Function Name:" in lines[j]:
                        docFound = True
                        break
                
                if not docFound:
                    errors.append(f"Line {i+1}: Function '{functionName}' missing documentation")
    
    # Return result
    return errors

################################################
# Function Name: checkNamingConventions
# Author: Jordan Yu
# Date: 2024/11/07
# Description:
#     Checks variable and class naming conventions
# Parameters:
#     lines (list) - List of file lines
# Return:
#     list - List of naming convention warnings
# Notes:
#     Warns about snake_case usage
# Example:
#     warnings = checkNamingConventions(fileLines)
################################################
def checkNamingConventions(lines):
    # Parameter validation
    if not lines:
        return []
    
    # Main logic
    warnings = []
    
    for i, line in enumerate(lines):
        # Check for snake_case variables
        if '_' in line and not line.strip().startswith('#'):
            # Check if it's a variable assignment
            varMatch = VARIABLE_PATTERN.match(line)
            if varMatch:
                varName = varMatch.group(1)
                if '_' in varName and not varName.isupper() and not varName.startswith('__'):
                    warnings.append(f"Line {i+1}: Variable '{varName}' uses snake_case (should use camelCase)")
        
        # Check class names
        classMatch = CLASS_PATTERN.match(line)
        if classMatch:
            className = classMatch.group(1)
            if not PASCAL_CASE_PATTERN.match(className):
                warnings.append(f"Line {i+1}: Class '{className}' should use PascalCase")
    
    # Return result
    return warnings

################################################
# Function Name: printResults
# Author: Jordan Yu
# Date: 2024/11/07
# Description:
#     Prints validation results in formatted output
# Parameters:
#     filePath (str) - Path to the validated file
#     errors (list) - List of errors found
#     warnings (list) - List of warnings found
# Return:
#     None
# Notes:
#     Uses colored output for better visibility
# Example:
#     printResults("test.py", errors, warnings)
################################################
def printResults(filePath, errors, warnings):
    # Parameter validation
    if not filePath:
        return
    
    # Main logic
    print("\n" + "="*50)
    print(f"RoyalTek Python Validator - {os.path.basename(filePath)}")
    print("="*50)
    
    if errors:
        print("\n❌ ERRORS:")
        for error in errors:
            print(f"  • {error}")
    
    if warnings:
        print("\n⚠️  WARNINGS:")
        for warning in warnings:
            print(f"  • {warning}")
    
    if not errors and not warnings:
        print("\n✅ File passes all RoyalTek standards!")
    
    print("="*50 + "\n")
    
    # Return result (None)

################################################
# Function Name: main
# Author: Jordan Yu
# Date: 2024/11/07
# Description:
#     Main entry point for the validator
# Parameters:
#     None - Uses command line arguments
# Return:
#     None
# Notes:
#     Exits with code 1 if validation fails
# Example:
#     python validatePython.py myfile.py
################################################
def main():
    # Parameter validation
    if len(sys.argv) < 2:
        print("Usage: python validatePython.py <file.py>")
        sys.exit(1)
    
    # Main logic
    filePath = sys.argv[1]
    verbose = "--verbose" in sys.argv or "-v" in sys.argv
    
    results = validateFile(filePath, verbose=True)
    
    # Return result
    if not results["valid"]:
        sys.exit(1)

if __name__ == "__main__":
    main()

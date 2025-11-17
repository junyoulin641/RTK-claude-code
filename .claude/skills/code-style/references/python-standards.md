# Python Implementation - RoyalTek Standards

## Follow PEP 8 - Use snake_case

Python follows PEP 8 conventions. RoyalTek adds mandatory file headers and function documentation.

### Variable and Function Names (PEP 8 Standard)
```python
# ✅ CORRECT - PEP 8 Standard
first_name = "John"
last_name = "Doe"
user_age = 25

def get_user_name(user_id):
    return user_name

def calculate_total(item_list):
    total_amount = 0
    for item in item_list:
        total_amount += item.price
    return total_amount

# ❌ WRONG - Not Python Standard
firstName = "John"   # Don't use camelCase for variables
getUserName()        # Don't use camelCase for functions
```

### Class Names - PascalCase (PEP 8 Standard)
```python
# ✅ CORRECT
class UserAccount:
    def __init__(self):
        self.account_id = None
        
class DatabaseManager:
    def connect_to_database(self):
        pass

# ❌ WRONG
class userAccount:    # Don't use lowercase
    pass
class User_Account:   # Don't use snake_case for classes
    pass
```

### File Header Format
```python
"""
**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: user_manager.py
Author: Jordan Yu
Date: 2024/11/07
Description:
    User management module for the application
Notes:
    Requires SQLAlchemy for database operations
**************************************************
"""
```

### Function Documentation Format
```python
################################################
# Function Name: get_user_by_id
# Author: Jordan Yu
# Date: 2024/11/07
# Description:
#     Retrieves user information from database by ID
# Parameters:
#     user_id (int) - The unique identifier of the user
#     include_details (bool) - Whether to include full details
# Return:
#     dict - User information dictionary
# Notes:
#     Returns None if user not found
# Example:
#     user = get_user_by_id(123, True)
################################################
def get_user_by_id(user_id, include_details=False):
    # Parameter validation
    if not user_id or user_id < 0:
        return None
    
    # Main logic
    user = database.query(User).filter_by(id=user_id).first()
    
    if user and include_details:
        user = enrich_user_data(user)
    
    # Return result
    return user
```

### Import Organization
```python
# Standard library imports
import os
import sys
from datetime import datetime

# Third-party imports
import numpy as np
import pandas as pd
from flask import Flask, request

# Local imports
from user_manager import UserAccount
from database_helper import DatabaseManager
```

### Error Handling
```python
def process_data(data_list):
    # Parameter validation
    if not data_list:
        raise ValueError("Data list cannot be empty")
    
    # Main logic
    try:
        processed_data = []
        for data_item in data_list:
            result = transform_data(data_item)
            processed_data.append(result)
    except Exception as error:
        print(f"❌ Error processing data: {str(error)}")
        return None
    
    # Return result
    return processed_data
```

### Common Patterns

#### Data Classes
```python
from dataclasses import dataclass

@dataclass
class ProductInfo:
    product_id: int
    product_name: str
    product_price: float
    stock_quantity: int = 0
    
    def get_total_value(self):
        return self.product_price * self.stock_quantity
```

#### Context Managers
```python
class DatabaseConnection:
    def __init__(self, connection_string):
        self.connection_string = connection_string
        self.connection = None
    
    def __enter__(self):
        self.connection = create_connection(self.connection_string)
        return self.connection
    
    def __exit__(self, exc_type, exc_value, traceback):
        if self.connection:
            self.connection.close()
```

#### Decorators
```python
def validate_input(validation_func):
    def decorator(func):
        def wrapper(*args, **kwargs):
            # Parameter validation
            if not validation_func(*args, **kwargs):
                raise ValueError("Invalid input parameters")
            
            # Main logic
            result = func(*args, **kwargs)
            
            # Return result
            return result
        return wrapper
    return decorator
```

### Testing Convention
```python
"""
**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: test_user_manager.py
Author: Jordan Yu
Date: 2024/11/07
Description:
    Unit tests for user management module
Notes:
    Uses pytest framework
**************************************************
"""

import pytest
from user_manager import get_user_by_id, create_user

class TestUserManager:
    
    def test_get_user_by_id(self):
        # Test data
        test_user_id = 123
        
        # Execute test
        result = get_user_by_id(test_user_id)
        
        # Verify result
        assert result is not None
        assert result['id'] == test_user_id
    
    def test_create_user(self):
        # Test data
        user_data = {
            'user_name': 'testUser',
            'user_email': 'test@royaltek.com'
        }
        
        # Execute test
        new_user = create_user(user_data)
        
        # Verify result
        assert new_user.user_id > 0
        assert new_user.user_name == user_data['user_name']
```

## Configuration Files

### pyproject.toml
```toml
[tool.black]
line-length = 100
skip-string-normalization = true

[tool.pylint]
max-line-length = 100

[tool.mypy]
python_version = "3.9"
warn_return_any = true
```

### .pylintrc
```ini
[BASIC]
# Follow PEP 8 naming conventions
variable-rgx=[a-z_][a-z0-9_]{2,30}$
function-rgx=[a-z_][a-z0-9_]{2,30}$
method-rgx=[a-z_][a-z0-9_]{2,30}$
class-rgx=[A-Z][a-zA-Z0-9]+$
const-rgx=[A-Z_][A-Z0-9_]+$
```

## IDE Configuration

### VS Code settings.json
```json
{
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "python.formatting.blackArgs": [
        "--line-length=100"
    ]
}
```

## Common Violations to Avoid

1. **Using camelCase for variables/functions**: `userName` → Use `user_name`
2. **Using ALL_CAPS for non-constants**: `USER_ACCOUNT` → Use `UserAccount` (class) or `user_account` (variable)
3. **Missing file header**: Always include RoyalTek copyright header
4. **Missing function documentation**: Every function needs full documentation
5. **Not following three-part structure**: Always use validation → logic → return
6. **Improper main function structure**: Use proper main function
```python
# ✅ CORRECT
def main():
    # Main execution logic
    pass

if __name__ == "__main__":
    main()
```

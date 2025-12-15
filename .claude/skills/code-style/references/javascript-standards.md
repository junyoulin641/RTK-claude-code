# JavaScript/TypeScript Implementation - RoyalTek Standards

## Naming Convention - Hungarian Notation

JavaScript/TypeScript follows Hungarian notation for variables, similar to C/C++.

### Variable Type Prefixes

| Type | Prefix | Example |
|------|--------|---------|
| string | sz | szUserName |
| number (int) | i | iUserAge |
| number (float) | f | fPrice |
| boolean | b | bIsActive |
| array | a | aItems |
| object | o | oUserData |
| function | fn | fnCallback |
| Date | dt | dtCreatedDate |
| Promise | p | pUserData |

### Naming Examples

```javascript
//  CORRECT - Hungarian notation + camelCase
let szUserName = "John";
let iUserAge = 25;
let fPrice = 99.99;
let bIsActive = true;
let aItems = [1, 2, 3];
let oUserData = { name: "John" };
let dtCreatedDate = new Date();

function processUser(szName, iAge) {
    return { szName, iAge };
}

//  WRONG - No type prefix
let userName = "John";    // Missing 'sz' prefix
let userAge = 25;         // Missing 'i' prefix
let isActive = true;      // Missing 'b' prefix
```

## JavaScript Specific Guidelines

### File Header Format
```javascript
/**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: userManager.js
Author: Jordan Yu
Date: 2024/11/07
Description:
    User management module for web application
Notes:
    Requires axios for HTTP requests
***************************************************/
```

### Function Documentation
```javascript
/************************************************
Function Name: getUserById
Author: Jordan Yu
Date: 2024/11/07
Description:
    Retrieves user information from API by ID
Parameters:
    iUserId (number) - The unique identifier of the user
    bIncludeDetails (boolean) - Whether to include full details
Return:
    Promise<Object> - User information object
Notes:
    Returns null if user not found
Example:
    const oUser = await getUserById(123, true);
************************************************/
async function getUserById(iUserId, bIncludeDetails = false) {
    // Parameter validation
    if (!iUserId || iUserId < 0) {
        return null;
    }
    
    // Main logic
    try {
        const oResponse = await axios.get(`/api/users/${iUserId}`);
        let oUserData = oResponse.data;
        
        if (bIncludeDetails) {
            oUserData = await enrichUserData(oUserData);
        }
        
        // Return result
        return oUserData;
    } catch (oError) {
        console.error(' Error fetching user:', oError);
        return null;
    }
}
```

### Class Definition
```javascript
class UserAccount {
    /************************************************
    Function Name: constructor
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Initializes a new UserAccount instance
    Parameters:
        iUserId (number) - User identifier
        szUserName (string) - User's display name
    Return:
        None - Constructor
    Notes:
        Sets default values for optional properties
    ************************************************/
    constructor(iUserId, szUserName) {
        // Parameter validation
        if (!iUserId || !szUserName) {
            throw new Error('iUserId and szUserName are required');
        }
        
        // Main logic
        this.iUserId = iUserId;
        this.szUserName = szUserName;
        this.dtCreatedDate = new Date();
        this.bIsActive = true;
    }
    
    /************************************************
    Function Name: updateProfile
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Updates user profile information
    Parameters:
        oProfileData (Object) - Profile data to update
    Return:
        boolean - True if update successful
    ************************************************/
    updateProfile(oProfileData) {
        // Parameter validation
        if (!oProfileData || typeof oProfileData !== 'object') {
            return false;
        }
        
        // Main logic
        Object.assign(this, oProfileData);
        this.dtLastModified = new Date();
        
        // Return result
        return true;
    }
}
```

## TypeScript Specific Guidelines

### Type Definitions
```typescript
// Use PascalCase for types and interfaces
// Interface properties use Hungarian notation
interface UserData {
    iUserId: number;
    szUserName: string;
    szUserEmail: string;
    bIsActive: boolean;
}

type UserRole = 'admin' | 'user' | 'guest';

enum StatusCode {
    SUCCESS = 200,
    NOT_FOUND = 404,
    SERVER_ERROR = 500
}
```

### TypeScript Function with Types
```typescript
/************************************************
Function Name: processUserData
Author: Jordan Yu
Date: 2024/11/07
Description:
    Processes and validates user data
Parameters:
    oUserData (UserData) - Raw user data object
    aValidationRules (ValidationRule[]) - Array of validation rules
Return:
    ProcessedUser | null - Processed user or null if invalid
Notes:
    Performs data transformation and validation
Example:
    const oProcessed = processUserData(oRawData, aRules);
************************************************/
function processUserData(
    oUserData: UserData, 
    aValidationRules: ValidationRule[]
): ProcessedUser | null {
    // Parameter validation
    if (!oUserData || !aValidationRules) {
        return null;
    }
    
    // Main logic
    const aErrors = validateData(oUserData, aValidationRules);
    if (aErrors.length > 0) {
        console.error(' Validation errors:', aErrors);
        return null;
    }
    
    const oProcessedUser: ProcessedUser = {
        ...oUserData,
        dtProcessedAt: new Date(),
        bValidationPassed: true
    };
    
    // Return result
    return oProcessedUser;
}
```

### TypeScript Class
```typescript
class DatabaseManager {
    private szConnectionString: string;
    private bIsConnected: boolean = false;
    
    /************************************************
    Function Name: constructor
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Initializes database manager
    Parameters:
        szConnectionString (string) - Database connection string
    Return:
        None - Constructor
    ************************************************/
    constructor(szConnectionString: string) {
        // Parameter validation
        if (!szConnectionString) {
            throw new Error('Connection string required');
        }
        
        // Main logic
        this.szConnectionString = szConnectionString;
    }
    
    /************************************************
    Function Name: connect
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Establishes database connection
    Parameters:
        None
    Return:
        Promise<boolean> - Connection success status
    ************************************************/
    async connect(): Promise<boolean> {
        // Parameter validation (none needed)
        
        // Main logic
        try {
            await this.establishConnection();
            this.bIsConnected = true;
            
            // Return result
            return true;
        } catch (oError) {
            console.error(' Connection failed:', oError);
            return false;
        }
    }
}
```

## Modern JavaScript Patterns

### Arrow Functions (with Hungarian notation)
```javascript
//  CORRECT - Using Hungarian notation
const fnCalculateTotal = (aItemList) => {
    // Parameter validation
    if (!aItemList || !Array.isArray(aItemList)) {
        return 0;
    }
    
    // Main logic
    const fTotalAmount = aItemList.reduce((fSum, oItem) => fSum + oItem.fPrice, 0);
    
    // Return result
    return fTotalAmount;
};

//  WRONG - No type prefix
const calculateTotal = (itemList) => {  // Missing prefixes
    // ...
};
```

### Async/Await Pattern
```javascript
async function fetchUserData(iUserId) {
    // Parameter validation
    if (!iUserId) {
        throw new Error('iUserId is required');
    }
    
    // Main logic
    try {
        const oUserData = await getUserById(iUserId);
        const aPermissions = await getUserPermissions(iUserId);
        
        const oCompleteUser = {
            ...oUserData,
            aPermissions
        };
        
        // Return result
        return oCompleteUser;
    } catch (oError) {
        console.error(' Error fetching user data:', oError);
        throw oError;
    }
}
```

### Module Exports

#### CommonJS
```javascript
// userManager.js
module.exports = {
    getUserById,
    createUser,
    updateUser,
    deleteUser
};
```

#### ES6 Modules
```javascript
// Named exports
export { getUserById, createUser, updateUser };

// Default export
export default UserManager;

// Import examples
import UserManager from './UserManager';
import { getUserById, createUser } from './userUtils';
```

## React/JSX Guidelines

### Component Structure
```jsx
/**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: UserProfile.jsx
Author: Jordan Yu
Date: 2024/11/07
Description:
    User profile display component
Notes:
    Uses React Hooks for state management
***************************************************/

import React, { useState, useEffect } from 'react';

/************************************************
Function Name: UserProfile
Author: Jordan Yu
Date: 2024/11/07
Description:
    Displays user profile information
Parameters:
    iUserId (number) - User identifier
    bShowDetails (boolean) - Show detailed view
Return:
    JSX.Element - Rendered component
************************************************/
function UserProfile({ iUserId, bShowDetails = false }) {
    // State management
    const [oUserData, setUserData] = useState(null);
    const [bIsLoading, setIsLoading] = useState(true);
    
    // Effect hook
    useEffect(() => {
        loadUserData();
    }, [iUserId]);
    
    /************************************************
    Function Name: loadUserData
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Loads user data from API
    Parameters:
        None
    Return:
        Promise<void>
    ************************************************/
    const loadUserData = async () => {
        // Parameter validation
        if (!iUserId) return;
        
        // Main logic
        setIsLoading(true);
        try {
            const oData = await getUserById(iUserId);
            setUserData(oData);
        } catch (oError) {
            console.error(' Failed to load user:', oError);
        } finally {
            setIsLoading(false);
        }
    };
    
    // Render
    if (bIsLoading) return <div>Loading...</div>;
    if (!oUserData) return <div>User not found</div>;
    
    return (
        <div className="userProfile">
            <h2>{oUserData.szUserName}</h2>
            {bShowDetails && (
                <div className="userDetails">
                    <p>Email: {oUserData.szUserEmail}</p>
                    <p>Joined: {oUserData.dtJoinDate}</p>
                </div>
            )}
        </div>
    );
}

export default UserProfile;
```

## Configuration Files

### .eslintrc.json
```json
{
    "env": {
        "browser": true,
        "es2021": true,
        "node": true
    },
    "extends": [
        "eslint:recommended"
    ],
    "parserOptions": {
        "ecmaVersion": 12,
        "sourceType": "module"
    },
    "rules": {
        "camelcase": ["error", {
            "properties": "always"
        }],
        "no-underscore-dangle": "error",
        "prefer-const": "error",
        "no-var": "error"
    }
}
```

### tsconfig.json
```json
{
    "compilerOptions": {
        "target": "ES2020",
        "module": "commonjs",
        "strict": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true,
        "declaration": true,
        "outDir": "./dist"
    },
    "include": ["src/**/*"],
    "exclude": ["node_modules", "dist"]
}
```

## Testing Convention

### Jest Tests
```javascript
/**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: userManager.test.js
Author: Jordan Yu
Date: 2024/11/07
Description:
    Unit tests for user management functions
Notes:
    Uses Jest testing framework
***************************************************/

describe('UserManager', () => {
    describe('getUserById', () => {
        test('should return user when valid ID provided', async () => {
            // Test data
            const iTestUserId = 123;
            
            // Execute test
            const oResult = await getUserById(iTestUserId);
            
            // Verify result
            expect(oResult).toBeDefined();
            expect(oResult.iUserId).toBe(iTestUserId);
        });
        
        test('should return null for invalid ID', async () => {
            // Test data
            const iInvalidId = -1;
            
            // Execute test
            const oResult = await getUserById(iInvalidId);
            
            // Verify result
            expect(oResult).toBeNull();
        });
    });
});
```

## Common Violations to Avoid

1. **Missing Hungarian notation prefix**: `userName` → Use `szUserName`
2. **Using snake_case**: `user_name` → Use `szUserName`
3. **Using kebab-case in JS**: `user-name` → Use `szUserName`
4. **Missing function documentation**: Every function needs RoyalTek format docs
5. **Inconsistent async patterns**: Use async/await consistently
6. **Missing error handling**: Always handle errors appropriately
7. **Not using three-part structure**: validation → logic → return

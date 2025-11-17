# C/C++ Implementation - RoyalTek Standards

## File Header Format

```cpp
/**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: UserManager.cpp
Author: Jordan Yu
Date: 2024/11/07
Description:
    User management implementation for system
Notes:
    Requires C++17 or later
***************************************************/
```

## Header Files (.h/.hpp)

```cpp
#ifndef ROYALTEK_USER_MANAGER_H
#define ROYALTEK_USER_MANAGER_H

#include <string>
#include <vector>
#include <memory>

// Constants
const int MAX_USERS = 1000;
const int DEFAULT_TIMEOUT = 30;

/************************************************
Class Name: UserManager
Author: Jordan Yu
Date: 2024/11/07
Description:
    Manages user accounts and authentication
Notes:
    Thread-safe implementation
************************************************/
class UserManager {
private:
    int userCount;
    std::vector<User> userList;
    
public:
    /************************************************
    Function Name: UserManager (Constructor)
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Initializes the UserManager instance
    Parameters:
        configPath (const std::string&) - Configuration file path
    Return:
        None - Constructor
    Notes:
        Throws exception if config invalid
    Example:
        UserManager manager("./config.json");
    ************************************************/
    explicit UserManager(const std::string& configPath);
    
    /************************************************
    Function Name: getUserById
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Retrieves user by unique identifier
    Parameters:
        userId (int) - User's unique ID
    Return:
        User* - Pointer to user object or nullptr
    Notes:
        Returns nullptr if user not found
    Example:
        User* user = manager.getUserById(123);
    ************************************************/
    User* getUserById(int userId);
    
    /************************************************
    Function Name: createUser
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Creates a new user account
    Parameters:
        userName (const std::string&) - Username
        userEmail (const std::string&) - Email address
    Return:
        bool - True if creation successful
    Notes:
        Validates input before creation
    Example:
        bool success = manager.createUser("john", "john@royaltek.com");
    ************************************************/
    bool createUser(const std::string& userName, 
                   const std::string& userEmail);
};

#endif // ROYALTEK_USER_MANAGER_H
```

## Implementation Files (.cpp)

```cpp
/**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: UserManager.cpp
Author: Jordan Yu
Date: 2024/11/07
Description:
    Implementation of UserManager class
Notes:
    Uses RAII for resource management
***************************************************/

#include "UserManager.h"
#include <iostream>
#include <fstream>
#include <algorithm>

/************************************************
Function Name: UserManager::UserManager
Author: Jordan Yu
Date: 2024/11/07
Description:
    Constructor implementation
Parameters:
    configPath (const std::string&) - Config file path
Return:
    None - Constructor
Notes:
    Initializes member variables
************************************************/
UserManager::UserManager(const std::string& configPath) 
    : userCount(0) {
    // Parameter validation
    if (configPath.empty()) {
        throw std::invalid_argument("Config path cannot be empty");
    }
    
    // Main logic
    loadConfiguration(configPath);
    initializeDatabase();
    
    // Constructor doesn't return
}

/************************************************
Function Name: getUserById
Author: Jordan Yu
Date: 2024/11/07
Description:
    Finds and returns user by ID
Parameters:
    userId (int) - User identifier
Return:
    User* - Pointer to user or nullptr
Notes:
    Thread-safe operation
Example:
    User* user = getUserById(100);
************************************************/
User* UserManager::getUserById(int userId) {
    // Parameter validation
    if (userId <= 0) {
        return nullptr;
    }
    
    // Main logic
    auto iterator = std::find_if(
        userList.begin(), 
        userList.end(),
        [userId](const User& user) {
            return user.userId == userId;
        }
    );
    
    // Return result
    if (iterator != userList.end()) {
        return &(*iterator);
    }
    return nullptr;
}

/************************************************
Function Name: processUserData
Author: Jordan Yu
Date: 2024/11/07
Description:
    Process user data with validation
Parameters:
    userData (const UserData&) - User data structure
    options (ProcessOptions) - Processing options
Return:
    ProcessResult - Result of processing
Notes:
    Uses move semantics for efficiency
Example:
    ProcessResult result = processUserData(data, options);
************************************************/
ProcessResult processUserData(const UserData& userData, 
                             ProcessOptions options) {
    // Parameter validation
    if (!validateUserData(userData)) {
        return ProcessResult{false, "Invalid data"};
    }
    
    // Main logic
    ProcessResult result;
    
    try {
        // Transform data
        TransformedData transformed = transformData(userData);
        
        // Apply options
        if (options.encrypt) {
            transformed = encryptData(std::move(transformed));
        }
        
        // Store result
        result.success = true;
        result.data = std::move(transformed);
        
    } catch (const std::exception& error) {
        result.success = false;
        result.errorMessage = error.what();
    }
    
    // Return result
    return result;
}
```

## Template Functions

```cpp
/************************************************
Function Name: findItemInContainer
Author: Jordan Yu
Date: 2024/11/07
Description:
    Generic function to find item in container
Parameters:
    container (const Container&) - Container to search
    predicate (Predicate) - Search condition
Return:
    Iterator - Iterator to found item or end()
Notes:
    Template function for any container type
Example:
    auto it = findItemInContainer(vec, [](int x){ return x > 10; });
************************************************/
template<typename Container, typename Predicate>
auto findItemInContainer(const Container& container, 
                        Predicate predicate) 
    -> decltype(container.begin()) {
    // Parameter validation (compile-time)
    static_assert(
        std::is_invocable_v<Predicate, 
                           decltype(*container.begin())>,
        "Predicate must be callable with container element type"
    );
    
    // Main logic
    auto result = std::find_if(
        container.begin(), 
        container.end(), 
        predicate
    );
    
    // Return result
    return result;
}
```

## Naming Conventions

### Variables and Functions: camelCase
```cpp
int userAge = 25;              // ✅ Correct
std::string firstName = "John"; // ✅ Correct

int user_age = 25;              // ❌ Wrong (no snake_case)
std::string first_name = "John"; // ❌ Wrong
```

### Classes and Structs: PascalCase
```cpp
class UserAccount { };          // ✅ Correct
struct DatabaseConfig { };      // ✅ Correct

class user_account { };         // ❌ Wrong
struct database_config { };     // ❌ Wrong
```

### Constants and Macros: UPPER_CASE
```cpp
#define MAX_BUFFER_SIZE 1024    // ✅ Correct
const int DEFAULT_PORT = 8080;  // ✅ Correct

#define MaxBufferSize 1024      // ❌ Wrong
const int defaultPort = 8080;   // ❌ Wrong (for constants)
```

## Memory Management

```cpp
/************************************************
Function Name: createUserObject
Author: Jordan Yu
Date: 2024/11/07
Description:
    Creates user object with smart pointer
Parameters:
    userName (const std::string&) - User name
Return:
    std::unique_ptr<User> - Smart pointer to user
Notes:
    Uses RAII for automatic cleanup
Example:
    auto user = createUserObject("John");
************************************************/
std::unique_ptr<User> createUserObject(const std::string& userName) {
    // Parameter validation
    if (userName.empty()) {
        return nullptr;
    }
    
    // Main logic
    auto user = std::make_unique<User>();
    user->name = userName;
    user->createdAt = std::chrono::system_clock::now();
    
    // Return result
    return user;
}
```

## Error Handling

```cpp
/************************************************
Function Name: readFileContent
Author: Jordan Yu
Date: 2024/11/07
Description:
    Reads content from file with error handling
Parameters:
    filePath (const std::string&) - File path
    content (std::string&) - Output content
Return:
    bool - True if successful
Notes:
    Uses RAII for file handling
Example:
    std::string content;
    if (readFileContent("data.txt", content)) { }
************************************************/
bool readFileContent(const std::string& filePath, 
                    std::string& content) {
    // Parameter validation
    if (filePath.empty()) {
        std::cerr << "❌ Error: Empty file path" << std::endl;
        return false;
    }
    
    // Main logic
    std::ifstream fileStream(filePath);
    if (!fileStream.is_open()) {
        std::cerr << "❌ Error: Cannot open file: " << filePath << std::endl;
        return false;
    }
    
    try {
        std::stringstream buffer;
        buffer << fileStream.rdbuf();
        content = buffer.str();
        
        // Return result
        return true;
        
    } catch (const std::exception& error) {
        std::cerr << "❌ Error reading file: " << error.what() << std::endl;
        return false;
    }
}
```

## Modern C++ Features (C++17/20)

```cpp
// Structured bindings (C++17)
auto [success, errorMessage] = processData(input);

// Optional returns (C++17)
std::optional<User> findUser(int userId) {
    // Parameter validation
    if (userId <= 0) {
        return std::nullopt;
    }
    
    // Main logic
    if (auto* user = getUserById(userId)) {
        return *user;
    }
    
    // Return result
    return std::nullopt;
}

// Concepts (C++20)
template<typename T>
concept Numeric = std::is_arithmetic_v<T>;

template<Numeric T>
T calculateAverage(const std::vector<T>& values) {
    // Implementation
}
```

## CMakeLists.txt Example

```cmake
cmake_minimum_required(VERSION 3.10)
project(RoyalTekProject)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Compiler flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic")

# Source files
set(SOURCES
    src/UserManager.cpp
    src/DatabaseManager.cpp
    src/main.cpp
)

# Header files
set(HEADERS
    include/UserManager.h
    include/DatabaseManager.h
)

# Create executable
add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS})

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE include)

# Link libraries
target_link_libraries(${PROJECT_NAME} PRIVATE pthread)
```

## Common Violations to Avoid

1. **Using snake_case**: `user_name` → Use `userName`
2. **Using Hungarian notation**: `szName`, `nCount` → Use `name`, `count`
3. **Missing function documentation**: Every function needs RoyalTek format docs
4. **Not using RAII**: Always use smart pointers and RAII
5. **Missing header guards**: Always use include guards or `#pragma once`
6. **Not following three-part structure**: validation → logic → return

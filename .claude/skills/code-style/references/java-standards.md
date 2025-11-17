# Java Implementation - RoyalTek Standards

## Naming Convention - Hungarian Notation

Java follows Hungarian notation for variables, similar to C/C++.

### Variable Type Prefixes

| Type | Prefix | Example |
|------|--------|---------|
| String | sz | szUserName |
| int | i | iUserAge |
| long | l | lTimestamp |
| float | f | fPrice |
| double | d | dTotal |
| boolean | b | bIsActive |
| List/ArrayList | a | aItems |
| Map | m | mUserMap |
| Object | o | oUserData |
| Date | dt | dtCreatedDate |

### Naming Examples

```java
// ✅ CORRECT - Hungarian notation
String szUserName = "John";
int iUserAge = 25;
float fPrice = 99.99f;
boolean bIsActive = true;
List<String> aItems = new ArrayList<>();
Map<Integer, User> mUserMap = new HashMap<>();
Date dtCreatedDate = new Date();

public User getUserById(int iUserId) {
    return userRepository.findById(iUserId);
}

// ❌ WRONG - No type prefix
String userName = "John";     // Missing 'sz' prefix
int userAge = 25;             // Missing 'i' prefix
boolean isActive = true;      // Missing 'b' prefix
```

## File Header Format

```java
/**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: UserManager.java
Author: Jordan Yu
Date: 2024/11/07
Description:
    User management service for the application
Notes:
    Requires Java 11 or later
***************************************************/
```

## Package and Import Organization

```java
package com.royaltek.usermanagement;

// Java standard library
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

// Third-party libraries
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;

// Project imports
import com.royaltek.common.BaseService;
import com.royaltek.models.User;
import com.royaltek.exceptions.UserNotFoundException;
```

## Class Definition

```java
/**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: UserManager.java
Author: Jordan Yu
Date: 2024/11/07
Description:
    Service class for managing user operations
Notes:
    Thread-safe implementation using synchronized methods
***************************************************/

package com.royaltek.services;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/************************************************
Class Name: UserManager
Author: Jordan Yu
Date: 2024/11/07
Description:
    Manages user accounts and authentication
Notes:
    Singleton pattern implementation
************************************************/
@Service
public class UserManager {
    
    // Constants
    private static final int I_MAX_USERS = 1000;
    private static final int I_DEFAULT_TIMEOUT = 30;
    
    // Instance variables (use Hungarian notation)
    private final Map<Integer, User> mUserMap;
    private final DatabaseManager oDatabaseManager;
    private int iActiveUserCount;
    private boolean bIsInitialized;
    
    /************************************************
    Function Name: UserManager (Constructor)
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Initializes the UserManager service
    Parameters:
        oDatabaseManager (DatabaseManager) - Database access manager
    Return:
        None - Constructor
    Notes:
        Autowired by Spring framework
    Example:
        // Automatically injected by Spring
    ************************************************/
    @Autowired
    public UserManager(DatabaseManager oDatabaseManager) {
        // Parameter validation
        if (oDatabaseManager == null) {
            throw new IllegalArgumentException("DatabaseManager cannot be null");
        }
        
        // Main logic
        this.oDatabaseManager = oDatabaseManager;
        this.mUserMap = new ConcurrentHashMap<>();
        this.iActiveUserCount = 0;
        this.bIsInitialized = false;
    }
    
    /************************************************
    Function Name: getUserById
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Retrieves user by unique identifier
    Parameters:
        iUserId (int) - User's unique ID
    Return:
        Optional<User> - User if found, empty otherwise
    Notes:
        Thread-safe operation
    Example:
        Optional<User> oUser = userManager.getUserById(123);
    ************************************************/
    public Optional<User> getUserById(int iUserId) {
        // Parameter validation
        if (iUserId <= 0) {
            return Optional.empty();
        }
        
        // Main logic
        User oUser = mUserMap.get(iUserId);
        if (oUser == null) {
            oUser = oDatabaseManager.findUserById(iUserId);
            if (oUser != null) {
                mUserMap.put(iUserId, oUser);
            }
        }
        
        // Return result
        return Optional.ofNullable(oUser);
    }
    
    /************************************************
    Function Name: createUser
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Creates a new user account
    Parameters:
        szUserName (String) - Username
        szUserEmail (String) - Email address
    Return:
        User - Created user object
    Notes:
        Throws exception if user exists
    Example:
        User oNewUser = userManager.createUser("john", "john@royaltek.com");
    ************************************************/
    public User createUser(String szUserName, String szUserEmail) 
            throws UserAlreadyExistsException {
        // Parameter validation
        validateUserInput(szUserName, szUserEmail);
        
        // Main logic
        User oNewUser = new User(szUserName, szUserEmail);
        oNewUser = oDatabaseManager.saveUser(oNewUser);
        mUserMap.put(oNewUser.getIUserId(), oNewUser);
        iActiveUserCount++;
        
        // Return result
        return oNewUser;
    }
        synchronized(this) {
            if (userExists(userName)) {
                throw new UserAlreadyExistsException(
                    "User already exists: " + userName
                );
            }
            
            User newUser = new User();
            newUser.setUserName(userName);
            newUser.setUserEmail(userEmail);
            newUser.setCreatedDate(new Date());
            
            int userId = databaseManager.saveUser(newUser);
            newUser.setUserId(userId);
            
            userMap.put(userId, newUser);
            activeUserCount++;
            
            // Return result
            return newUser;
        }
    }
    
    /************************************************
    Function Name: validateUserInput
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Validates user input parameters
    Parameters:
        userName (String) - Username to validate
        userEmail (String) - Email to validate
    Return:
        void
    Notes:
        Throws IllegalArgumentException if invalid
    Example:
        validateUserInput("john", "john@royaltek.com");
    ************************************************/
    private void validateUserInput(String userName, String userEmail) {
        // Parameter validation
        if (userName == null || userName.trim().isEmpty()) {
            throw new IllegalArgumentException("Username cannot be empty");
        }
        
        if (userEmail == null || !userEmail.contains("@")) {
            throw new IllegalArgumentException("Invalid email address");
        }
        
        // Main logic
        if (userName.length() < 3 || userName.length() > 50) {
            throw new IllegalArgumentException(
                "Username must be between 3 and 50 characters"
            );
        }
        
        // Return result (void)
    }
}
```

## Interface Definition

```java
/************************************************
Interface Name: UserService
Author: Jordan Yu
Date: 2024/11/07
Description:
    Interface for user service operations
Notes:
    Implemented by UserManager
************************************************/
public interface UserService {
    
    /************************************************
    Function Name: authenticateUser
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Authenticates user credentials
    Parameters:
        userName (String) - Username
        password (String) - User password
    Return:
        boolean - True if authentication successful
    ************************************************/
    boolean authenticateUser(String userName, String password);
    
    /************************************************
    Function Name: updateUserProfile
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Updates user profile information
    Parameters:
        userId (int) - User ID
        profileData (Map<String, Object>) - Profile data
    Return:
        User - Updated user object
    ************************************************/
    User updateUserProfile(int userId, Map<String, Object> profileData);
}
```

## Enum Definition

```java
/************************************************
Enum Name: UserRole
Author: Jordan Yu
Date: 2024/11/07
Description:
    Defines user roles in the system
Notes:
    Used for authorization
************************************************/
public enum UserRole {
    ADMIN("Administrator", 100),
    MANAGER("Manager", 50),
    USER("Regular User", 10),
    GUEST("Guest", 1);
    
    private final String displayName;
    private final int permissionLevel;
    
    /************************************************
    Function Name: UserRole (Constructor)
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Initializes user role enum
    Parameters:
        displayName (String) - Display name
        permissionLevel (int) - Permission level
    ************************************************/
    UserRole(String displayName, int permissionLevel) {
        this.displayName = displayName;
        this.permissionLevel = permissionLevel;
    }
    
    public String getDisplayName() {
        return displayName;
    }
    
    public int getPermissionLevel() {
        return permissionLevel;
    }
}
```

## Generic Methods

```java
/************************************************
Function Name: processDataList
Author: Jordan Yu
Date: 2024/11/07
Description:
    Generic method to process list of data
Parameters:
    dataList (List<T>) - List of data items
    processor (Function<T, R>) - Processing function
Return:
    List<R> - List of processed items
Notes:
    Uses Java 8 functional programming
Example:
    List<String> names = processDataList(users, User::getUserName);
************************************************/
public <T, R> List<R> processDataList(List<T> dataList, 
                                      Function<T, R> processor) {
    // Parameter validation
    if (dataList == null || processor == null) {
        return Collections.emptyList();
    }
    
    // Main logic
    List<R> resultList = new ArrayList<>();
    
    for (T item : dataList) {
        try {
            R processed = processor.apply(item);
            resultList.add(processed);
        } catch (Exception error) {
            System.err.println("❌ Error processing item: " + error.getMessage());
        }
    }
    
    // Return result
    return resultList;
}
```

## Lambda and Stream API Usage

```java
/************************************************
Function Name: filterActiveUsers
Author: Jordan Yu
Date: 2024/11/07
Description:
    Filters and returns active users
Parameters:
    userList (List<User>) - List of all users
    minActivityDays (int) - Minimum activity days
Return:
    List<User> - List of active users
Notes:
    Uses Java 8 Stream API
Example:
    List<User> activeUsers = filterActiveUsers(allUsers, 30);
************************************************/
public List<User> filterActiveUsers(List<User> userList, int minActivityDays) {
    // Parameter validation
    if (userList == null || minActivityDays < 0) {
        return Collections.emptyList();
    }
    
    // Main logic
    LocalDate cutoffDate = LocalDate.now().minusDays(minActivityDays);
    
    List<User> activeUsers = userList.stream()
        .filter(user -> user != null)
        .filter(user -> user.getLastActivityDate() != null)
        .filter(user -> user.getLastActivityDate().isAfter(cutoffDate))
        .sorted(Comparator.comparing(User::getLastActivityDate).reversed())
        .collect(Collectors.toList());
    
    // Return result
    return activeUsers;
}
```

## Exception Handling

```java
/************************************************
Function Name: performDatabaseOperation
Author: Jordan Yu
Date: 2024/11/07
Description:
    Performs database operation with retry logic
Parameters:
    operation (Supplier<T>) - Database operation
    maxRetries (int) - Maximum retry attempts
Return:
    T - Result of the operation
Notes:
    Implements exponential backoff
Example:
    User user = performDatabaseOperation(() -> db.getUser(id), 3);
************************************************/
public <T> T performDatabaseOperation(Supplier<T> operation, int maxRetries) 
        throws DatabaseException {
    // Parameter validation
    if (operation == null || maxRetries < 0) {
        throw new IllegalArgumentException("Invalid parameters");
    }
    
    // Main logic
    int retryCount = 0;
    Exception lastException = null;
    
    while (retryCount <= maxRetries) {
        try {
            T result = operation.get();
            
            // Return result
            return result;
            
        } catch (Exception error) {
            lastException = error;
            retryCount++;
            
            if (retryCount <= maxRetries) {
                int delayMs = (int) Math.pow(2, retryCount) * 1000;
                System.out.println("⚠️ Retry " + retryCount + "/" + maxRetries + 
                                 " after " + delayMs + "ms");
                
                try {
                    Thread.sleep(delayMs);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    throw new DatabaseException("Operation interrupted", ie);
                }
            }
        }
    }
    
    throw new DatabaseException("Operation failed after " + maxRetries + 
                               " retries", lastException);
}
```

## Unit Testing with JUnit 5

```java
/**************************************************
*      RoyalTek Company Limited                  *
*      Copyright 2024 RoyalTek Co., Ltd.         *
*      All Rights Reserved                       *
**************************************************
File Name: UserManagerTest.java
Author: Jordan Yu
Date: 2024/11/07
Description:
    Unit tests for UserManager class
Notes:
    Uses JUnit 5 and Mockito
***************************************************/

package com.royaltek.services;

import org.junit.jupiter.api.*;
import org.mockito.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class UserManagerTest {
    
    @Mock
    private DatabaseManager databaseManager;
    
    private UserManager userManager;
    
    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        userManager = new UserManager(databaseManager);
    }
    
    /************************************************
    Function Name: testGetUserById
    Author: Jordan Yu
    Date: 2024/11/07
    Description:
        Tests getUserById method
    Parameters:
        None
    Return:
        void
    Notes:
        Tests both success and failure cases
    ************************************************/
    @Test
    void testGetUserById() {
        // Test data
        int testUserId = 123;
        User mockUser = new User();
        mockUser.setUserId(testUserId);
        mockUser.setUserName("testUser");
        
        // Mock behavior
        when(databaseManager.findUserById(testUserId)).thenReturn(mockUser);
        
        // Execute test
        Optional<User> result = userManager.getUserById(testUserId);
        
        // Verify result
        assertTrue(result.isPresent());
        assertEquals(testUserId, result.get().getUserId());
        verify(databaseManager, times(1)).findUserById(testUserId);
    }
    
    @Test
    void testCreateUserWithInvalidInput() {
        // Test data
        String invalidUserName = "";
        String invalidEmail = "notanemail";
        
        // Execute test & Verify
        assertThrows(IllegalArgumentException.class, () -> {
            userManager.createUser(invalidUserName, invalidEmail);
        });
    }
}
```

## Maven pom.xml Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.royaltek</groupId>
    <artifactId>user-management</artifactId>
    <version>1.0.0</version>
    
    <properties>
        <java.version>11</java.version>
        <spring.version>2.7.0</spring.version>
        <junit.version>5.8.2</junit.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
            <version>${spring.version}</version>
        </dependency>
        
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>${junit.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
```

## Common Violations to Avoid

1. **Using snake_case**: `user_name` → Use `userName`
2. **Using Hungarian notation**: `strName`, `iCount` → Use `name`, `count`
3. **Missing JavaDoc**: Use RoyalTek function documentation format
4. **Public fields**: Always use private fields with getters/setters
5. **Not handling null**: Always check for null or use Optional
6. **Ignoring exceptions**: Always handle or properly propagate exceptions
7. **Not following three-part structure**: validation → logic → return

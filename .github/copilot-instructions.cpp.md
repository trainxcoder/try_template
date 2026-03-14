# GitHub Copilot Instructions - C++

## Project Context
- **Language**: C++17/C++20
- **Build System**: CMake / Make / Meson
- **Testing**: CTest / Google Test / Catch2

## General Guidelines

### Code Style
- Follow **Modern C++** practices (C++17/C++20 features)
- Use **RAII** (Resource Acquisition Is Initialization)
- Prefer **smart pointers** (`std::unique_ptr`, `std::shared_ptr`) over raw pointers
- Use **const correctness** everywhere
- Follow **Google C++ Style Guide** or project-specific style
- Use **snake_case** for functions and variables, **PascalCase** for classes
- Add **Doxygen comments** for public APIs

### Memory Management
- Avoid manual `new`/`delete` - use smart pointers
- Use `std::vector` and `std::array` instead of C-style arrays
- Prefer stack allocation over heap when possible
- Use `std::move` for efficient transfers
- Follow **Rule of Zero** or **Rule of Five**

### Modern C++ Features
- Use **auto** for type deduction where it improves readability
- Prefer **range-based for loops**: `for (const auto& item : container)`
- Use **structured bindings**: `auto [key, value] = map.find(...)`
- Leverage **lambda expressions** for callbacks
- Use **constexpr** for compile-time constants
- Prefer **enum class** over plain enum
- Use **std::optional** instead of null pointers for optional values

### Error Handling
- Use **exceptions** for exceptional conditions
- Use **std::expected** or **std::optional** for expected failures (C++23)
- Validate inputs and handle edge cases
- Provide clear error messages
- Use **RAII** to ensure cleanup on exceptions

### File Organization
```
project/
├── include/
│   └── project_name/
│       ├── class_name.hpp
│       └── utils.hpp
├── src/
│   ├── class_name.cpp
│   └── utils.cpp
├── tests/
│   ├── test_class_name.cpp
│   └── CMakeLists.txt
├── CMakeLists.txt
└── README.md
```

### Header Files (.hpp / .h)
- Use **include guards** or `#pragma once`
- Declare class interfaces, templates, inline functions
- Minimize `#include` in headers - use forward declarations
- Example:
```cpp
#pragma once

#include <string>
#include <vector>

namespace myproject {

/**
 * @brief Brief description of the class
 *
 * Detailed description of what this class does.
 */
class MyClass {
public:
    MyClass();
    explicit MyClass(const std::string& name);
    ~MyClass() = default;

    // Delete copy, allow move
    MyClass(const MyClass&) = delete;
    MyClass& operator=(const MyClass&) = delete;
    MyClass(MyClass&&) = default;
    MyClass& operator=(MyClass&&) = default;

    void doSomething(int value);
    [[nodiscard]] std::string getName() const;

private:
    std::string name_;
    std::vector<int> data_;
};

} // namespace myproject
```

### Source Files (.cpp)
- Implement class methods
- Keep implementation details private
- Use unnamed namespaces for internal helpers
- Example:
```cpp
#include "myproject/myclass.hpp"
#include <algorithm>
#include <iostream>

namespace myproject {

namespace {
// Internal helper (not exposed in header)
int helperFunction(int x) {
    return x * 2;
}
} // anonymous namespace

MyClass::MyClass() : name_("default"), data_() {}

MyClass::MyClass(const std::string& name)
    : name_(name), data_() {
    // Constructor implementation
}

void MyClass::doSomething(int value) {
    data_.push_back(helperFunction(value));
}

std::string MyClass::getName() const {
    return name_;
}

} // namespace myproject
```

### CMakeLists.txt Best Practices
```cmake
cmake_minimum_required(VERSION 3.15)
project(MyProject VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Compiler warnings
if(MSVC)
    add_compile_options(/W4 /WX)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Werror)
endif()

# Library or executable
add_library(myproject
    src/class_name.cpp
    src/utils.cpp
)

target_include_directories(myproject
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Enable testing
enable_testing()
add_subdirectory(tests)
```

### Testing
- Use **Google Test** or **Catch2**
- Write tests for all public APIs
- Test edge cases and error conditions
- Use **fixtures** for common setup
- Example (Google Test):
```cpp
#include <gtest/gtest.h>
#include "myproject/myclass.hpp"

namespace myproject {
namespace test {

TEST(MyClassTest, DefaultConstructor) {
    MyClass obj;
    EXPECT_EQ(obj.getName(), "default");
}

TEST(MyClassTest, ParameterizedConstructor) {
    MyClass obj("test");
    EXPECT_EQ(obj.getName(), "test");
}

TEST(MyClassTest, DoSomething) {
    MyClass obj;
    obj.doSomething(5);
    // Add assertions
}

} // namespace test
} // namespace myproject
```

### Performance
- **Profile before optimizing**
- Use `-O3` for release builds
- Consider **move semantics** for large objects
- Use **const&** for large parameters
- Leverage **compiler optimizations** (LTO, etc.)
- Avoid premature optimization

### Common Patterns

#### Singleton (thread-safe)
```cpp
class Singleton {
public:
    static Singleton& getInstance() {
        static Singleton instance;
        return instance;
    }

    Singleton(const Singleton&) = delete;
    Singleton& operator=(const Singleton&) = delete;

private:
    Singleton() = default;
};
```

#### Factory Pattern
```cpp
class Shape {
public:
    virtual ~Shape() = default;
    virtual void draw() const = 0;
};

class ShapeFactory {
public:
    static std::unique_ptr<Shape> create(const std::string& type);
};
```

#### PIMPL (Pointer to Implementation)
```cpp
// In header
class MyClass {
public:
    MyClass();
    ~MyClass();
    void doWork();
private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
};
```

### Dependencies Management
- Use **vcpkg**, **Conan**, or **CMake FetchContent**
- Specify versions explicitly
- Minimize external dependencies
- Consider header-only libraries when possible

### Documentation
- Use **Doxygen** for API documentation
- Add comments for complex algorithms
- Document assumptions and preconditions
- Include usage examples

### Build Configurations
- **Debug**: Full symbols, no optimization, sanitizers
- **Release**: O3 optimization, LTO, no debug symbols
- **RelWithDebInfo**: Optimization + debug symbols
- **MinSizeRel**: Optimize for size

### Compiler Flags (Recommended)
```cmake
# GCC/Clang
-Wall -Wextra -Wpedantic -Werror
-fsanitize=address,undefined (debug builds)
-O3 -flto (release builds)

# MSVC
/W4 /WX
/O2 (release)
```

## Project-Specific Notes
- Check if `CMakeLists.txt`, `Makefile`, or `meson.build` exists
- Follow existing naming conventions
- Use existing test framework
- Match indentation style (tabs vs spaces)

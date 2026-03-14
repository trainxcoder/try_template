cmake_minimum_required(VERSION 3.14)
project(FunnyApp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(funny_app src/funny_app.cpp)

enable_testing()
add_test(NAME funny_app_output_test COMMAND funny_app)
set_tests_properties(funny_app_output_test PROPERTIES
  PASS_REGULAR_EXPRESSION "Let's imagine a funny app to develop: a mood-powered rubber duck advisor!"
)

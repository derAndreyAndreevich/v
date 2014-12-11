# Set the name and the supported language of the project
project(hello-world C)
# Set the minimum version of cmake required to build this project
cmake_minimum_required(VERSION 2.8)
# Use the package PkgConfig to detect GTK+ headers/library files
find_package(PkgConfig)
pkg_check_modules(GTK3 gtk+-3.0)
pkg_check_modules(GLIB glib-2.0)
# Setup CMake to use GTK+, tell the compiler where to look for headers
# and to the linker where to look for libraries
include_directories(${GTK3_INCLUDE_DIRS})
include_directories(${GLIB_INCLUDE_DIRS})
link_directories(${GTK3_LIBRARY_DIRS})
link_directories(${GLIB_LIBRARY_DIRS})
# Add other flags to the compiler
add_definitions(${GTK3_CFLAGS_OTHER})
add_definitions(${GLIB_CFLAGS_OTHER})
# Add an executable compiled from hello.c
add_executable(hello hello.c)
# Link the target to the GTK+ libraries
target_link_libraries(hello ${GTK3_LIBRARIES})
target_link_libraries(hello ${GLIB_LIBRARIES})
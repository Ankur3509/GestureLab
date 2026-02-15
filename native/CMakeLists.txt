cmake_minimum_required(VERSION 3.10)
project(hand_tracker)

set(CMAKE_CXX_STANDARD 14)

# Find OpenCV
# find_package(OpenCV REQUIRED)
# include_directories(${OpenCV_INCLUDE_DIRS})

add_library(hand_tracker SHARED hand_tracker.cpp)

# target_link_libraries(hand_tracker ${OpenCV_LIBS})

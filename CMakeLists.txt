cmake_minimum_required(VERSION 3.8)
project(mirena_sim)
#Compiler options
add_compile_options("-O3")


# ------------------ Install Godot ----------------------

set(GODOT_EXE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/bin")
set(GODOT_INSTALLER "${CMAKE_CURRENT_SOURCE_DIR}/scripts/install_godot.bash")

execute_process(
	COMMAND "${GODOT_INSTALLER}" "${GODOT_EXE_DIR}"
	RESULT_VARIABLE GD_INSTALL_RESULT
)

if(NOT GD_INSTALL_RESULT EQUAL 0)
	message(FATAL_ERROR "Failed to install godot. Aborting build.\n")
else()
	message(WARNING "Successfully installed godot\n")
endif()


# ----------------------------- Build Sim -----------------------------

# Find dependencies
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(tf2 REQUIRED)
find_package(tf2_ros REQUIRED)
find_package(std_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(mirena_common REQUIRED) # For car controls message
find_package(Eigen3 REQUIRED) # For coordinate conversions
find_package(OpenMP REQUIRED) # For lidar optimizations

# Include godot-cpp module
set(GODOTCPP_DISABLE_EXCEPTIONS OFF)
add_subdirectory(godot-cpp)

# Suppress build warnings for the godot files
add_library(godot_cpp_no_cmake_warnings INTERFACE)
target_link_libraries(godot_cpp_no_cmake_warnings INTERFACE godot::cpp)
if(MSVC)
    target_compile_options(godot_cpp_no_cmake_warnings INTERFACE /w)
else()
    target_compile_options(godot_cpp_no_cmake_warnings INTERFACE -w)
endif()


# Add paths for ROS 2 headers
include_directories(${rclcpp_INCLUDE_DIRS})
include_directories(${tf2_INCLUDE_DIRS})
include_directories(${tf2_ros_INCLUDE_DIRS})
include_directories(${std_msgs_INCLUDE_DIRS})
include_directories(${sensor_msgs_INCLUDE_DIRS})
include_directories(${geometry_msgs_INCLUDE_DIRS})
include_directories(${EIGEN3_INCLUDE_DIR})

# Source files for the project (your GDExtension and ROS 2 code)
include_directories(src)
set(SOURCES
    src/sim/node3d/ros_node3d.cpp
    src/sim/node3d/mirena_car.cpp
    src/sim/node3d/mirena_cam.cpp
    src/sim/node3d/mirena_lidar.cpp
    src/sim/node3d/mirena_imu.cpp
    src/sim/node3d/mirena_gps.cpp

    src/sim/ref_counted/ros_time.cpp
    src/sim/ref_counted/mirena_ros_bridge.cpp
    src/sim/ref_counted/service_wrappers.cpp
    
    src/ros/ros_conversions.cpp
    
    src/register_types.cpp
)

# Create the shared library for the GDExtension
add_library(mirena_ros SHARED ${SOURCES})

# Ensure ROS 2 libraries are found
ament_target_dependencies(mirena_ros
    rclcpp
    tf2
    tf2_ros
    std_msgs
    sensor_msgs
    geometry_msgs
    mirena_common
)

# Link Godot GDExtension, Godot CPP bindings, ROS 2 libraries
target_link_libraries(mirena_ros
    ${rclcpp_LIBRARIES}
    ${std_msgs_LIBRARIES}
    ${sensor_msgs_LIBRARIES}
    ${geometry_msgs_LIBRARIES}
    OpenMP::OpenMP_CXX
    godot_cpp_no_cmake_warnings
)


# Copy generated library and export the godot project
add_custom_command(
    TARGET mirena_ros POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:mirena_ros> ${CMAKE_SOURCE_DIR}/MirenaSim/LibMirena/libmirena_sim.so
    COMMENT "Copying the built shared library to godot LibMirena extension folder"
)

#####################################################[ INSTALL ZONE ]#####################################################################
# Install the simulator for usage with ros2

# Detect architecture
if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    # Install the godot engine as executable to lib
    install(PROGRAMS bin/Godot_v4.4.1-stable_linux.x86_64
        DESTINATION lib/${PROJECT_NAME}
        RENAME godot
    )
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
    # Install the godot engine as executable to lib
    install(PROGRAMS bin/Godot_v4.4.1-stable_linux.arm64
        DESTINATION lib/${PROJECT_NAME}
        RENAME godot
    )
endif()


# Install the export build of the sim 

if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|amd64|AMD64")
    set(MIRENA_SIM_ARCH "x86_64")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64|ARM64")
    set(MIRENA_SIM_ARCH "arm64")
else()
    message(WARNING "Unknown architecture ${CMAKE_SYSTEM_PROCESSOR}, defaulting to x86_64")
    set(MIRENA_SIM_ARCH "x86_64")
endif()

install(DIRECTORY
    "export/${MIRENA_SIM_ARCH}/"
    DESTINATION share/${PROJECT_NAME}/sim
    # Set default permissions for all files
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    # Exclude specific files from permission changes using PATTERN
    PATTERN "MirenaSim.pck" PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
    PATTERN "libmirena_sim.so" PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)

# Install the launch script as executable
install(PROGRAMS
    "scripts/launch_sim.sh"
    DESTINATION lib/${PROJECT_NAME}
    RENAME sim
)

#####################################################[ FINISH ]#####################################################################

if(BUILD_TESTING)
    find_package(ament_lint_auto REQUIRED)
    # the following line skips the linter which checks for copyrights
    # comment the line when a copyright and license is added to all source files
    set(ament_cmake_copyright_FOUND TRUE)
    # the following line skips cpplint (only works in a git repo)
    # comment the line when this package is in a git repo and when
    # a copyright and license is added to all source files
    set(ament_cmake_cpplint_FOUND TRUE)
    ament_lint_auto_find_test_dependencies()
endif()

ament_package()


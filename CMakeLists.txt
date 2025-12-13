cmake_minimum_required(VERSION 3.8)
project(mirena_sim)
#Compiler options
add_compile_options("-O3")

find_package(ament_cmake REQUIRED)



#####################################################[ EDITOR BUILD ]###########################################################


    # ------------------ Auto Install Godot ----------------------#

    # 1. Determine the Godot executable's architecture suffix
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
        set(ARCH_SUFFIX "x86_64")
    elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
        set(ARCH_SUFFIX "arm64")
    else()
        message(FATAL_ERROR "Unsupported architecture: ${CMAKE_SYSTEM_PROCESSOR}. Cannot download Godot.")
    endif()

    execute_process(
        COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/scripts/install_godot.bash" "${CMAKE_BINARY_DIR}" "${ARCH_SUFFIX}"
        RESULT_VARIABLE GD_INSTALL_RESULT
        OUTPUT_VARIABLE GD_INSTALL_OUTPUT
        ERROR_VARIABLE GD_INSTALL_ERROR
    )

    if(NOT GD_INSTALL_RESULT EQUAL 0)
    message(FATAL_ERROR "Failed to install godot (Error Code: ${GD_INSTALL_RESULT}).\nOutput: ${GD_INSTALL_OUTPUT}\nError: ${GD_INSTALL_ERROR}")
    else()
        message(STATUS "Godot Installation Script Output: ${GD_INSTALL_OUTPUT}")
    endif()

    set(GODOT_EXE "${CMAKE_BINARY_DIR}/godot")

    # ------------------- Godot project Automatic export of resources ----------------------#
    # GODOT project files
    file(GLOB_RECURSE GODOT_ASSET_FILES
        RELATIVE "${CMAKE_SOURCE_DIR}/MirenaSim"
        CONFIGURE_DEPENDS
        "${CMAKE_SOURCE_DIR}/MirenaSim/*"
    )

    # Filter the .godot folder itself (Avoids loop re-export target)
    list(FILTER GODOT_ASSET_FILES EXCLUDE REGEX "^\\.godot/.*")

    # 3. Use the list of clean, filtered files for dependencies
    set(GODOT_ASSET_DEPENDENCIES)
    foreach(FILE IN ITEMS ${GODOT_ASSET_FILES})
        list(APPEND GODOT_ASSET_DEPENDENCIES "${CMAKE_SOURCE_DIR}/MirenaSim/${FILE}")
    endforeach()

    add_custom_target(
        godot_import_resources
        ALL
        COMMAND
        ${GODOT_EXE}
            --editor                # Run in editor mode to trigger the import logic
            --headless              # Do not render the GUI (essential for CI/CLI builds)
            --quit-after 2          # Run for 2 frames, then quit. (Crucial for full import)
            --path ${CMAKE_SOURCE_DIR}/MirenaSim # Path to the project.godot file's directory
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        DEPENDS 
            ${GODOT_ASSET_DEPENDENCIES} # Must run if some file has changed in the project
        COMMENT "Forcing Godot editor to run headless for resource re-import and GDExtension registration."
    )

    # ----------------------------- Build Sim -----------------------------

    # Find dependencies
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



    # Install the simulator for usage with ros2
    install(PROGRAMS ${CMAKE_BINARY_DIR}/godot
        DESTINATION lib/${PROJECT_NAME}
    )

    # Install project files to share directory
    install(DIRECTORY
        MirenaSim
        DESTINATION share/${PROJECT_NAME}/
    )

    # Install the launch script as executable
    install(PROGRAMS
        scripts/launch_sim.sh
        DESTINATION lib/${PROJECT_NAME}/
        RENAME MirenaSim
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


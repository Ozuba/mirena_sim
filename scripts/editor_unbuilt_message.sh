#!/bin/bash
echo "The editor-related source code is not built by default."
echo "If you just want to run the sim without editing the sim in godot, run 'ros2 run mirena_sim sim' instead"
echo "To build the editor, run:"
echo ""
echo "colcon build --cmake-args -DGD_EDITOR=ON"
echo ""
echo "This will download/update the godot executable and build the GDExtension library"
echo "After that, feel free to source ros and run 'ros2 run mirena_sim godot'"


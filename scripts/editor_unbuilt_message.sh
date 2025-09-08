#!/bin/bash
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${ORANGE}The editor-related source code is not built by default.${NC}"
echo -e "${ORANGE}If you just want to run the sim without editing the sim in godot, run 'ros2 run mirena_sim sim' instead${NC}"
echo -e "${ORANGE}To build the editor, run:${NC}"
echo -e "${ORANGE}${NC}"
echo -e "	${GREEN}colcon build --cmake-args -DGD_EDITOR=ON${NC}"
echo -e "${ORANGE}${NC}"
echo -e "${ORANGE}This will download/update the godot executable and build the GDExtension library${NC}"
echo -e "${ORANGE}After that, feel free to source ros and run 'ros2 run mirena_sim godot'${NC}"

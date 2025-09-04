#!/bin/bash
LAUNCHSCRIPT_PATH=$(dirname "$(realpath "$0")")
cd $LAUNCHSCRIPT_PATH
cd "../../share/mirena_sim/sim"
./MirenaSim.sh


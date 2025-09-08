# mirena_sim
MirenaSim is a godot simulation enviroment for formula student driverless system development, 
it implements the various required sensors to start off with ros2 tinkering,

![SimBanner](https://github.com/user-attachments/assets/8311561e-1324-448f-80ac-e42c1cdfb438)

## Working on the sim
Due to reasons, The sim is excluded from the automatic build process of colcon and instead requires manual exporting each time a new version of the sim is to be published.

The sim consists of the godot project itself (/MirenaSim) and a GDExtension library (/src)

### Building the GDE library
To install the editor, build the GDE library, etc etc..., the following flag must be supplied to colcon:
```colcon build --cmake-args -DGD_EDITOR=ON```

Whenever changes are made to the gdextension library, and a rebuild is desired, the command given above also rebuilds the library and installs it in the project directory


### Exporting a new version of the sim
After making changes to either the project, library, or both, the changes will only be immediately visible in the editor. Other people launchin the sim via other way different from the editor will still use the old version even if they rebuild

To efectively `publish` a new version of the sim, the following procedure must be done:
- Open MirenaSim in godot. Go to Project > Export > (Add linux as a export target)
- Select the x86_64 architecture, set the output directory to "export/x86_64" and Export All
- Select the arm64 architecture, set the output directory to "export/arm64" and Export All
- Push the changes

Make sure the export format is the same as it was before. Each one of the directories in export should consist of:
- MirenaSim.sh (entry point)
- MirenaSim<architecture> (godot binary)
- MirenaSim.pck (assets and scripts)
- libmirena_sim.so (gde library)



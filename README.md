# mirena_sim
MirenaSim is a godot simulation enviroment for formula student driverless system development, 
it implements the various required sensors to start off with ros2 tinkering,

![SimBanner](https://github.com/user-attachments/assets/8311561e-1324-448f-80ac-e42c1cdfb438)


## Current Features
- [x] Fully fledged Car Model, implementing, basic tire friction, suspension dynamics.
- [x] mirena_car -> Car controls node
- [x] mirena_lidar -> An implementation of a lidar using multithreaded raycasting
- [x] mirena_imu -> An implementation of an IMU providing standard ros2 twist pose and accel messages
- [x] mirena_cam -> A viewport/camera broadcaster
- [x] Track generation from a curve given in json format
- [x] Keypoint and Bounding box dataset generation
- [x] Automatic Dataset Generation
- [x] Simulation time support
- [x] CLI Interface

# Installation
```bash
git clone https://github.com/Tecnun-eRacing/mirena_sim
```

extends RosMsg
class_name RosSensorMsgsFluidPressure

func _init():
	init("sensor_msgs/msg/FluidPressure")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var fluid_pressure : float:
	get: return get_member(&"fluid_pressure")
	set(v): set_member(&"fluid_pressure", v)

var variance : float:
	get: return get_member(&"variance")
	set(v): set_member(&"variance", v)


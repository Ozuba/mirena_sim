extends AVehiclePilot
class_name RosPilot

# Internal Variables
var _node : RosNode
var _control_sub : RosSubscriber 
var _control : RosMsg

func _init(owner_: MirenaCar) -> void:
	super._init(owner_)
	_node = RosNode.new()
	_node.init("ControlSubscriber")
	_control_sub = _node.create_subscriber("control/car_control","mirena_common/msg/CarControl",_control_callback)
	_control = RosMirenaCommonCarControl.new() as RosMsg
	
func _control_callback(msg):
	_control = msg 
func on_take_control():
	owner.reset_pilot_config()

func pilot(_delta: float):
	owner.gas = _control.gas
	owner.steering = _control.steer_angle

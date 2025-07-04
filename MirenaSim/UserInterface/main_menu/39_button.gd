extends Button

var _miku_node: Node3D

func _ready() -> void:
	self.pressed.connect(self._on_click)

func _on_click() -> void:
	if self._miku_node == null:
		var miku_scene = preload("res://Assets/secret/super_secret/source/miku_lp.tscn")
		self._miku_node = miku_scene.instantiate()
		SIM.get_vehicle().add_child(self._miku_node)
		self._miku_node.position = Vector3(0, -0.3, 0.525)
	else:
		SIM.get_vehicle().remove_child(self._miku_node)
		self._miku_node.queue_free()
		self._miku_node = null

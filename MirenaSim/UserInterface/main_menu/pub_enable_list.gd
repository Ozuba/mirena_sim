extends VBoxContainer

var elements: Dictionary[ROS.PublisherType, CheckButton]

func _ready() -> void:
	for pub_name in ROS.PublisherType.keys():
		var pub = ROS.PublisherType.get(pub_name)
		var element := CheckButton.new()
		element.text = str(pub_name)
		element.set_pressed_no_signal(ROS.is_publisher_enabled(pub))
		element.toggled.connect(func (toggle_on: bool): ROS.set_publisher_enabled(pub, toggle_on))
		elements.set(pub, element)
		self.add_child(element)

func _process(_delta: float) -> void:
	for pub in elements.keys():
		var element: CheckButton = elements.get(pub)
		element.set_pressed_no_signal(ROS.is_publisher_enabled(pub))

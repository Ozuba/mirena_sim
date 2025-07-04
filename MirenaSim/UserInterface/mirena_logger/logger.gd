extends PanelContainer
class_name LoggingDisplay

signal on_text_updated()
signal on_finish_fade()

var _fade_tween_manager: TweenManager = TweenManager.new(self)

func _ready() -> void:
	MirenaLogger._set_display(self)
	self.on_text_updated.connect(self.show_logger)
	self.on_finish_fade.connect(self.hide_logger)

func _disp_std(what: Array):
	var label = self._get_label()
	for thing in what:
		label.add_text(str(thing))
	label.newline()

	on_text_updated.emit()

func _disp_debug(what: Array):
	var label = self._get_label()
	label.push_color(Color.DARK_GRAY)
	label.push_bold()
	label.add_text("[ DEBUG ] ")
	label.pop()
	for thing in what:
		label.add_text(str(thing))
	label.pop_all()
	label.newline()
	on_text_updated.emit()

func _disp_warn(what: Array):
	var label = self._get_label()
	label.push_color(Color.ORANGE)
	label.push_bold()
	label.add_text("[ WARN ] ")
	label.pop()
	for thing in what:
		label.add_text(str(thing))
	label.pop_all()
	label.newline()
	on_text_updated.emit()

func _disp_error(what: Array):
	var label = self._get_label()
	label.push_color(Color.CRIMSON)
	label.push_bold()
	label.add_text("[ ERROR ] ")
	label.pop()
	for thing in what:
		label.add_text(str(thing))
	label.pop_all()
	label.newline()
	on_text_updated.emit()

func _get_label() -> RichTextLabel:
	return $MarginContainer/RichTextLabel

func show_logger():
	self.show()
	self.start_fade()

func hide_logger():
	self.hide()

func start_fade():
	var tween = self._fade_tween_manager.new_tween()
	tween.tween_interval(5.0)
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	tween.tween_callback(self.on_finish_fade.emit)
	self.modulate.a = 1.0

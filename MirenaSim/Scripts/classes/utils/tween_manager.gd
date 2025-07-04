extends RefCounted

## Tween Manager [br][br]
## When a new tween is created, the tween previously created by this Sanager is killed [br]
## A tween manager should be used for each group of mutually excusive tweens [br]
## TweenManager should NEVER outlife its owner
class_name TweenManager

var _owner: WeakRef
var _active_tween: Tween = null

func _init(owner: Node) -> void:
	self._owner = weakref(owner)

func new_tween() -> Tween:
	if _active_tween != null: _active_tween.kill()
	self._active_tween = self._owner.get_ref().get_tree().create_tween()
	self._active_tween.finished.connect(self._on_tween_finish)
	return self._active_tween

func _on_tween_finish():
	self._active_tween = null

extends RefCounted
## Abstract car pilot class
class_name AVehiclePilot

# Declare a private backing field
var _owner_ref : WeakRef = null

# Public property
var owner: MirenaCar:
	get:
		return _owner_ref.get_ref()
	set(value):
		_owner_ref = weakref(value)

func _init(owner_: MirenaCar) -> void:
	self.owner = owner_

# -----------------------------------
# Abstract methods
# -----------------------------------

## Called during physics process.
func pilot(_delta: float):
	pass

func can_take_control() -> bool:
	return true

## Called when pilot is switched from other pilot to this pilot
func on_take_control():
	pass

## Called when pilot is switched from this pilot to other pilot
func on_lose_control():
	pass

extends Node
class_name GoapGoal

var _actor

func is_valid() -> bool:
	return true

func priority() -> int:
	return 1

func desired_state() -> Dictionary:
	return {}

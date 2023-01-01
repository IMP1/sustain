extends Node
class_name GoapAction

func is_valid(actor, world) -> bool:
	return true

func cost(blackboard: Dictionary) -> int:
	return 1000

func preconditions() -> Dictionary:
	return {}

func results() -> Dictionary:
	return {}

func perform(actor, world, delta: float) -> bool:
	return false

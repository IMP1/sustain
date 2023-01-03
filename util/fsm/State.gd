extends Node
class_name State

signal exiting(next_state, msg)

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_msg:Dictionary={}) -> void:
	pass

func exit() -> void:
	pass

func transition_to(next_state: NodePath, msg:Dictionary={}) -> void:
	emit_signal("exiting", next_state, msg)

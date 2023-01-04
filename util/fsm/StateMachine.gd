extends Node
class_name StateMachine

# https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/

export(NodePath) var initial_state: NodePath

onready var _state: State = get_node(initial_state) as State

func _ready() -> void:
	yield(owner, "ready")
	for child in get_children():
		child.connect("exiting", self, "_transition_to")
	_state.enter()

func _transition_to(next_state: NodePath, msg: Dictionary) -> void:
	_state.exit()
	_state = get_node(next_state) as State
	_state.enter(msg)

func _unhandled_input(event: InputEvent) -> void:
	_state.handle_input(event)

func _process(delta: float) -> void:
	_state.update(delta)

func _physics_process(delta: float) -> void:
	_state.physics_update(delta)



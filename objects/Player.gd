extends KinematicBody2D

signal shift_character(direction)

export(String) var player_name: String = "Player 1"
export(int) var device_id: int = 0

const MOVEMENT_IMPULSE = 100

var _velocity: Vector2 = Vector2.ZERO

onready var inventory: Inventory = $Inventory as Inventory
onready var _interaction_area: Area2D = $InteractionReach as Area2D

func _is_action_pressed(action_name: String) -> bool:
	return Input.is_action_pressed(action_name + "_" + str(device_id))

func _is_event_action_pressed(event: InputEvent, action_name: String) -> bool:
	return event.is_action_pressed(action_name + "_" + str(device_id))

func _input(event):
	if _is_event_action_pressed(event, "shift_char_down"):
		emit_signal("shift_character", -1)
	elif _is_event_action_pressed(event, "shift_char_up"):
		emit_signal("shift_character", 1)
	
	if _is_event_action_pressed(event, "interact"):
		_interact()
		print(inventory.items)

func _handle_movement(delta: float) -> void:
	_velocity = Vector2.ZERO
	if _is_action_pressed("move_left"):
		_velocity.x -= MOVEMENT_IMPULSE #* delta
	if _is_action_pressed("move_right"):
		_velocity.x += MOVEMENT_IMPULSE #* delta
	if _is_action_pressed("move_up"):
		_velocity.y -= MOVEMENT_IMPULSE #* delta
	if _is_action_pressed("move_down"):
		_velocity.y += MOVEMENT_IMPULSE #* delta
	var collision := move_and_slide(_velocity, Vector2.ZERO)

func _process(delta: float):
	_handle_movement(delta)

func _ready():
	print("Player ready")

func _interact():
	var interactables := _interaction_area.get_overlapping_bodies()
	print(interactables)
	if interactables.size() == 1:
		interactables[0].activate(self)

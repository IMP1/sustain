extends KinematicBody2D

signal shift_character(direction)

export(String) var player_name: String = "Player 1"
export(int) var device_id: int = 0

const MOVEMENT_IMPULSE = 100
const ITEM_SCENE = preload("res://gui/InventoryItem.tscn")

var _hunger: float = 100
var _hunger_rate: float = 5 # Hunger points increase per second 

var _velocity: Vector2 = Vector2.ZERO
var _current_item_index: int = 0

onready var inventory: Inventory = $Inventory as Inventory
onready var _interaction_area: Area2D = $InteractionReach as Area2D
onready var _inventory_gui: Control = $InventoryGui as Control
onready var _hunger_tween: Tween = $HungerTween as Tween

func is_action_pressed(action_name: String) -> bool:
	return Input.is_action_pressed(action_name + "_" + str(device_id))

func is_action_just_released(action_name: String) -> bool:
	return Input.is_action_just_released(action_name + "_" + str(device_id))

func _is_event_action_pressed(event: InputEvent, action_name: String) -> bool:
	return event.is_action_pressed(action_name + "_" + str(device_id))

func _action_strength(action_name: String) -> float:
	return Input.get_action_strength(action_name + "_" + str(device_id))

func _input(event):
	if _inventory_gui.visible:
		var any_items := inventory.item_types().size() > 0
		if any_items and _is_event_action_pressed(event, "move_left"):
			_current_item_index -= 1
			_current_item_index %= inventory.item_types().size()
			_refresh_inventory_gui()
		if any_items and _is_event_action_pressed(event, "move_right"):
			_current_item_index += 1
			_current_item_index %= inventory.item_types().size()
			_refresh_inventory_gui()
		if any_items and _is_event_action_pressed(event, "interact"):
			_use_item()
	else:
		if _is_event_action_pressed(event, "shift_char_down"):
			emit_signal("shift_character", -1)
		elif _is_event_action_pressed(event, "shift_char_up"):
			emit_signal("shift_character", 1)
		if _is_event_action_pressed(event, "interact"):
			_interact()
	if _is_event_action_pressed(event, "inventory"):
		_inventory_gui.visible = not _inventory_gui.visible

func _handle_movement(delta: float) -> void:
	_velocity = Vector2.ZERO
	_velocity.x = _action_strength("move_right") - _action_strength("move_left")
	_velocity.y = _action_strength("move_down") - _action_strength("move_up")
	# TODO: If using keyboard + mouse, then check for walk command and slow movement
	_velocity = _velocity.normalized() * MOVEMENT_IMPULSE
	var collision := move_and_slide(_velocity, Vector2.ZERO)

func _process(delta: float) -> void:
	if _inventory_gui.visible:
		return
	_handle_movement(delta)
	# TODO: Get hungry

func _ready() -> void:
	_inventory_gui.visible = false

func _use_item() -> void:
	if inventory.item_types().empty():
		return
	var item = inventory.item_types()[_current_item_index]
	print("Using item %s" % item.name)
	item.use(self)
	inventory.remove_item(item, 1)
	# TODO: Close inventory on use?
	_refresh_inventory_gui()

func _interact() -> void:
	var interactables := _interaction_area.get_overlapping_bodies()
	print(interactables)
	if interactables.size() == 1:
		interactables[0].activate(self)
	var all_are_item_stacks := true
	for obj in interactables:
		if not obj is ItemStack:
			all_are_item_stacks = false
			break
	if all_are_item_stacks:
		for stack in interactables:
			stack.activate(self)
	else:
		var nearest := _nearest_interactable(interactables)
		nearest.activate(self)

func _nearest_interactable(list: Array) -> StaticInteractable:
	var nearest = null
	var distance := 0.0
	for obj in list:
		var dist := position.distance_squared_to(obj.position)
		if nearest == null or dist < distance:
			nearest = obj
			distance = dist
	return nearest

func _item_added(item: Resource, amount: int) -> void:
	_refresh_inventory_gui()

func _refresh_inventory_gui() -> void:
	var item_types := inventory.item_types()
	if item_types.empty():
		$InventoryGui/CurrentItem.texture = null
		$InventoryGui/CurrentItem/Count.text = ""
		return
	var item = item_types[_current_item_index]
	var amount = inventory.item_count(item)
	$InventoryGui/CurrentItem.texture = item.icon
	$InventoryGui/CurrentItem/Count.text = str(amount)

func feed(amount: float) -> void:
	_hunger -= amount
	_hunger = 0 if _hunger < 0 else _hunger
	# TODO: Refresh hunger bar

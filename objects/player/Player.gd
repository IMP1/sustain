extends KinematicBody2D

signal shift_character(direction)
signal hunger_changed()
signal starved()
signal drop_item(item, amount)
signal construction_begun(building, location)

export(String) var player_name: String = "Player 1"
export(int) var device_id: int = 0

export(float) var hunger_rate: float = 5 # Hunger points increase per second 

const MOVEMENT_IMPULSE = 128
const WALK_FACTOR = 0.3
const ITEM_SCENE = preload("res://gui/InventoryItem.tscn")

var _hunger: float = 0
var _velocity: Vector2 = Vector2.ZERO
var _current_item_index: int = 0
var _current_build_index: int = 0
var _current_building_blueprint: Building = null

onready var inventory: Inventory = $Inventory as Inventory
onready var _interaction_area: Area2D = $InteractionReach as Area2D
onready var _inventory_gui: Control = $InventoryGui as Control
onready var _craft_gui: Control = $CraftGui as Control
onready var _build_blueprint: Sprite = $Pivot/BuildBlueprint as Sprite
onready var _build_area: Area2D = $Pivot/BuildBlueprint/Area2D as Area2D
onready var _current_item: InventoryItem = $InventoryGui/CurrentItem as InventoryItem
onready var _pivot: Node2D = $Pivot as Node2D

func _ready() -> void:
	_inventory_gui.visible = false
	_craft_gui.visible = false
	_build_blueprint.visible = false

func _is_action_pressed(action_name: String) -> bool:
	return Input.is_action_pressed(action_name + "_" + str(device_id))

func _is_action_just_released(action_name: String) -> bool:
	return Input.is_action_just_released(action_name + "_" + str(device_id))

func _is_event_action_pressed(event: InputEvent, action_name: String) -> bool:
	return event.is_action_pressed(action_name + "_" + str(device_id))

func _action_strength(action_name: String) -> float:
	return Input.get_action_strength(action_name + "_" + str(device_id))

func _input(event: InputEvent) -> void:
	if _inventory_gui.visible:
		if _is_event_action_pressed(event, "inventory"):
			_inventory_gui.visible = false
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
		if any_items and _is_event_action_pressed(event, "drop"):
			_drop_item()
	elif _craft_gui.visible:
		if _is_event_action_pressed(event, "inventory"):
			_craft_gui.visible = false
		var tabs: TabContainer = _craft_gui.get_node("Tabs") as TabContainer
		var option_count: int = tabs.get_child(tabs.current_tab).get_child_count()
		if _is_event_action_pressed(event, "build"):
			_craft_gui.visible = false
		if _is_event_action_pressed(event, "move_left"):
			_current_build_index -= 1
			if _current_build_index == -1:
				_current_build_index = option_count - 1
			_refresh_craft_gui()
		if _is_event_action_pressed(event, "move_right"):
			_current_build_index += 1
			_current_build_index %= option_count
			_refresh_craft_gui()
		if _is_event_action_pressed(event, "interact"):
			if tabs.current_tab == 0:
				tabs.current_tab = _current_build_index + 1
				_current_build_index = 0
			else:
				var object = tabs.get_child(tabs.current_tab).get_child(_current_build_index)
				if _can_build(object.building):
					_hold_blueprint(object.building)
				elif _can_craft(object.building):
					print("Crafting, not building")
			_refresh_craft_gui()
		if tabs.current_tab > 0 and _is_event_action_pressed(event, "back"):
			_current_build_index = tabs.current_tab - 1
			tabs.current_tab = 0
			_refresh_craft_gui()
	elif _current_building_blueprint:
		if _is_event_action_pressed(event, "inventory"):
			_remove_building_blueprint()
		if _is_event_action_pressed(event, "interact"):
			_place_building()
	else:
		if _is_event_action_pressed(event, "shift_char_down"):
			emit_signal("shift_character", -1)
		elif _is_event_action_pressed(event, "shift_char_up"):
			emit_signal("shift_character", 1)
		if _is_event_action_pressed(event, "interact"):
			_interact()
		if _is_event_action_pressed(event, "build"):
			_craft_gui.visible = true
		if _is_event_action_pressed(event, "inventory"):
			_inventory_gui.visible = true

func _handle_movement(_delta: float) -> void:
	_velocity = Vector2.ZERO
	_velocity.x = _action_strength("move_right") - _action_strength("move_left")
	_velocity.y = _action_strength("move_down") - _action_strength("move_up")
	if _velocity == Vector2.ZERO:
		return
	_velocity = _velocity.normalized() * MOVEMENT_IMPULSE
	_pivot.rotation_degrees = stepify(rad2deg(_velocity.angle()), TAU / 8)
	if _is_action_pressed("toggle_walk"):
		_velocity *= WALK_FACTOR
	move_and_slide(_velocity, Vector2.ZERO)

func _process_hunger(delta: float) -> void:
	_hunger += hunger_rate * delta
	emit_signal("hunger_changed")
	if _hunger > 100:
		emit_signal("starved")

func _process(delta: float) -> void:
	if not _inventory_gui.visible and not _craft_gui.visible:
		_handle_movement(delta)
	if _current_building_blueprint:
		_update_blueprint_placement()
	_process_hunger(delta)

func _use_item() -> void:
	if inventory.item_types().empty():
		return
	var item: Item = inventory.item_types()[_current_item_index]
	if not item.can_use(self):
		return
	item.use(self)
	inventory.remove_item(item, 1)
	if _current_item_index > 0 and not inventory.has_item(item):
		_current_item_index -= 1
	_refresh_inventory_gui()

func _drop_item() -> void:
	if inventory.item_types().empty():
		return
	var item: Item = inventory.item_types()[_current_item_index]
	var amount: int = 1
	if _is_action_pressed("toggle_drop_all"):
		amount = inventory.item_count(item)
	var height := Vector2(0, 10) # TODO: Use the direction facing
	var destination: Vector2 = position + Vector2(rand_range(-8, 8), 24) # TODO: Use the direction facing
	emit_signal("drop_item", item, amount, position, height, destination)
	inventory.remove_item(item, amount)
	if _current_item_index > 0 and not inventory.has_item(item):
		_current_item_index -= 1
	_refresh_inventory_gui()

func _interact() -> void:
	var interactables := _interaction_area.get_overlapping_bodies()
	if interactables.size() == 1:
		interactables[0].activate(self)
		return
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

func _item_added(_item: Resource, _amount: int) -> void:
	_refresh_inventory_gui()

func _refresh_inventory_gui() -> void:
	var label: Label = $InventoryGui/Info as Label
	var item_types := inventory.item_types()
	var item: Item
	var amount: int
	if item_types.empty():
		item = null
		amount = 0
	else:
		item = item_types[_current_item_index]
		amount = inventory.item_count(item)
	_current_item.item = item
	_current_item.amount = amount
	_current_item.refresh()
	if item:
		label.text = item.name

func _refresh_craft_gui() -> void:
	var selection: Panel = $CraftGui/Selection as Panel
	var tabs: TabContainer = $CraftGui/Tabs as TabContainer
	var option_count: int = tabs.get_child(tabs.current_tab).get_child_count()
	var width: int = option_count * 24 + (option_count - 1) * 4
	var ox: int = -(width / 2)
	selection.rect_position.x = ox + (_current_build_index * (24+4))
	var label: Label = $CraftGui/Info as Label
	label.text = tabs.get_child(tabs.current_tab).get_child(_current_build_index).name

func feed(amount: float) -> void:
	_hunger -= amount
	_hunger = 0.0 if _hunger < 0 else _hunger
	emit_signal("hunger_changed")

func _can_build(building: Building) -> bool:
	if building == null:
		return false
	for i in building.needed_resources.size():
		var resource: Item = building.needed_resources[i]
		var amount: int = building.resource_amounts[i]
		if inventory.item_count(resource) < amount:
			return false
	return true

func _can_craft(item: CraftedItem) -> bool:
	if item == null:
		return false
	for i in item.needed_resources.size():
		var resource: Item = item.needed_resources[i]
		var amount: int = item.resource_amounts[i]
		if inventory.item_count(resource) < amount:
			return false
	if item.needed_items.size() > 0:
		for item_set in item.needed_items:
			var all_in_set: bool = true
			for needed_item in item_set:
				if not inventory.has_item(needed_item):
					all_in_set = false
					break
			if all_in_set:
				return true
		return false
	return true

func _hold_blueprint(building: Building) -> void:
	_current_building_blueprint = building
	_build_blueprint.texture = building.texture
	_build_blueprint.visible = true
	_craft_gui.visible = false
	_inventory_gui.visible = false
	var shape: RectangleShape2D = _build_area.get_node("CollisionShape2D").shape
	shape.extents = building.texture.get_size() / 2

func _remove_building_blueprint() -> void:
	_current_building_blueprint = null
	_build_blueprint.visible = false

func _update_blueprint_placement() -> void:
	_build_blueprint.rotation_degrees = -_pivot.rotation_degrees
	var obstacles := _build_area.get_overlapping_bodies()
	if obstacles.size() > 0:
		_build_blueprint.modulate = Color("80b13030")
	else:
		_build_blueprint.modulate = Color("a079b2ff")

func _place_building() -> void:
	var obstacles := _build_area.get_overlapping_bodies()
	if obstacles.size() > 0:
		return
	print("Placing building")
	var building = _current_building_blueprint
	var location = _build_blueprint.global_position
	emit_signal("construction_begun", building, location)
	# TODO: Remove items
	for i in building.needed_resources.size():
		var item: Item = building.needed_resources[i]
		var amount: int = building.resource_amounts[i]
		inventory.remove_item(item, amount)
	_refresh_inventory_gui()
	_remove_building_blueprint()

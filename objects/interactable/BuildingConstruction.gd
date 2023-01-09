extends LongInteractable
class_name BuildingConstruction

signal construction_finished(building, location)

var building: Building setget _set_building

var _is_ready: bool = false

onready var _sprite: Sprite = $Sprite as Sprite
onready var _collision: CollisionShape2D = $CollisionShape2D as CollisionShape2D

func _ready() -> void:
	_is_ready = true

func _set_building(new_building: Building) -> void:
	building = new_building
	if _is_ready:
		_sprite.texture = building.texture
		_collision.shape.extents = _sprite.texture.get_size() / 2
	interaction_duration = building.construction_time

func activate(player) -> void:
	if not _player_can_build(player):
		return
	.activate(player)
	print("Activating..")

func _player_can_build(player) -> bool:
	if building.needed_items.size() == 0:
		return true
	for item_set in building.needed_item:
		var all_in_set: bool = true
		for item in item_set:
			if not player.inventory.has_item(item):
				all_in_set = false
				break
		if all_in_set:
			return true
	return true

func _activation_successful() -> void:
	print("Activated!")
	._activation_successful()
	emit_signal("construction_finished", building, global_position)

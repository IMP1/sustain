extends StaticInteractable
class_name BuildingObject

var building: Building setget _set_building

var _is_ready: bool = false

onready var _sprite: Sprite = $Sprite as Sprite
onready var _collision: CollisionShape2D = $CollisionShape2D as CollisionShape2D

func _ready() -> void:
	_is_ready = true
	if building:
		_sprite.texture = building.texture
		_collision.shape.extents = _sprite.texture.get_size() / 2

func _set_building(new_building: Building) -> void:
	building = new_building
	if _is_ready:
		_sprite.texture = building.texture
		_collision.shape.extents = _sprite.texture.get_size() / 2

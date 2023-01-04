extends StaticBody2D
class_name ItemStack

export(Resource) var item: Resource setget _set_item
export(int) var amount: int
export(Vector2) var height: Vector2
export(Vector2) var destination: Vector2

var _is_ready = false

onready var _sprite: Sprite = $Sprite as Sprite
onready var _tween: Tween = $Tween as Tween

func _set_item(new_item: Resource) -> void:
	item = new_item
	if _is_ready:
		_sprite.texture = item.icon

func _ready():
	_is_ready = true

func pop():
	$Sprite/Label.text = str(amount)
	var duration := 0.1
	_tween.interpolate_property(self, "position", position, position - height, duration)
	_tween.interpolate_property(self, "z_index", 0, 2, duration)
	_tween.start()
	yield(_tween, "tween_all_completed")
	_tween.stop_all()
	duration = 0.3
	_tween.interpolate_property(self, "position", position, destination, duration, Tween.TRANS_BOUNCE)
	_tween.interpolate_property(self, "z_index", 2, 0, duration)
	_tween.start()

func activate(player) -> void:
	player.inventory.add_item(item, amount)
	queue_free()

extends StaticBody2D
class_name StaticInteractable

const ITEM_STACK = preload("res://objects/interactable/ItemStack.tscn")

var _enabled: bool = true
onready var _game_scene = get_node("/root/Main/CurrentScene/Game")

func activate(_player) -> void:
	pass

func disable() -> void:
	if not _enabled:
		return
	collision_layer -= 64
	_enabled = false

func enable() -> void:
	if _enabled:
		return
	collision_layer += 64
	_enabled = true	

func pop_item_stack(item: Resource, amount: int, pos: Vector2, direction: Vector2):
	var height := Vector2(0, 10)
	# TODO: Use direction
	var destination := pos + Vector2(rand_range(-8, 8), 32)
	var _item_stack: ItemStack = _game_scene._add_item_stack(item, amount, pos, height, destination)

func play_sound(stream: AudioStream, pos: Vector2):
	var audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	_game_scene.get_node("Sounds").add_child(audio)
	audio.position = pos
	audio.stream = stream
	audio.play()
	yield(audio, "finished")
	audio.queue_free()

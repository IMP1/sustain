extends StaticBody2D
class_name StaticInteractable

const ITEM_STACK = preload("res://objects/ItemStack.tscn")

var _enabled: bool = true
onready var _game_scene = get_node("/root/Main/CurrentScene/Game")

func activate(player) -> void:
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

func pop_item_stack(item: Resource, amount: int, global_pos: Vector2, direction: Vector2):
	# TODO: Play sounds
	var item_stack = ITEM_STACK.instance()
	_game_scene.get_node("Objects/Objects").add_child(item_stack)
	item_stack.source = global_pos + Vector2(0, 10)
	item_stack.destination = global_pos + Vector2(rand_range(-8, 8), 32)
	item_stack.global_position = item_stack.source
	item_stack.item = item
	item_stack.amount = amount
	item_stack.pop()

func play_sound(stream: AudioStream, pos: Vector2):
	var audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	_game_scene.get_node("Sounds").add_child(audio)
	audio.position = pos
	audio.stream = stream
	audio.play()
	yield(audio, "finished")
	audio.queue_free()

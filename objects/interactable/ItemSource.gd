extends LongInteractable

signal item_harvested
signal exhausted

export(Resource) var item: Resource
export(int) var min_yield: int = 1
export(int) var max_yield: int = 1
export(int) var amount: int = 1

var _rng := RandomNumberGenerator.new()

onready var _audio: AudioStreamPlayer2D = $Sound as AudioStreamPlayer2D

func _begin_activation() -> void:
	._begin_activation()
	if _audio.stream:
		_audio.play()

func _stop_activation() -> void:
	._stop_activation()
	_audio.stop()

func _ready() -> void:
	if item == null:
		print("[WARNING] Item not set for source %s." % self.to_string())
	_rng.randomize()

func _activation_successful() -> void:
	._activation_successful()
	var direction := Vector2()
	var yield_amount: int = _rng.randi_range(min_yield, max_yield)
	pop_item_stack(item, yield_amount, global_position, direction)
	amount -= 1
	if amount <= 0:
		disable()

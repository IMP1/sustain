extends LongInteractable

export(Resource) var item: Resource
export(int) var amount: int = 6

onready var _audio: AudioStreamPlayer2D = $ProgressBar/AudioStreamPlayer2D as AudioStreamPlayer2D

func _begin_activation() -> void:
	._begin_activation()
	_audio.play()

func _stop_activation() -> void:
	._stop_activation()
	_audio.stop()

func _activation_successful() -> void:
	._activation_successful()
	var direction := Vector2()
	pop_item_stack(item, 1, global_position, direction)
	amount -= 1
	if amount <= 0:
		disable()

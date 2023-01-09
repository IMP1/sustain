extends "res://objects/interactable/ItemSource.gd"

export(float) var min_growth_time: float = 10.0
export(float) var max_growth_time: float = 10.0
export(int) var max_amount: int = 1

onready var _timer := $Timer as Timer

func _activation_successful() -> void:
	._activation_successful()
	if _timer.is_stopped() and amount < max_amount:
		var growth_time := _rng.randf_range(min_growth_time, max_growth_time)
		_timer.start(growth_time)

func replenish() -> void:
	enable()
	if amount < max_amount:
		var growth_time := _rng.randf_range(min_growth_time, max_growth_time)
		_timer.start(growth_time)

extends StaticInteractable

export(Resource) var item: Resource
export(int) var min_yield: int = 1
export(int) var max_yield: int = 1
export(float) var min_growth_time: float = 10.0
export(float) var max_growth_time: float = 10.0

onready var _timer := $Timer as Timer
onready var _rng := RandomNumberGenerator.new()

func activate(player) -> void:
	$Sprites/Berries.visible = false
	var item_amount := _rng.randi_range(min_yield, max_yield)
	var direction := Vector2()
	pop_item_stack(item, item_amount, global_position, direction)
	var growth_time := _rng.randf_range(min_growth_time, max_growth_time)
	_timer.start(growth_time)
	disable()

func produce_fruit() -> void:
	$Sprites/Berries.visible = true
	enable()

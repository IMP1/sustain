extends StaticInteractable

export(Resource) var item: Resource
export(int) var amount: int = 6
export(float) var interaction_duration: float = 1.0

var _last_active_player = null
var _active: bool = false

onready var _bar: ProgressBar = $ProgressBar as ProgressBar
onready var _tween: Tween = $Tween as Tween
onready var _audio: AudioStreamPlayer2D = $ProgressBar/AudioStreamPlayer2D as AudioStreamPlayer2D

func activate(player) -> void:
	_last_active_player = player
	_active = true
	_bar.visible = true
	_tween.interpolate_property(_bar, "value", 0, 1, interaction_duration)
	_tween.start()
	_audio.play()

func _stop_activation() -> void:
	_active = false
	_bar.visible = false
	_tween.stop_all()
	_audio.stop()

func _input(event: InputEvent) -> void:
	if not _active:
		return
	if _last_active_player.is_action_just_released("interact"):
		_stop_activation()

func _process(delta: float) -> void:
	if not _active:
		return
	if not self in _last_active_player._interaction_area.get_overlapping_bodies():
		_stop_activation()

func _activation_successful() -> void:
	var direction := Vector2()
	pop_item_stack(item, 1, global_position, direction)
	_stop_activation()
	amount -= 1
	if amount <= 0:
		disable()

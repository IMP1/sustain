extends StaticInteractable
class_name LongInteractable

export(float) var interaction_duration: float = 1.0

var _last_active_player = null
var _active: bool = false

onready var _bar: ProgressBar = $ProgressBar as ProgressBar
onready var _tween: Tween = $ProgressBar/Tween as Tween

func activate(player) -> void:
	_last_active_player = player
	_active = true
	_begin_activation()

func _begin_activation() -> void:
	_bar.visible = true
	_tween.interpolate_property(_bar, "value", 0, 1, interaction_duration)
	_tween.start()

func _stop_activation() -> void:
	_active = false
	_bar.visible = false
	_tween.stop_all()

func _input(_event: InputEvent) -> void:
	if not _active:
		return
	if _last_active_player._is_action_just_released("interact"):
		_stop_activation()

func _process(_delta: float) -> void:
	if not _active:
		return
	if not self in _last_active_player._interaction_area.get_overlapping_bodies():
		_stop_activation()

func _activation_successful() -> void:
	_stop_activation()

extends Camera2D
class_name MultiplayerCamera2D

export(Array, NodePath) var players: Array = []

onready var _tween: Tween = $Tween as Tween

func add_player(path: NodePath) -> void:
	print(path)
	players.append(path)
	# TODO: Tween to incorporate new player

func _process(delta: float) -> void:
	# TODO: Make sure all players are visible
	pass

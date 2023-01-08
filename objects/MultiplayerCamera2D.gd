extends Camera2D
class_name MultiplayerCamera2D

export(float) var max_zoom: float = 1.0
export(Array, NodePath) var players: Array = []

var bounds := Rect2(0, 0, 0, 0)

onready var _tween: Tween = $Tween as Tween

func add_player(path: NodePath) -> void:
	print(path)
	players.append(path)
	# TODO: Tween to incorporate new player

func _process(_delta: float) -> void:
	var midpoint := Vector2.ZERO
	var count := 0
	var bounds_shifted := false
	for path in players:
		var player: Node2D = get_node_or_null(path)
		if player:
			midpoint += player.position
			count += 1
			if not bounds.has_point(player.position):
				bounds = bounds.expand(player.position)
				bounds_shifted = true
	midpoint /= count
	if bounds_shifted:
		pass
	# TODO: Use midpoint and bounds somehow.

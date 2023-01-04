extends ItemEffect
class_name Delay

export(float) var duration: float = 1.0

func activate(user: Node) -> void:
	yield(user.get_tree().create_timer(duration), "timeout")

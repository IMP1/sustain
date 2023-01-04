extends ItemEffect
class_name HungerOffset

export(float) var satiation: float = 0.0

func activate(user) -> void:
	user.feed(satiation)

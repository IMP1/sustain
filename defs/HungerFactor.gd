extends ItemEffect
class_name HungerFactor

export(float) var rate_offset: float = 0.0
export(float) var duration: float = 1.0

func activate(user: Node) -> void:
	print("Changing hunger rate")
	user._hunger_rate += rate_offset
	yield(user.get_tree().create_timer(duration), "timeout")
	user._hunger_rate -= rate_offset
	print("Changing hunger rate back.")

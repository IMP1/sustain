extends ItemEffect
class_name Parallel

export(Array, Resource) var effects: Array = []

func activate(user) -> void:
	for coroutine in effects:
		var state = coroutine.activate()
		if state is GDScriptFunctionState and state.is_valid():
			yield(state, "completed")

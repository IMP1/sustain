extends Resource
class_name Item

export(String) var name: String
export(Texture) var icon: Texture
export(Array, Resource) var effects: Array = []

func use(user) -> void:
	for effect in effects:
		var state = effect.activate(user)
		if state is GDScriptFunctionState:
			yield(state, "completed")

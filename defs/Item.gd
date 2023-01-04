extends Resource
class_name Item

export(String) var name: String
export(Texture) var icon: Texture
export(Array, Resource) var effects: Array = []
export(bool) var usable: bool = true

func can_use(user) -> bool:
	return usable

func use(user) -> void:
	for effect in effects:
		var state = effect.activate(user)
		if state is GDScriptFunctionState:
			yield(state, "completed")

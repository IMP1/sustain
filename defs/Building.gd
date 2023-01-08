extends Resource
class_name Building

export(String) var name: String = ""
export(Texture) var texture: Texture
export(Texture) var icon: Texture

export(float) var construction_time: float = 1.0
export(Array, Resource) var needed_resources: Array = []
export(Array, int) var resource_amounts: Array = []

# List of sublists, where at least one of the sublists must have ALL their items be present for the building process.
export(Array, Array, Resource) var needed_items: Array = []

export(Script) var behaviour: Script


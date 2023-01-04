extends TextureRect

export(NodePath) var object: NodePath
export(String) var property: String

onready var _object: Node = get_node(object) as Node

func refresh():
	texture = _object.get(property)

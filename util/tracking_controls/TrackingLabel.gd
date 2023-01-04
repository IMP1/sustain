extends Label

export(NodePath) var object: NodePath
export(String) var property: String
export(String) var format_string: String = "%s"

onready var _object: Node = get_node(object) as Node

func refresh():
	text = format_string % _object.get(property)

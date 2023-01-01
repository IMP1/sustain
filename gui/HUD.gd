extends Control

export(String) var player_name: String = "" setget _set_name
export(Texture) var player_face: Texture = null setget _set_face

var _ready: bool = false

func _set_name(text: String) -> void:
	player_name = text
	if _ready:
		$Name.text = player_name

func _set_face(face: Texture) -> void:
	player_face = face
	if _ready:
		$Face.texture = player_face

func _ready():
	_ready = true

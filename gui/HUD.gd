extends Control

const ITEM_SCENE = preload("res://gui/InventoryItem.tscn")

export(String) var player_name: String = "" setget _set_name
export(Texture) var player_face: Texture = null setget _set_face
export(Dictionary) var player_inventory: Dictionary = {} setget _set_items

var _is_ready: bool = false

onready var _name_label: Label = $Name as Label
onready var _face_texture: TextureRect = $Face as TextureRect
onready var _item_list: Container = $Inventory/Items as Container

func _set_name(text: String) -> void:
	player_name = text
	if _is_ready:
		$Name.text = player_name

func _set_face(face: Texture) -> void:
	player_face = face
	if _is_ready:
		$Face.texture = player_face

func _set_items(items: Dictionary) -> void:
	print("Setting items")
	player_inventory = items
	if _is_ready:
		for child in _item_list.get_children():
			_item_list.remove_child(child)
		for item in items:
			var amount = items[item]
			var icon = ITEM_SCENE.instance()
			_item_list.add_child(icon)
			icon.item = item
			icon.amount = amount
			icon.refresh()

func _ready():
	_is_ready = true

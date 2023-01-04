extends Node2D

const PLAYER = preload("res://objects/Player.tscn")
const AVAILABLE_CHARACTERS = ["Pink", "Blue", "White"]

var _used_devices = []

onready var _players: Node2D = $Objects/Players as Node2D
onready var _camera: MultiplayerCamera2D = $Camera as MultiplayerCamera2D
onready var _gui_layer: CanvasLayer = $HUDs as CanvasLayer

func _add_player(input_device: int) -> void:
	_used_devices.append(input_device)
	var player = PLAYER.instance()
	_players.add_child(player)
	player.device_id = input_device
	player.position += Vector2(50, 50)
	player.connect("shift_character", self, "_shift_player_character", [player])
	player.connect("starved", self, "_player_starved", [player])
	_camera.add_player(player.get_path())
	var current_player_number: int = _players.get_child_count()
	var hud_path: String = ""
	match current_player_number:
		1:
			hud_path = "HUD.tscn"
		2:
			hud_path = "HUDRight.tscn"
		3:
			hud_path = "HUDBottom.tscn"
		4:
			hud_path = "HUDBottomRight.tscn"
	var hud: Control = load("res://gui/" + hud_path).instance() as Control
	_gui_layer.add_child(hud)
	var hunger_bar = hud.get_node("Hunger/Bar")
	hunger_bar._object = player
	hunger_bar.property = "_hunger"
	player.connect("hunger_changed", hunger_bar, "refresh")
	player.inventory.connect("item_added", self, "_refresh_player_inventory", [player, hud])
	player.inventory.connect("item_removed", self, "_refresh_player_inventory", [player, hud])

func _shift_player_character(direction: int, player) -> void:
	print(player)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if not 0 in _used_devices:
			_add_player(0)
	if event is InputEventJoypadButton:
		if not (event.device + 1) in _used_devices:
			_add_player(event.device + 1)

func _player_starved(player):
	print("GAME OVER")

func _refresh_player_inventory(_item, _amount, player, hud):
	hud.player_inventory = player.inventory._items

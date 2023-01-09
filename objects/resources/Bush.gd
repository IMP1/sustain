extends "res://objects/interactable/ReplenishingItemSource.gd"

onready var _item_sprite: Sprite = $Sprites/Item as Sprite

func _activation_successful() -> void:
	._activation_successful()
	if amount <= 0:
		_item_sprite.visible = false
	
func replenish() -> void:
	.replenish()
	_item_sprite.visible = true

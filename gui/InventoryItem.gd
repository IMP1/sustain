extends TextureRect
class_name InventoryItem

export(Resource) var item: Resource
export(int) var amount: int = 1

onready var _count: Label = $Count as Label

func refresh() -> void:
	_count = $Count
	texture = item.icon
	_count.text = str(amount)

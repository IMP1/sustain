extends TextureRect
class_name InventoryItem

export(Resource) var item: Resource
export(int) var amount: int = 1

onready var _count: Label = $Count as Label

func refresh() -> void:
	texture = item.icon if item else null
	_count.text = str(amount) if amount > 0 else ""

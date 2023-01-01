extends Node
class_name Inventory

var items = {} 

func add_item(item: Resource, amount: int = 1) -> void:
	if not items.has(item):
		items[item] = 0
	items[item] += amount

func has_item(item: Resource) -> bool:
	return item_count(item) > 0

func item_count(item: Resource) -> int:
	if not items.has(item):
		return 0
	return items[item]

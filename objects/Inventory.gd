extends Node
class_name Inventory

var _items := {} 

signal item_added(item, amount)
signal item_removed(item, amount)

func add_item(item: Resource, amount: int = 1) -> void:
	if not has_item(item):
		_items[item] = 0
	var key := _item_ref(item)
	_items[key] += amount
	emit_signal("item_added", key, amount)

func remove_item(item: Resource, amount: int = 1) -> bool:
	if not has_item(item):
		return false
	if item_count(item) < amount:
		return false
	var key := _item_ref(item)
	_items[key] -= amount
	if _items[key] <= 0:
		_items.erase(key)
	emit_signal("item_removed", key, amount)
	return true

func has_item(item: Resource) -> bool:
	return _item_ref(item) != null

func item_count(item: Resource) -> int:
	var total := 0
	for i in _items:
		if item.name == i.name:
			total += _items[i]
	return total

func item_types() -> Array:
	return _items.keys()

func _item_ref(item: Resource) -> Resource:
	for i in _items:
		if item.name == i.name:
			return i
	return null
	

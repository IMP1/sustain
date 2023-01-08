extends Item
class_name CraftedItem

export(float) var construction_time: float = 1.0
export(int) var constuction_yield: int = 1
export(Array, Resource) var needed_resources: Array = []
export(Array, int) var resource_amounts: Array = []
# List of sublists, where at least one of the sublists must have ALL their items be present
export(Array, Array, Resource) var needed_items: Array = []

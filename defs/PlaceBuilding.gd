extends ItemEffect
class_name PlaceBuilding

export(Resource) var building: Resource

func activate(user) -> void:
	print(user)
	# TODO: Set building_being_placed to the building

extends KinematicBody2D

var _hunger: int = 0

class ManageHunger extends GoapGoal:
	func is_valid() -> bool:
		return true
	func priority() -> int:
		return 1 if _actor._hunger < 75 else 2
	func desired_state() -> Dictionary:
		return {
			"fed": true
		}



func _ready():
	_setup_goap()

func _setup_goap() -> void:
	var goals := []
	var manage_hunger := ManageHunger.new()
	manage_hunger._actor = self
	goals.append(manage_hunger)
	
	var world = null # TODO: Get world from somewhere
	
	var agent := GoapAgent.new()
	agent.init(self, world, goals)
	add_child(agent)
	

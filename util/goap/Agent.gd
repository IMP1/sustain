extends Node
class_name GoapAgent

var _goals: Array
var _current_goal: GoapGoal
var _current_plan: Array
var _current_plan_step: int = 0

var _actor
var _world

func init(actor, world, goals: Array) -> void:
	_actor = actor
	_world = world
	_goals = goals

func _process(delta: float) -> void:
	var goal := _most_pressing_goal()
	if _current_goal == null or goal != _current_goal:
		var blackboard = {}
		_current_goal = goal
		_current_plan = Goap.get_plan(_current_goal, _actor, _world, blackboard)
		_current_plan_step = 0
	else:
		_follow_plan(_current_plan, delta)

func _most_pressing_goal() -> GoapGoal:
	var urgent_goal: GoapGoal
	for goal in _goals:
		if goal.is_valid() and (urgent_goal == null or goal.priority() > urgent_goal.priority()):
			urgent_goal = goal
	return urgent_goal

func _follow_plan(plan: Array, delta: float) -> void:
	if plan.size() == 0:
		return
	var is_step_complete: bool = plan[_current_plan_step].perform(_actor, _world, delta)
	if is_step_complete and _current_plan_step < plan.size() - 1:
		_current_plan_step += 1

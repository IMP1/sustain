extends Node
class_name GoapPlanner

# Using https://github.com/viniciusgerevini/godot-goap/blob/main/goap/action_planner.gd

class Step:
	var action: GoapAction
	var state: Dictionary
	var children: Array

class Plan:
	var actions: Array
	var cost: int

var _available_actions: Array

func set_actions(actions: Array) -> void:
	_available_actions = actions

func get_plan(goal: GoapGoal, actor, world, blackboard: Dictionary = {}) -> Array:
	print("Getting plan for goal: %s" % goal.get_class())
	var desired_state := goal.desired_state().duplicate()
	if desired_state.empty():
		return []
		
	var plan := _find_best_plan(actor, goal, desired_state, blackboard)
	return plan

func _find_best_plan(actor, goal: GoapGoal, desired_state: Dictionary, blackboard: Dictionary) -> Array:
	var root := Step.new()
	root.action = null # goal
	root.state = desired_state
	root.children = []
	if _build_plans(root, actor, blackboard.duplicate()):
		var plans := _tree_to_array(root, blackboard)
		return _cheapest_plan(plans)
	return []

func _cheapest_plan(plans: Array) -> Array:
	var best_plan: Plan
	for p in plans:
		var plan := p as Plan
		_print_plan(plan)
		if best_plan == null or plan.cost < best_plan.cost:
			best_plan = plan
	return best_plan.actions

func _build_plans(step: Step, actor, blackboard: Dictionary) -> bool:
	var has_followup := false
	var state := step.state.duplicate()
	
	for s in state:
		if state[s] == blackboard.get(s):
			state.erase(s)
	if state.empty():
		return true
	
	for a in _available_actions:
		var action := a as GoapAction
		if not action.is_valid(actor, _world):
			continue
		var should_use_action := false
		var effects := action.results()
		var desired_state := state.duplicate()
		for s in desired_state:
			if desired_state[s] == effects.get(s):
				desired_state.erase(s)
				should_use_action = true
		if should_use_action:
			var preconditions := action.preconditions()
			for p in preconditions:
				desired_state[p] = preconditions[p]
			var s := Step.new()
			s.action = action
			s.state = desired_state
			s.children = []
			if desired_state.empty() or _build_plans(s, actor, blackboard.duplicate()):
				step.children.push_back(s)
				has_followup = true	
	return has_followup

func _tree_to_array(p: Step, blackboard: Dictionary) -> Array:
	var plans := []
	
	if p.children.size() == 0:
		var plan := Plan.new()
		plan.actions = [p.action]
		plan.cost = p.action.cost(blackboard)
		plans.push_back(plan)
		return plans
	
	for c in p.children:
		var child := c as Step
		for cp in _tree_to_array(child, blackboard):
			var child_plan := cp as Plan
			if p.action != null:
				child_plan.actions.push_back(p.action)
				child_plan.cost += p.action.cost(blackboard)
			plans.push_back(child_plan)
	
	return plans

func _print_plan(plan: Plan) -> void:
	var actions := []
	for a in plan.actions:
		actions.push_back(a.get_class())
	print({"cost": plan.cost, "actions": actions})

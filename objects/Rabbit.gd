extends KinematicBody2D

var _hunger: int = 0

onready var _nav_agent: NavigationAgent2D = $NavigationAgent2D as NavigationAgent2D

func _ready():
	_nav_agent.set_target_location(position)

func move_to(pos: Vector2):
	_nav_agent.set_target_location(pos)

# TODO: Remove
func _input(event):
	if event is InputEventMouseButton:
		move_to(event.position - Vector2(512, 300))

func _physics_process(_delta: float) -> void:
	_process_path_movement()

func _process_path_movement():
	if _nav_agent.is_navigation_finished():
		return
	var target := _nav_agent.get_next_location()
	var direction := global_position.direction_to(target)
	var velocity := direction * _nav_agent.max_speed
	move_and_slide(velocity)

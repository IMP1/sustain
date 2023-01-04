extends ProgressBar

export(NodePath) var object: NodePath
export(String) var property: String
export(float) var offset: float = 0.0
export(float) var multiplier: float = 1.0

onready var _object: Node = get_node(object) as Node
onready var _tween: Tween = $Tween as Tween

func refresh(duration:float=0):
	var new_value = offset + _object.get(property) * multiplier
	if duration <= 0.0:
		value = new_value
		return
	_tween.stop_all()
	_tween.interpolate_property(self, "value", value, new_value, duration)
	_tween.start()

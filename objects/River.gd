extends Area2D
class_name River

export(float) var flow_speed: float = 128.0
export(Texture) var wave_texture: Texture

onready var _polygon: CollisionPolygon2D = $Polygon2D as CollisionPolygon2D
onready var _path: Path2D = $Path as Path2D
onready var _flow_texture: Sprite = $Flowmap as Sprite

onready var _bar: ProgressBar = $ProgressBar as ProgressBar

var is_generated: bool = false

func _ready():
	_bar.visible = false
	_flow_texture.visible = false
	if not ResourceLoader.exists(_river_flow_data_path()):
		var state = _generate_flow()
		if state is GDScriptFunctionState:
			yield(state, "completed")
	var flowmap: RiverFlowMap = load(_river_flow_data_path())
	_flow_texture.texture = flowmap.texture
	_flow_texture.position = flowmap.position
	_flow_texture.material.set_shader_param("scale", flowmap.scale)
	_flow_texture.material.set_shader_param("flow_speed", flow_speed)
	_flow_texture.material.set_shader_param("wave_texture", wave_texture)
	_flow_texture.visible = true

func _river_flow_data_path() -> String:
	return "res://data/river_flowmaps/" + str(get_path()).replace("/", "_") + ".tres"

func _bounding_box(polygon: PoolVector2Array) -> Rect2:
	var min_vec := polygon[0]
	var max_vec := polygon[0]
	for i in polygon.size() - 1:
		var vec : Vector2 = polygon[i+1]
		if vec.x < min_vec.x:
			min_vec.x = vec.x
		if vec.y < min_vec.y:
			min_vec.y = vec.y
		if vec.x > max_vec.x:
			max_vec.x = vec.x
		if vec.y > max_vec.y:
			max_vec.y = vec.y
	var size := max_vec - min_vec
	return Rect2(min_vec, size)

func _generate_flow() -> void:
	# TODO: Create a texture. 
	#       Go through each pixel:
	#           Work out its direction (?!) based on nearest points on $Path
	#           Populate each pixel with an RGB value based on the direction
	#       Create a polygon the same shape as the collision polgygon ($Polygon2D)
	#       Give this polygon a shader material that uses the water flow shader
	#       Feed this texture into the shader for the water material
	var flow_data := Image.new()
	var bounds := _bounding_box(_polygon.polygon)
	var width: int = int(ceil(bounds.size.x))
	var height: int = int(ceil(bounds.size.y))
	var offset_x: int = int(floor(bounds.position.x))
	var offset_y: int = int(floor(bounds.position.y))
	flow_data.create(width, height, false, Image.FORMAT_RGBA8)
	flow_data.lock()
	print(width, "x", height)
	_bar.visible = true
	_bar.max_value = height
	for j in height:
		for i in width:
			_compute_flow_at_pixel(i, j, flow_data, offset_x, offset_y)
		yield(get_tree(), "idle_frame")
		_bar.value = j
	_bar.value = height
	flow_data.unlock()
	var texture := ImageTexture.new()
	texture.create_from_image(flow_data)
	var resource := RiverFlowMap.new()
	resource.texture = texture
	resource.position = bounds.position
	resource.scale = bounds.size
	ResourceSaver.save(_river_flow_data_path(), resource)
	_flow_texture.texture = texture
	_flow_texture.position = bounds.position
	_bar.visible = false

func _compute_flow_at_pixel(x: int, y: int, image: Image, ox:=0, oy:=0) -> void:
	if not Geometry.is_point_in_polygon(Vector2(x + ox, y + oy), _polygon.polygon):
		return
	var velocity := _flow_direction_at_pixel(Vector2(x, y)).normalized()
	var r: float = (velocity.x + 1) / 2
	var g: float = (velocity.y + 1) / 2
	var color : Color = Color(r, g, 0.5, 1)
	image.set_pixel(x, y, color)

func _flow_direction_at_pixel(pos: Vector2) -> Vector2:
	var flow_path_offset := 10
	var nearest_path_offset := _path.curve.get_closest_offset(pos)
	var nearest_path_point := _path.curve.interpolate_baked(nearest_path_offset)
	var previous_offset := max(0, nearest_path_offset - flow_path_offset)
	var next_offset := min(nearest_path_offset + flow_path_offset, _path.curve.get_baked_length())
	var previous_point := _path.curve.interpolate_baked(previous_offset)
	var next_point := _path.curve.interpolate_baked(next_offset)
	var flow_direction := next_point - previous_point
	var flow_offset := nearest_path_point - pos
	return flow_direction + flow_offset / 2

# DEBUGGING
# TODO: Remove when river is working
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var local_pos := get_local_mouse_position()
		var dir := _flow_direction_at_pixel(local_pos)
		var line := Line2D.new()
		add_child(line)
		line.add_point(local_pos)
		line.add_point(local_pos + dir.normalized() * 48)
		line.default_color = Color.white
		line.width_curve = Curve.new()
		line.width_curve.add_point(Vector2(0, 1))
		line.width_curve.add_point(Vector2(1, 0))


extends Area2D
class_name River

export(float) var flow_speed: float = 128.0

onready var _polygon: CollisionPolygon2D = $Polygon2D as CollisionPolygon2D
onready var _path: Path2D = $Path as Path2D
onready var _flow_texture: Sprite = $Flowmap as Sprite

onready var _bar: ProgressBar = $ProgressBar as ProgressBar

var is_generated: bool = false

func _ready():
	# TODO: Create a water shader
	#       Have it discard pixels that aren't over a waterway (using the blue color channel? or transparent on a layer?)
	#       Give it a speed, and wave thickness, and wave colour
	_bar.visible = false
	print(_river_flow_data_path())
	if not ResourceLoader.exists(_river_flow_data_path()):
		var state = _generate_flow()
		if state is GDScriptFunctionState:
			yield(state, "completed")
	var flowmap: RiverFlowMap = load(_river_flow_data_path())
	_flow_texture.texture = flowmap.texture
	_flow_texture.position = flowmap.position
	_flow_texture.material.set_shader_param("scale", flowmap.scale)
	_flow_texture.material.set_shader_param("flow_speed", flow_speed)

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
			_compute_flow_at_pixel(i, j, flow_data, offset_x, offset_y, width, height)
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

func _compute_flow_at_pixel(x: int, y: int, image: Image, ox:=0, oy:=0, width:=0, height:=0) -> void:
	if not Geometry.is_point_in_polygon(Vector2(x + ox, y + oy), _polygon.polygon):
		return
	var velocity := _flow_direction_at_pixel(Vector2(x + ox, y + oy))
	var r: float = (clamp(velocity.x / width, -1, 1) + 1) / 2
	var g: float = (clamp(velocity.y / height, -1, 1) + 1) / 2
	var color : Color = Color(r, g, 0.5, 1)
	image.set_pixel(x, y, color)

func _flow_direction_at_pixel(pos: Vector2) -> Vector2:
	# TODO: I don't think this is working. I think it's a positional thing. Some are local, some are global. Maybe?
	var nearest_path_point := _path.curve.get_closest_point(_path.to_local(pos))
	var previous: Vector2 = Vector2.ZERO
	var current: Vector2 = Vector2.ZERO
	var next: Vector2 = pos
	for point in _path.curve.get_baked_points():
		previous = current
		current = next
		next = point
		if current == nearest_path_point:
			break
	if current == nearest_path_point:
		return next - current
	else:
		return current - previous

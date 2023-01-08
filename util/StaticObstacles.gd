extends NavigationPolygonInstance

func _ready():
	_cut_away_polygons()

func _cut_away_polygons() -> void:
	var nav_polygon := navpoly
	for child in get_children():
		var composite_cut_outs := PoolVector2Array()
		if not child is CollisionPolygon2D:
			continue
		var polygon := child as CollisionPolygon2D
		var shape := polygon.polygon
		var glob_trans := polygon.global_transform
		for vertex in shape:
			composite_cut_outs.append(glob_trans.xform(vertex))
		nav_polygon.add_outline(composite_cut_outs)
	nav_polygon.make_polygons_from_outlines()
	navpoly = nav_polygon
	enabled = false
	enabled = true

func add_obstacle(glob_trans: Transform2D, polygon: PoolVector2Array) -> void:
	var nav_polygon := navpoly
	var adjusted_polygon := PoolVector2Array()
	for vertex in polygon:
		adjusted_polygon.append(glob_trans.xform(vertex))
	nav_polygon.add_outline(adjusted_polygon)
	nav_polygon.make_polygons_from_outlines()
	navpoly = nav_polygon
	enabled = false
	enabled = true

func add_obstacle_rect(glob_trans: Transform2D, rect: RectangleShape2D) -> void:
	var polygon := PoolVector2Array()
	var x := rect.extents.x + 4
	var y := rect.extents.y + 4
	polygon.append(Vector2(-x, -y))
	polygon.append(Vector2(x, -y))
	polygon.append(Vector2(x, y))
	polygon.append(Vector2(-x, y))
	polygon.append(Vector2(-x, -y))
	add_obstacle(glob_trans, polygon)

extends Node2D
tool


const POINTS := 32

export(float) var inner_radius
export(float) var outer_radius
export(float) var span_radians

func _draw():
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([Color(1.0, 1.0, 1.0)])
	for i in range(POINTS + 1):
		var angle_point = (i * span_radians) / POINTS
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * inner_radius)
	for i in range(POINTS, -1, -1):
		var angle_point = (i * span_radians) / POINTS
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * outer_radius)
	draw_polygon(points_arc, colors, PoolVector2Array(), null, null, true)
	$CollisionPolygon2D.polygon = points_arc

func setup_resource(var i_radius : float, var o_radius : float, var _span : float ):
	inner_radius = i_radius
	outer_radius = o_radius
	span_radians = _span
	update()

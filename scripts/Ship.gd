extends Node2D
tool

export(float) var inner_radius
export(float) var outer_radius
export(float) var span_radians
var points_vec = PoolVector2Array()

export(PoolColorArray) var ship_color
export(Color) var outline_color

const INSERTER_RADIUS_MOD = 0.2

const SHIP_SIZE = 10.0

func _ready():
	outline_color = Color(0.8, 0.8, 0.8)
	ship_color = PoolColorArray([Color(0.6, 0.6, 0.6, 1.0)])

func _draw():
	var radius_mod : float = (outer_radius - inner_radius) * INSERTER_RADIUS_MOD
	points_vec.resize(0)
	points_vec.push_back(Vector2(cos(+span_radians/2.0), sin(+span_radians/2.0)) * (outer_radius - radius_mod))
	points_vec.push_back(Vector2(outer_radius + radius_mod, 0))
	points_vec.push_back(Vector2(cos(-span_radians/2.0), sin(-span_radians/2.0)) * (outer_radius - radius_mod))
	#
	points_vec.push_back(Vector2(outer_radius + SHIP_SIZE * radius_mod, 0))
	#
	points_vec.push_back(points_vec[0])
	#
	draw_polygon(points_vec, ship_color, PoolVector2Array(), null, null, true)
	draw_polyline(points_vec, outline_color, 2.0, true)
	
func setup_resource(var i_radius : float, var o_radius : float, var _span : float ):
	inner_radius = i_radius
	outer_radius = o_radius
	span_radians = _span
	update()
	
func configure_ship(var recipy : String):
	outline_color = Global.data[recipy]["color"]
	ship_color[0] = Color.from_hsv(outline_color.h, 
		outline_color.s - (outline_color.s * 0.75),  # Lighten
		outline_color.v)
	update()

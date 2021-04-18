extends Area2D
tool

const POINTS := 32

onready var id = get_tree().get_root().find_node("InfoDialog", true, false) 

export(float) var inner_radius
export(float) var outer_radius
export(float) var span_radians
export(PoolColorArray) var factory_color
export(bool) var colliding

enum {FACTORY_UNSET, FACTORY_SHUNT, FACTORY_MAKE}
export(int) var mode = FACTORY_UNSET
export(String) var recipy = ""

func _draw():
	var points_arc = PoolVector2Array()
	var factory_outline_color = Color(0.0, 1.0, 1.0)
	for i in range(POINTS + 1):
		var angle_point = ((i * span_radians) / POINTS) - span_radians/2.0
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * inner_radius)
	for i in range(POINTS, -1, -1):
		var angle_point = ((i * span_radians) / POINTS) - span_radians/2.0
		points_arc.push_back(Vector2(cos(angle_point), sin(angle_point)) * outer_radius)
	points_arc.push_back(points_arc[0])
	draw_polygon(points_arc, factory_color, PoolVector2Array(), null, null, true)
	draw_polyline(points_arc, factory_outline_color, 3.0, true)
	$CollisionPolygon2D.polygon = points_arc

func setup_resource(var i_radius : float, var o_radius : float, var _span : float ):
	inner_radius = i_radius
	outer_radius = o_radius
	span_radians = _span
	factory_color = PoolColorArray([Color(1.0, 1.0, 1.0, 0.5)])
	colliding = false
	update()

func _on_FactoryTemplate_area_entered(area):
	if name == "FactoryTemplate":
		factory_color = PoolColorArray([Color(1.0, 0.0, 0.0, 0.5)])
		colliding = true
		update()

func _on_FactoryTemplate_area_exited(area):
	if name == "FactoryTemplate" and get_overlapping_areas().size() == 0:
		factory_color = PoolColorArray([Color(1.0, 1.0, 1.0, 0.5)])
		colliding = false
		update()


func _on_FactoryTemplate_input_event(var _viewport, var event, var _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		id.show_factory_diag(self)

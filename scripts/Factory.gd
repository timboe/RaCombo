extends Area2D
tool

const POINTS := 32

onready var id = get_tree().get_root().find_node("InfoDialog", true, false) 
onready var ring = find_parent("Ring*")

export(float) var inner_radius
export(float) var outer_radius
export(float) var span_radians

export(PoolColorArray) var factory_color
export(Color) var factory_outline_color
export(bool) var colliding

export(int) var mode = Global.BUILDING_UNSET
export(String) var recipy = null
export(String) var descriptive_name = ""

var points_vec = PoolVector2Array()

func _ready():
	reset()

func add_arc(var points : int,
  var start : float, var end : float,
   var centre : Vector2, var radius : float):
	var span_radians = end - start
	for i in range(points + 1):
		var angle_point = ((i * span_radians) / POINTS) + start
		points_vec.push_back(centre + (Vector2(cos(angle_point), sin(angle_point)) * radius))

func _draw():
	
	#mode = BUILDING_EXTRACTOR
	
	var radius_mod : float = (outer_radius - inner_radius) * Global.INSERTER_RADIUS_MOD
	var span_mod = span_radians * Global.INSERTER_RADIUS_MOD
	points_vec.resize(0)
	###
	if mode == Global.BUILDING_INSERTER:
		points_vec.push_back(Vector2(cos(-span_radians/2.0), sin(-span_radians/2.0)) * (inner_radius + radius_mod))
		points_vec.push_back(Vector2(inner_radius - radius_mod, 0))
		points_vec.push_back(Vector2(cos(+span_radians/2.0), sin(+span_radians/2.0)) * (inner_radius + radius_mod))
	elif mode == Global.BUILDING_FACTORY and Global.data[recipy]["mode"] == "insert":
		add_arc(POINTS, -span_radians/2.0, -span_mod, Vector2.ZERO, inner_radius)
		points_vec.push_back(Vector2(inner_radius - radius_mod, 0))
		add_arc(POINTS, +span_mod, +span_radians/2.0, Vector2.ZERO, inner_radius)
	else:
		add_arc(POINTS, -span_radians/2.0, +span_radians/2.0, Vector2.ZERO, inner_radius)
	###
	if mode == Global.BUILDING_FACTORY:
		var mod_r = inner_radius + (outer_radius - inner_radius)/2.0
		var mod_angle = span_radians/2.0 + span_radians * Global.INSERTER_RADIUS_MOD
		points_vec.push_back(Vector2(cos(mod_angle), sin(mod_angle)) * mod_r)
#	if true or mode == BUILDING_FACTORY: # Curvy edge?
#		var centre = Vector2.ZERO
#		var small_circ_radius = (outer_radius - inner_radius)/2.0
#		centre.x = inner_radius + small_circ_radius
#		centre.y = tan(span_radians/2.0) * centre.x
#		add_arc(POINTS/2, PI, -PI, centre, small_circ_radius)
	###
	if mode == Global.BUILDING_EXTRACTOR:
		points_vec.push_back(Vector2(cos(+span_radians/2.0), sin(+span_radians/2.0)) * (outer_radius - radius_mod))
		points_vec.push_back(Vector2(outer_radius + radius_mod, 0))
		points_vec.push_back(Vector2(cos(-span_radians/2.0), sin(-span_radians/2.0)) * (outer_radius - radius_mod))
	elif mode == Global.BUILDING_FACTORY and Global.data[recipy]["mode"] == "extract":
		add_arc(POINTS, +span_radians/2.0, +span_mod, Vector2.ZERO, outer_radius)
		points_vec.push_back(Vector2(outer_radius + radius_mod, 0))
		add_arc(POINTS, -span_mod, -span_radians/2.0, Vector2.ZERO, outer_radius)
	else:
		add_arc(POINTS, +span_radians/2.0, -span_radians/2.0, Vector2.ZERO, outer_radius)
	###
	if mode == Global.BUILDING_FACTORY:
		var mod_r = inner_radius + (outer_radius - inner_radius)/2.0
		var mod_angle = -span_radians/2.0 - span_radians * Global.INSERTER_RADIUS_MOD
		points_vec.push_back(Vector2(cos(mod_angle), sin(mod_angle)) * mod_r)
	###
	points_vec.push_back(points_vec[0])
	###
	draw_polygon(points_vec, factory_color, PoolVector2Array(), null, null, true)
	draw_polyline(points_vec, factory_outline_color, 2.0, true)
	$CollisionPolygon2D.polygon = points_vec
	$FactoryProcess.angle_back = -span_radians/2.0
	$FactoryProcess.angle_front = span_radians/2.0
	#
	$TextureButton.rect_position.x = inner_radius
	$Label.rect_position.x = inner_radius + 21 # Magic number from size of rotated text box
	
func configure_building(var _mode : int, var _recipy : String):
	mode = _mode
	recipy = _recipy
	$FactoryProcess.configure(_mode, _recipy)
	factory_outline_color = Global.data[recipy]["color"]
	factory_color[0] = Color.from_hsv(factory_outline_color.h, 
		factory_outline_color.s - (factory_outline_color.s * 0.75),  # Lighten
		factory_outline_color.v)
	$Label.text = Global.data[recipy]["name"] + ("+" if Global.data[recipy]["mode"] == "extract" else "-")
	update()
	set_descriptive_name()
	if mode == Global.BUILDING_EXTRACTOR and ring.ring_number + 1 == Global.rings:
		var sr = ring.get_node("ShipRotationTemplate").duplicate(DUPLICATE_SCRIPTS|DUPLICATE_GROUPS)
		sr.name = "ShipRotation1"
		ring.add_child(sr, true)
		sr.global_rotation = self.global_rotation
		$FactoryProcess.ship = sr.get_child(0)
		$FactoryProcess.ship.configure_ship(recipy)
	
func get_process_node():
	return $FactoryProcess

func reset():
	mode = Global.BUILDING_UNSET
	recipy = null
	factory_outline_color = Color(0.8, 0.8, 0.8)
	factory_color = PoolColorArray([Color(0.6, 0.6, 0.6, 1.0)])
	$FactoryProcess.reset()
	$Label.text = ""
	update()
	set_descriptive_name()

func remove():
	$FactoryProcess.reset()
	queue_free()

func lane_cleared(var lane : MultiMeshInstance2D):
	$FactoryProcess.lane_clared(lane)
	
func set_descriptive_name():
	descriptive_name = String(name.to_int()) + " "
	if mode == Global.BUILDING_UNSET:
		descriptive_name += "Unassigned Satelite"
	else:
		descriptive_name += Global.data[recipy]["name"]
		descriptive_name += "+" if Global.data[recipy]["mode"] == "extract" else "-"
	if mode == Global.BUILDING_FACTORY:
		descriptive_name += " " + "Factory"
	elif mode == Global.BUILDING_INSERTER:
		descriptive_name += " " + "Inserter"
	elif mode == Global.BUILDING_EXTRACTOR:
		descriptive_name += " " + "Extractor"

func setup_resource(var i_radius : float, var o_radius : float, var _span : float ):
	inner_radius = i_radius
	outer_radius = o_radius
	span_radians = _span
	factory_color = PoolColorArray([Color(0.6, 0.6, 0.6, 1.0)])
	colliding = false
	update()

func _on_FactoryTemplate_area_entered(_area):
	if name == "FactoryTemplate":
		factory_color = PoolColorArray([Color(0.5, 0.0, 0.17, 1.0)])
		colliding = true
		update()

func _on_FactoryTemplate_area_exited(_area):
	if name == "FactoryTemplate" and get_overlapping_areas().size() == 0:
		factory_color = PoolColorArray([Color(0.6, 0.6, 0.6, 1.0)])
		colliding = false
		update()

func _on_TextureButton_pressed():
	id.show_building_diag(self)

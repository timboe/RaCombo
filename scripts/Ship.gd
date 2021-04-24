extends Node2D
tool

const TWOPI := PI * 2.0
const SHIP_SIZE = 10.0
const SHIP_APPEAR_TIME := 5.0

export(float) var radius
export(float) var inner_radius
export(float) var outer_radius
export(float) var span_radians

export(bool) var built = false

export(int) var output_storage = 0

export(PoolColorArray) var ship_color
export(Color) var outline_color

var factory

var points_vec = PoolVector2Array()

var spies = [] # The multimeshes currently spying on the storage content here

onready var id = get_tree().get_root().find_node("InfoDialog", true, false) 

func _ready():
	outline_color = Color(0.8, 0.8, 0.8, 1.0)
	ship_color = PoolColorArray([Color(0.6, 0.6, 0.6, 1.0)])
	set_physics_process(false)

func _draw():
	var radius_mod : float = (outer_radius - inner_radius) * Global.INSERTER_RADIUS_MOD
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
	
func setup_resource(var _radius : float, var i_radius : float, var o_radius : float, var _span : float):
	inner_radius = i_radius
	outer_radius = o_radius
	radius = _radius
	span_radians = _span
	
func configure_ship(var recipy : String, var _factory : Node2D):
	outline_color = Global.data[recipy]["color"]
	factory = _factory
	ship_color[0] = Global.lighten(outline_color)
	update()
	set_physics_process(true)
	visible = true
	get_parent().visible = true
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1),
		SHIP_APPEAR_TIME, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func _on_Tween_tween_all_completed():
	built = true
	
func depart():
	factory.lane_cleared(self, true) # true = and queue new ship
	factory = null
	id.update_diag()
	# TODO fly away before remove
	remove()
	
func remove():
	for spy in spies:
		spy.reset()
	spies.clear()
	get_parent().queue_free()
	
func set_spy(var spy):
	spies.append(spy)

func try_send(var _angle : float, var _direction : int) -> bool:
	if not built or output_storage >= Global.MAX_STORAGE:
		return false
	output_storage += 1
	if output_storage == Global.MAX_STORAGE:
		depart()
	return true

func _physics_process(delta):
	var angular_velocity = Global.M_SOL/radius
	get_parent().rotation += delta * angular_velocity
	if get_parent().rotation > TWOPI:
		get_parent().rotation -= TWOPI




extends Node2D
tool

const DENSITY := 0.2
const M_SOL := 80
const LANE_OFFSET := 5.0;
const TWOPI := PI * 2.0
const FACTORY_SPAN_DEGREES := 45.0

export(int, 9) var set_ring
export(int, 1, 4) var set_lanes
export(Color) var set_debug_color

export(Array, float) var radius_array
export(float) var angular_velocity
export(int) var n

func _ready():
	rotation = 0
	
func add_to_ring(var angle : float, var lane : int):
	var angle_mod = angle - rotation
	if angle_mod < 0.0:
		angle_mod += TWOPI
	elif angle_mod > TWOPI:
		angle_mod -= TWOPI
	return get_child(lane).add_to_ring(angle_mod)
	
func set_radius(var r : float):
	radius_array.resize(set_lanes)
	for i in range(set_lanes):
		radius_array[i] = r + (i*LANE_OFFSET)
	# To be physical this should be ~ sqrt(1/r)
	angular_velocity = M_SOL/r
	var circ : float = 2.0 * PI * r
	n = circ * DENSITY

func setup_resource(var r : float):
	set_radius(r)
	var count : int = 0
	for c in get_children():
		if not c is MultiMeshInstance2D:
			continue
		c.setup_resource(n, radius_array[count])
		count += 1
	#vertical drop in ring0
	var r0 : Node2D = $"../Ring0"
	var r0_outer_r : float = r0.radius_array[ r0.set_lanes - 1 ] + LANE_OFFSET/2.0
	var drop : = sin(deg2rad(FACTORY_SPAN_DEGREES)) * r0_outer_r
	var inner_r : float = radius_array[0] - LANE_OFFSET/2.0
	var outer_r : float = radius_array[set_lanes-1] + LANE_OFFSET/2.0
	var this_ring_angle : float = asin(drop / outer_r)
	$FactoryTemplate.setup_resource(inner_r, outer_r, this_ring_angle)
	$Line2D.default_color = set_debug_color
	#$Outline.highlight = false

func _physics_process(delta):
	rotation += delta * angular_velocity
	if rotation > TWOPI:
		rotation -= TWOPI

extends Node2D

const DENSITY := 0.2
const LANE_OFFSET := 5.0;
const TWOPI := PI * 2.0
const FACTORY_SPAN_DEGREES := 45.0

export(int, 1, 8) var set_lanes
export(Color) var set_debug_color

export(int) var ring_number
export(Array, float) var radius_array
export(float) var angular_velocity
export(int) var n

func serialise() -> Dictionary:
	var d := {}
	d["rotation"] = $Rotation.rotation
	#
	d["lanes"] = set_lanes
	d["debug_color"] = set_debug_color.to_html()
	d["ring_number"] = ring_number
	d["radius_array"] = radius_array
	d["angular_velocity"] = angular_velocity
	d["n"] = n
	d["lanes"] = set_lanes
	for lane in get_lanes():
		d[lane.name] = lane.serialise()
	d["outline"] = $Outline.serialise()
	return d

func _ready():
	$Rotation.rotation = 0
	$Rotation/FactoryTemplate.visible = false
	$ShipRotationTemplate.visible = false
	ring_number = name.to_int()
	if ring_number != 0:
		for i in range(4,8):
			get_lane(i).name = "deleted"
			get_lane(i).queue_free()
	
func reset():
	for l in get_lanes():
		if l.lane_content != null:
			l.deregister_resource()
	for f in get_factories():
		f.remove()
	$"/root/Game/SomethingChanged".something_changed()
	
func add_to_ring(var angle : float, var lane : int):
	var angle_mod = angle - $Rotation.rotation
	return get_lane(lane).add_to_ring(angle_mod)

func set_factory_template_visible(var v : bool):
	$Rotation/FactoryTemplate.visible = v
	if v:
		$Rotation/FactoryTemplate._on_FactoryTemplate_area_exited(null)
	
func new_factory():
	var factory_template = $Rotation/FactoryTemplate
	if factory_template.colliding:
		return
	var new_factory = factory_template.duplicate(DUPLICATE_SCRIPTS|DUPLICATE_SIGNALS|DUPLICATE_GROUPS)
	new_factory.name = "FactoryInstance1"
	get_node("Rotation/Factories").add_child(new_factory, true)
	new_factory.set_owner(get_tree().get_root())
	new_factory.get_node("FactoryProcess").add_to_group("FactoryProcessGroup", true)
	var new_factory_angle_start = (new_factory.global_rotation - new_factory.span_radians/2.0) - $Rotation.rotation
	var new_factory_angle_end = (new_factory.global_rotation + new_factory.span_radians/2.0) - $Rotation.rotation
	new_factory.factory_angle_start = new_factory_angle_start
	new_factory.factory_angle_end = new_factory_angle_end
	for l in get_lanes():
		l.set_range_fillable(new_factory_angle_start, new_factory_angle_end, false)
	print("Factory ",new_factory.name," placed")

func get_lane(var i) -> Node:
	return $Rotation/Lanes.get_child(i)
	
func get_lanes() -> Array:
	return $Rotation/Lanes.get_children()

func get_factories() -> Array:
	return $Rotation/Factories.get_children()
	
func register_resource(var lane : int, var reg_resource : String, var provinace : Node):
	get_lane(lane).register_resource(reg_resource, provinace)

func get_free_or_existing_lane(var desired_resource : String) -> int:
	var max_lanes = get_lanes().size() if ring_number == 0 else Global.lanes
	# Existing
	for l in range(max_lanes):
		if get_lane(l).lane_content != null and get_lane(l).lane_content == desired_resource and get_lane(l).forbid_send == false:
			return l
	# Free
	for l in range(max_lanes):
		if get_lane(l).lane_content == null and get_lane(l).forbid_send == false:
			return l
	return -1
	
func set_radius(var r : float):
	radius_array.resize(set_lanes)
	for i in range(set_lanes):
		radius_array[i] = r + ((i%4)*LANE_OFFSET)
	# To be physical this should be ~ sqrt(1/r)
	angular_velocity = Global.M_SOL/r
	var circ : float = 2.0 * PI * r
	n = circ * DENSITY

# TODO rename this to init or something
func setup_resource(var r : float):
	set_radius(r)
	var count : int = 0
	for l in range(set_lanes):
		get_lane(l).setup_resource(n, radius_array[count])
		count += 1
	#vertical drop in ring0's factory template. Used to set angular width of all factory templates
	var r0 : Node2D = $"../Ring0"
	var r0_outer_r : float = r0.radius_array[ r0.set_lanes - 1 ] + LANE_OFFSET/2.0
	var drop : = sin(deg2rad(FACTORY_SPAN_DEGREES)) * r0_outer_r
	var inner_r : float = radius_array[0] - LANE_OFFSET/2.0
	var outer_r : float = radius_array[set_lanes-1] + LANE_OFFSET/2.0
	var this_ring_angle : float = asin(drop / outer_r)
	$Rotation/FactoryTemplate.setup_resource(inner_r, outer_r, this_ring_angle)
	$ShipRotationTemplate/Ship.setup_resource(r, inner_r, outer_r, this_ring_angle)
	$Rotation/Line2D.default_color = set_debug_color
	#$Outline.highlight = false

func _physics_process(delta):
	$Rotation.rotation += delta * angular_velocity
	if $Rotation.rotation > TWOPI:
		$Rotation.rotation -= TWOPI

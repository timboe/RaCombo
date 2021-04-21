extends Area2D
tool

const POINTS := 32
const MAX_STORAGE := 32

onready var id = get_tree().get_root().find_node("InfoDialog", true, false) 

export(float) var inner_radius
export(float) var outer_radius
export(float) var span_radians
export(float) var angle_back
export(float) var angle_front
export(PoolColorArray) var factory_color
export(bool) var colliding

enum {BUILDING_UNSET, BUILDING_EXTRACTOR, BUILDING_INSERTER, BUILDING_FACTORY}
export(int) var mode = BUILDING_UNSET
export(String) var recipy = ""

var input_storage = [] # Number of stored items per input
var input_content = [] # List of strings, name of each input
var input_lanes = [] # This is a list of lists. Providers of each input

export(int) var output_storage = 0
export(String) var output_content = null
var output_lane : MultiMeshInstance2D = null


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
	angle_back = -span_radians/2.0
	angle_front = span_radians/2.0
	
func configure_building(var _mode : int, var _recipy : String):
	mode = _mode
	recipy = _recipy
	input_content.clear()
	input_storage.clear()
	input_lanes.clear()
	if mode == BUILDING_FACTORY:
		for i in Global.recipies[recipy]["input"].size():
			input_content.append(Global.recipies[recipy]["input"][i])
			input_storage.append(0)
			input_lanes.append([])
	else:
		input_content.append(recipy) # recipy is just the thing we are moving
		input_storage.append(0)
		input_lanes.append([])
	# Output
	output_content = recipy
	output_storage = 0
	output_lane = null
	lane_system_changed()
	
func lane_cleared(var lane : MultiMeshInstance2D):
	if mode == BUILDING_UNSET: # Called on all buildings by the Bin fn
		return
	var something_changed : bool = false
	if output_lane == lane:
		output_lane = null
	for input_resource in input_lanes:
		for idx in range(input_resource.size() -1, -1):
			if input_resource[idx] == lane:
				input_resource.remove(idx)
	check_process()
	# We don't do something_changed here because the higher level bin-script will call it
	
func lane_system_changed():
	if mode == BUILDING_UNSET: # Called on all buildings by SomethingChanged
		return
	var something_changed = false
	# Input
	var ring := get_ring()
	if mode == BUILDING_FACTORY:
		# We check the two outermost rings for input
		for i in range(ring.set_ring + 1, ring.set_ring + 3):
			if i >= Global.rings:
				break
			for l in ring.get_parent().get_child(i).get_lanes():
				if l.lane_content == null:
					continue
				for input_counter in range(input_content.size()):
					if l.lane_conent == input_content[input_counter]:
						if not input_lanes[input_counter].has(l):
							input_lanes[input_counter].append(l)
							print("The ",name," will now import ",input_content[input_counter]," from ",l," (total of ",input_lanes[input_counter].size()," sources)")
							something_changed = true
	else: # Inserter or extractor
		input_lanes.append([])
		# input-resources propagate inwards
		var in_ring_n = ring.set_ring + 1 if Global.data[input_content[0]]["mode"] == "insert" else ring.set_ring - 1
		if in_ring_n != Global.rings: # If not trying to insert from outside the outermost ring
			for l in ring.get_parent().get_child(in_ring_n).get_lanes():
				if l.lane_content != null and l.lane_content == input_content[0]:
					if not input_lanes[0].has(l):
						input_lanes[0].append(l)
						print("The ",name," will now import ",input_content[0]," from ",l," (total of ",input_lanes[0].size()," sources)")
						something_changed = true
	# Output
	var out_ring_n = ring.set_ring - 1 if Global.data[output_content]["mode"] == "insert" else ring.set_ring + 1
	if out_ring_n == Global.rings:
		print("TODO export and something_changed for export")
	else:
		var out_ring = ring.get_parent().get_child(out_ring_n)
		var out_lane_id = out_ring.get_free_or_existing_lane(output_content)
		if out_lane_id != -1:
			var the_out_lane = out_ring.get_lane(out_lane_id)
			if output_lane != the_out_lane:
				output_lane = the_out_lane
				the_out_lane.register_resource(output_content, self)
				print("The ",name," will now export ",output_content," to ",the_out_lane)
				something_changed = true
	check_process()
	if something_changed:
		$"/root/Game/SomethingChanged".something_changed()
	
func check_process():
	# Do we have all inputs and outputs?
	var satisfy_all : bool = true
	if output_lane == null:
		satisfy_all = false
	for il in input_lanes:
		if il.size() == 0:
			satisfy_all = false
	if satisfy_all:
		set_physics_process(true)
		return
	# OK - what about inputs, are there input lanes which are not yet full?
	var can_gather_inputs : bool = false
	if mode == BUILDING_FACTORY:
		for i in range(input_lanes.size()):
			if input_lanes[i].size() > 0 and input_storage[i] < MAX_STORAGE:
				can_gather_inputs = true
				break
	else: # Inserters/ectractors only make use of output_storage
		if input_lanes[0].size() > 0 and output_storage < MAX_STORAGE:
			can_gather_inputs = true
	if can_gather_inputs:
		set_physics_process(true)
		return
	# OK - but do we still have outputs to send?
	var can_send_outputs : bool = false
	if output_storage > 0 and output_lane != null:
		can_send_outputs = true
	if can_send_outputs:
		set_physics_process(true)
		return
	# Deactivate until there is a change in the lane situation
	set_physics_process(false)
	
func _physics_process(_delta):
	if mode == BUILDING_EXTRACTOR:
		# Inputs
		if output_storage < MAX_STORAGE:
			for l in input_lanes[0]:
				l.try_capture(angle_back + global_rotation, self, l.OUTWARDS)
		# Output
		if output_storage > 0 and output_lane != null:
			var accepted = output_lane.try_send(global_rotation, output_lane.OUTWARDS)
			output_storage -= 1 if accepted else 0
	elif mode == BUILDING_INSERTER:
		# Inputs
		if output_storage < MAX_STORAGE:
			for l in input_lanes[0]:
				l.try_capture(angle_front + global_rotation, self, l.INWARDS)
		# Output
		if output_storage > 0 and output_lane != null:
			var accepted = output_lane.try_send(global_rotation, output_lane.INWARDS)
			output_storage -= 1 if accepted else 0
				
# Called asynchronously when try_capture succedes 
func add_item(var lane : MultiMeshInstance2D):
	if mode != BUILDING_FACTORY:
		output_storage += 1

func get_ring() -> Node2D:
	# Factory -> Factories -> Rotation -> Ring
	return get_parent().get_parent().get_parent() as Node2D

func setup_resource(var i_radius : float, var o_radius : float, var _span : float ):
	inner_radius = i_radius
	outer_radius = o_radius
	span_radians = _span
	factory_color = PoolColorArray([Color(1.0, 1.0, 1.0, 0.5)])
	colliding = false
	update()

func _on_FactoryTemplate_area_entered(_area):
	if name == "FactoryTemplate":
		factory_color = PoolColorArray([Color(1.0, 0.0, 0.0, 0.5)])
		colliding = true
		update()

func _on_FactoryTemplate_area_exited(_area):
	if name == "FactoryTemplate" and get_overlapping_areas().size() == 0:
		factory_color = PoolColorArray([Color(1.0, 1.0, 1.0, 0.5)])
		colliding = false
		update()


func _on_FactoryTemplate_input_event(var _viewport, var event, var _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		print("Clicked ",name)
		id.show_building_diag(self)

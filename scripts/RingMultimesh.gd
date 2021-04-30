extends MultiMeshInstance2D
tool

const DISABLE := 100.0
const INJECT_VELOCITY := 128.0

export(float) var radians_per_slot
export(float) var radius
export(String) var lane_content = null
export(bool) var source = false
export(bool) var sink = false
export(bool) var forbid_send = false
var lane_provinance : Array = [] # Note: NOT exported, becomes shared!
var laneswap_target : Array = [null] 

var ring_radius = load("res://scripts/RingSystem.gd").new().RING_RADIUS
var in_flight = []

# Called when the node enters the scene tree for the first time.
func _ready():
	multimesh = MultiMesh.new()
	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_8BIT
	multimesh.mesh = QuadMesh.new()
	multimesh.mesh.set_size(Vector2(10,10))
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	
func wrap_i(var i : int):
	while i < 0:
		i += multimesh.instance_count
	while i >= multimesh.instance_count:
		i -= multimesh.instance_count
	return i
	
func wrap_a(var f : float):
	while f < 0:
		f += PI*2
	while f >= PI*2:
		f -= PI*2
	return f
	
func add_to_ring(var angle : float):
	var slot : int = round(wrap_a(angle) / radians_per_slot)
	# Try and fill up ahead
	for i in range(slot, slot+3):
		var i_wrap = wrap_i(i)
		if get_slot_empty_and_fillable(i_wrap):
			set_slot_filled(i_wrap, true, true)
			return true
	# Or, if we cannot - then try and fill up behind
	for i in range(slot-1, slot-4, -1):
		var i_wrap = wrap_i(i)
		if get_slot_empty_and_fillable(i_wrap):
			set_slot_filled(i_wrap, true, true)
			return true
	return false
	
func set_range_fillable(var start : float, var end : float, var fillable : bool):
	var slot_start : int = wrap_i(round(wrap_a(start) / radians_per_slot))
	var slot_end : int = wrap_i(round(wrap_a(end) / radians_per_slot))
	while true:
		set_slot_fillable(slot_start, fillable)
		slot_start = wrap_i(slot_start + 1)
		if (slot_start == slot_end): break

func set_as_source_lane():
	source = true
	sink = false
	for i in multimesh.instance_count:
		set_slot_filled(i, true, true)

func set_as_sink_lane():
	sink = true
	source = false
	for i in multimesh.instance_count:
		set_slot_filled(i, false, true)
		
func set_laneswap(var other_lane : MultiMeshInstance2D):
	set_as_sink_lane()
	laneswap_target[0] = other_lane

func register_resource(var new_resource : String, var provinance : Node):
	if lane_content != null and new_resource != lane_content:
		print("ERROR in ",name," of ", get_parent().get_parent().get_parent().name, " trying to reg ",new_resource," into lane containing ",lane_content)
		return
	# If we are a sink, we can accept many different inputs
	if not sink:
		lane_content = new_resource
		modulate = Global.data[lane_content]["color"]
		texture = load("res://images/"+Global.data[lane_content]["shape"]+".png")
	lane_provinance.append(provinance)
	for o in get_tree().get_nodes_in_group("RingOutlineGroup"):
		o.update()
	
func deregister_provider(var provider):
	if not provider in lane_provinance:
		print("ERROR trying to dereg provider ",provider.name, " from lane ",name," which isn't registered")
		return
	lane_provinance.erase(provider)
	provider.lane_cleared(self)
	
func deregister_resource():
	if lane_content == null:
		print("ERROR trying to dereg in lane ",name," which isn'rt registered")
		return
	lane_content = null
	for p in lane_provinance:
		p.lane_cleared(self)
	lane_provinance.clear()
	for i in multimesh.instance_count:
		set_slot_filled(i, false, true)
	# These calls handle things also which take from the lane
	for f in get_tree().get_nodes_in_group("FactoryGroup"):
		f.lane_cleared(self)

func get_slot_filled(var i : int) -> bool:
	return bool(multimesh.get_instance_custom_data(i).r)
	
func get_slot_capturable(var i : int) -> bool:
	return bool(multimesh.get_instance_custom_data(i).g)
	
func get_slot_fillable(var i : int) -> bool:
	return bool(multimesh.get_instance_custom_data(i).b)

func get_slot_filled_and_captureable(var i : int) -> bool:
	var c : Color = multimesh.get_instance_custom_data(i)
	return (c.r == 1 and c.g == 1)
	
func get_slot_empty_and_fillable(var i : int) -> bool:
	var c : Color = multimesh.get_instance_custom_data(i)
	return (c.r == 0 and c.b == 1)

func try_capture(var angle : float, var caller : Node, var direction : int, var distance : int = 1):
	var i : int = wrap_i(round(wrap_a(angle - global_rotation) / radians_per_slot))
	var c : Color = multimesh.get_instance_custom_data(i)
	if not (c.r == 1 and c.g == 1): #same as get_slot_filled_and_captureable
		return
	c.g = 0 # Not capturable (caus' it's now captured)
	multimesh.set_instance_custom_data(i, c)
	var moving = {}
	moving["i"] = i
	moving["call"] = caller
	moving["dir"] = direction
	moving["offset"] = (2.0 * PI) * 1.0/float(multimesh.instance_count) * float(i)
	moving["radius"] = radius
	moving["target"] = radius + (ring_radius * distance) if direction == Global.OUTWARDS else radius - (ring_radius * distance)
	in_flight.append(moving)
	
func try_send(var angle : float, var direction : int) -> bool:
	var i : int = wrap_i(round(wrap_a(angle - global_rotation) / radians_per_slot))
	var c : Color = multimesh.get_instance_custom_data(i)
	if not (c.r == 0 and c.b == 1): #get_slot_empty_and_fillable
		return false
	c.r = 1 # Now filled
	c.b = 0 # Hence not fillable
	var new_radius = radius - ring_radius if direction == Global.OUTWARDS else radius + ring_radius
	var offset = (2.0 * PI) * 1.0/float(multimesh.instance_count) * float(i)
	multimesh.set_instance_custom_data(i, c)
	var t : Transform2D = multimesh.get_instance_transform_2d(i)
	t.origin /= DISABLE # Make visible again
	t.origin = Vector2(cos(offset), sin(offset)) * new_radius
	multimesh.set_instance_transform_2d(i, t)
	var moving = {}
	moving["i"] = i
	moving["dir"] = direction
	moving["offset"] = offset
	moving["radius"] = new_radius
	moving["target"] = radius
	in_flight.append(moving)
	return true
	
func _physics_process(var delta):
	for arr_i in range(in_flight.size()-1, -1, -1):
		var d = in_flight[arr_i]
		var i : int = d["i"]
		var dir : int = d["dir"]
		var t : Transform2D = multimesh.get_instance_transform_2d(i)
		d["radius"] += delta * INJECT_VELOCITY if dir == Global.OUTWARDS else -delta * INJECT_VELOCITY
		var finished : bool  = false 
		if (dir == Global.OUTWARDS and d["radius"] >= d["target"]) or (dir == Global.INWARDS and d["radius"] <= d["target"]):
			finished = true
			d["radius"] = radius
		var offset = d["offset"]
		t.origin = Vector2(cos(offset), sin(offset)) * d["radius"]
		if finished:
			if "call" in d: # Items which are flinging out (to below or above)
				if source: # Source rings never run out
					multimesh.set_instance_custom_data(i, Color(1,1,1,0))
				else:
					t.origin *= DISABLE
					multimesh.set_instance_custom_data(i, Color(0,1,1,0))
				var call = d["call"] 
				if call != null and is_instance_valid(call): # This might have been deleted in the time to move the item!
					call.add_item(self)
			else: # Items which are cascading in (from above or below)
				# Set empty and remove from dict
				if sink: # Sink consumes
					t.origin *= DISABLE
					multimesh.set_instance_custom_data(i, Color(0,1,1,0))
					if laneswap_target[0] != null:
						laneswap_target[0].set_slot_filled(i, true, true)
				else:
					multimesh.set_instance_custom_data(i, Color(1,1,1,0))
			in_flight.remove(arr_i)
		multimesh.set_instance_transform_2d(i, t)

func set_slot_filled(var i : int, var filled : bool, var capturable : bool):
	if laneswap_target[0] != null:
		laneswap_target[0].set_slot_filled(i, filled, capturable)
		return
	
	i = wrap_i(i)
	if source:
		filled = true
	if sink:
		filled = false
	if not bool(get_slot_filled(i)) == filled:
		var t : Transform2D = multimesh.get_instance_transform_2d(i)
		if filled:
			t.origin /= DISABLE
		else:
			t.origin *= DISABLE
		multimesh.set_instance_transform_2d(i, t)
	var c : Color = multimesh.get_instance_custom_data(i)
	c.r = filled
	c.g = capturable
	multimesh.set_instance_custom_data(i, c)
	
func set_slot_fillable(var i : int, var fillable : bool):
	var c : Color = multimesh.get_instance_custom_data(i)
	c.b = int(fillable)
	multimesh.set_instance_custom_data(i, c)
	if not fillable:
		set_slot_filled(i, false, true)

func setup_resource(var n : int, var _radius : float):
	radius = _radius
	multimesh.instance_count = n
	radians_per_slot = (2.0 * PI) / n
	for i in range(multimesh.instance_count):
		var offset = (2.0 * PI) * 1.0/float(multimesh.instance_count) * float(i)
		var p : Vector2 = Vector2(cos(offset), sin(offset)) * radius
		var t := Transform2D(Vector2.RIGHT, Vector2.DOWN, Vector2.ZERO)
		t = t.rotated(offset)
		t.origin = p * DISABLE
		# All nodes start off as filled = 0, capturable = 1, fillable = 1
		multimesh.set_instance_transform_2d(i, t)
		multimesh.set_instance_custom_data(i, Color(0,1,1,0))

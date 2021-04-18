extends MultiMeshInstance2D
tool

const DISABLE := 100.0

export(float) var radians_per_slot
export(String) var lane_content = null
var lane_provinance : Array = [] # Note: NOT exported, becomes shared!

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

func register_resource(var new_resource : String, var provinance : Node):
	if lane_content != null:
		print("ERROR in ",name," of ", get_parent().get_parent().name, " trying to reg ",new_resource," into lane containing ",lane_content)
		return
	lane_content = new_resource
	lane_provinance.append(provinance)
	modulate = Global.data[lane_content]["color"]
	
func deregister_resource():
	if lane_content == null:
		print("ERROR trying to dereg in lane ",name," which isn'rt registered")
		return
	lane_content = null
	for p in lane_provinance:
		p.deregister_resource()
	lane_provinance.clear()
	for i in multimesh.instance_count:
		set_slot_filled(i, false, true)

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

func set_slot_filled(var i : int, var filled : bool, var capturable : bool):
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

func setup_resource(var n : int, var radius : float):
	multimesh.instance_count = n
	radians_per_slot = (2.0 * PI) / n
	for i in range(multimesh.instance_count):
		var offset = (2.0 * PI) * 1.0/float(multimesh.instance_count) * float(i);
		var p := Vector2(cos(offset), sin(offset)) * radius
		var t := Transform2D(Vector2.RIGHT, Vector2.DOWN, p)
		t.origin *= DISABLE
		# All nodes start off as filled = 0, capturable = 1, fillable = 1
		multimesh.set_instance_transform_2d(i, t)
		multimesh.set_instance_custom_data(i, Color(0,1,1,0))

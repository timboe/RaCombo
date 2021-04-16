extends MultiMeshInstance2D
tool

const DISABLE := 100.0

export(float) var radians_per_slot
export(String) var lane_content = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var ring : Node2D = get_parent()
	multimesh = MultiMesh.new()
	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_8BIT
	multimesh.mesh = QuadMesh.new()
	multimesh.mesh.set_size(Vector2(10,10))
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	
func wrap(var i : int):
	if i < 0:
		return i + multimesh.instance_count
	elif i >= multimesh.instance_count:
		return i - multimesh.instance_count
	return i
	
func add_to_ring(var angle : float):
	var slot : int = round(angle / radians_per_slot) - 1
	for i in range(slot, slot+3):
		var i_wrap = wrap(i)
		if not get_slot_enabled(i_wrap):
			set_slot_enabled(i_wrap, true, true)
			return true
	for i in range(slot-1, slot-4, -1):
		var i_wrap = wrap(i)
		if not get_slot_enabled(i_wrap):
			set_slot_enabled(i_wrap, true, true)
			return true
	return false

func register_resource(var new_resource : String):
	if lane_content != null:
		print("ERROR in ",name," of ", get_parent().get_parent().name, " trying to reg ",new_resource," into lane containing ",lane_content)
		return
	lane_content = new_resource
	modulate = Global.data[lane_content]["color"]

func get_slot_enabled(var i : int):
	return bool(multimesh.get_instance_custom_data(i).r)

func set_slot_enabled(var i : int, var enable : bool, var capturable : bool):
	if not bool(get_slot_enabled(i)) == enable:
		var t : Transform2D = multimesh.get_instance_transform_2d(i)
		if enable:
			t.origin /= DISABLE
		else:
			t.origin *= DISABLE
		multimesh.set_instance_transform_2d(i, t)
	var c : Color = multimesh.get_instance_custom_data(i)
	c.r = enable
	c.g = capturable
	multimesh.set_instance_custom_data(i, c)

func setup_resource(var n : int, var radius : float):
	multimesh.instance_count = n
	radians_per_slot = (2.0 * PI) / n
	for i in range(multimesh.instance_count):
		var offset = (2.0 * PI) * 1.0/float(multimesh.instance_count) * float(i);
		var p := Vector2(cos(offset), sin(offset)) * radius
		var t := Transform2D(Vector2.RIGHT, Vector2.DOWN, p)
		multimesh.set_instance_transform_2d(i, t)
		multimesh.set_instance_custom_data(i, Color(1,0,0,0))
		set_slot_enabled(i, false, false) # in regular mode, should be false false 

	

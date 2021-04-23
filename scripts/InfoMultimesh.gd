extends MultiMeshInstance2D
tool

var is_input : bool
var input_index : int
var factory_process : Node2D

func _ready():
	multimesh = MultiMesh.new()
	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
	multimesh.mesh = QuadMesh.new()
	multimesh.mesh.set_size(Vector2(10,10))
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	var max_n = load("res://scripts/FactoryProcess.gd").new().MAX_STORAGE
	multimesh.instance_count = max_n
	var vertical_break := int(floor(sqrt(max_n)))
	for i in range(multimesh.instance_count):
		var orig := Vector2(10 * (i % vertical_break), 10 * floor(i/vertical_break))
		var t := Transform2D(Vector2.RIGHT, Vector2.DOWN, orig)
		multimesh.set_instance_transform_2d(i, t)

func reset():
	print("spy reset ",name," from ", factory_process.get_parent().descriptive_name)
	factory_process = null

func update_visible():
	if factory_process == null:
		return
	if is_input:
		multimesh.visible_instance_count = factory_process.input_storage[input_index]
	else:
		multimesh.visible_instance_count = factory_process.output_storage

func set_visible_count(var i : int):
	multimesh.visible_instance_count = i

func set_resource(var resource : String, var _factory_process, var _is_input : bool = false, var _index : bool = 0):
	is_input = _is_input
	input_index = _index
	factory_process = _factory_process
	factory_process.set_spy(self)
	modulate = Global.data[resource]["color"]
	texture = load("res://images/"+Global.data[resource]["shape"]+".png")

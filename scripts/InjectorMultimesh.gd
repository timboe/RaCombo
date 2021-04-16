extends MultiMeshInstance2D
tool

const WIDTH := 512.0
const EXTRA_MARGIN := 256.0

export(String) var set_resource = ""
export(float) var set_period = 1.0

export(int) var n
export(float) var linear_velocity
export(float) var radius
export(int) var lane
export(NodePath) var ring = ""

func _ready():
	n = 0
	multimesh = MultiMesh.new()
	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
	multimesh.mesh = QuadMesh.new()
	multimesh.mesh.set_size(Vector2(10,10))
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	if set_resource == "":
		print("ERROR: Injector ",name," has no resource!")
	var globals = load("res://scripts/Global.gd").new()
	modulate = globals.data[set_resource]["color"]

func hint_resource(var attached_ring : Node2D, var ring_lane : int):
	radius = attached_ring.radius_array[ring_lane]
	get_parent().update()
	get_parent().visible = true
	
func setup_resource(var attached_ring : Node2D, var ring_lane : int):
	attached_ring.register_resource(ring_lane, set_resource)
	
	ring = attached_ring.get_path()
	lane = ring_lane
	radius = attached_ring.radius_array[lane]
	linear_velocity = attached_ring.angular_velocity * radius
	var total_length := WIDTH + EXTRA_MARGIN
	n = round( (total_length/linear_velocity) / set_period ) 
	multimesh.instance_count = n
	for i in range(multimesh.instance_count):
		var offset = i * (linear_velocity * set_period);
		var orig := Vector2(-offset, -radius)
		var t := Transform2D(Vector2.RIGHT, Vector2.DOWN, orig)
		multimesh.set_instance_transform_2d(i, t)
	transform.origin.x = -WIDTH
	get_parent().update()
	get_parent().visible = true

func _physics_process(delta):
	if n == 0:
		return
	transform.origin.x += delta * linear_velocity
	if transform.origin.x > 0:
		transform.origin.x -= linear_velocity * set_period
		get_node(ring).add_to_ring(1.5 * PI, lane) # Always add new elements at the top

extends MultiMeshInstance2D
tool

const WIDTH := 500.0
const EXTRA_MARGIN := 250

export(int) var n
export(float) var linear_velocity
export(float) var radius
export(float) var period
export(int) var lane
export(NodePath) var ring

onready var parent : Node2D = get_parent()

func _ready():
	n = 0
	multimesh = MultiMesh.new()
	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
	multimesh.mesh = QuadMesh.new()
	multimesh.mesh.set_size(Vector2(10,10))
	multimesh.transform_format = MultiMesh.TRANSFORM_2D

func setup_resource(var p : float, var attached_ring : Node2D, var ring_lane : int):
	ring = attached_ring.get_path()
	lane = ring_lane
	radius = attached_ring.radius_array[lane]
	linear_velocity = attached_ring.angular_velocity * radius
	period = p
	var total_length := WIDTH + EXTRA_MARGIN
	n = round( (total_length/linear_velocity) / period ) 
	multimesh.instance_count = n
	for i in range(multimesh.instance_count):
		var offset = i * (linear_velocity * period);
		var orig := Vector2(-offset, -radius)
		var t := Transform2D(Vector2.RIGHT, Vector2.DOWN, orig)
		multimesh.set_instance_transform_2d(i, t)
	parent.transform.origin.x = -WIDTH

func _physics_process(delta):
	if n == 0:
		return
	parent.transform.origin.x += delta * linear_velocity
	if parent.transform.origin.x > 0:
		parent.transform.origin.x -= linear_velocity * period
		get_node(ring).add_to_ring(1.5 * PI, lane) # Always add new elements at the top

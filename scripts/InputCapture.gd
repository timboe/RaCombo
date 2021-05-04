extends Node

onready var centre_node : Node2D = get_tree().get_root().find_node("CentreNode", true, false) 
onready var camera_node : Camera2D = get_tree().get_root().find_node("Camera2D", true, false) 
onready var rs : Node2D = get_tree().get_root().find_node("RingSystem", true, false)
onready var button_group : ButtonGroup = get_tree().get_root().find_node("BuildMode", true, false).group
onready var id = get_tree().get_root().find_node("InfoDialog", true, false) 

var prev_ring : Node2D = null
var ring : Node2D = null
var cursor : Vector2

func _ready():
	set_process_unhandled_input(true)

func _process(_delta):
	var button = button_group.get_pressed_button()
	var mode_build = (button != null and button.name == "BuildMode")
	
	# Update once per frame
	if mode_build and ring != null:
		var cursor_angle = get_cursor_angle()
		ring.get_node("Rotation/FactoryTemplate").global_rotation = cursor_angle
	
func _unhandled_input(event):
	if not event is InputEventMouseMotion and not event is InputEventMouseButton:
		return

	var button = button_group.get_pressed_button()
	var mode_build = (button != null and button.name == "BuildMode")
	var mode_inject = (button != null and not mode_build)
	
	var injection = null
	if mode_inject:
		injection = button.inj_node
	
	cursor = (event.global_position + camera_node.global_position) * camera_node.zoom
	var dist : float = round( abs( cursor.distance_to( centre_node.position ) ) )
	var ring_index : int = int(dist / rs.RING_RADIUS) - 1 
	if dist < rs.RING_RADIUS:
		ring = rs.get_child(0)
	elif int(dist) % int(rs.RING_RADIUS) > rs.RING_WIDTH or ring_index > Global.rings:
		ring = null
	else:
		ring = rs.get_child(ring_index)
	
	if event is InputEventMouseMotion:
		# Update once per moving in/out of highlight
		if prev_ring != ring:
			if prev_ring != null and prev_ring.ring_number != 0:
				prev_ring.get_node("Outline").set_highlight(false)
				if (mode_build): 
					prev_ring.set_factory_template_visible(false)
				if mode_inject:
					injection.stop_hint_resource()
			if ring != null and ring.ring_number != 0:
				ring.get_node("Outline").set_highlight(true)
				if mode_build: 
					ring.set_factory_template_visible(true)
				if mode_inject:
					var free_lane = ring.get_free_or_existing_lane(injection.set_resource)
					injection.hint_resource(ring, free_lane)

		prev_ring = ring

	# Left click
	if event is InputEventMouseButton and ring != null and event.pressed and event.button_index == 1:
		if button == null: # Select ring (but not the Sol ring)
			if ring.ring_number == 0:
				id.show_named_diag("Sol")
			else:
				id.show_ring_diag(ring)
		elif mode_build and ring.ring_number != 0:
			ring.new_factory()
		elif mode_inject and ring.ring_number != 0:
			injection.setup_resource_at_hint()
			
	# Right click
	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		if mode_build or mode_inject:
			button.pressed = false
			Global.last_pressed = null

func get_cursor_angle():
	var cursor_angle : float = atan2(centre_node.position.y - cursor.y, centre_node.position.x - cursor.x) - PI
	if cursor_angle < 0:
		cursor_angle += 2*PI
	return cursor_angle


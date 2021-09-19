extends Camera2D

const MOVE_SPEED = 300


##############################
# Shake parameters

export var shake_speed := 0.8
export var shake_decay := 0.3
export var noise : OpenSimplexNoise

onready var info_dialog : WindowDialog = get_tree().get_root().find_node("InfoDialog",true,false)
onready var input_capture : Node2D = get_tree().get_root().find_node("InputCapture",true,false)

const RUMBLE_OFFSET : float = 0.75

var slow_mo_count : int = 0

var trauma := 0.0
var time := 0.0

var down_point : Vector2

var events = {}
var last_drag_distance = 0
var pan_zoom_sensitivity = 10
var zoom_speed = 0.05
var min_zoom := 0.05 # 0.5
var max_zoom := 20.0 # 2

var follow_target = null

func _ready():
	set_process_unhandled_input(true)

func _unhandled_input(event):
	var change = false
	# Zoom mouse
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP and zoom.x > min_zoom:
			zoom /= 1.1
			change = true
		if event.button_index == BUTTON_WHEEL_DOWN and zoom.x < max_zoom:
			zoom *= 1.1
			change = true
		down_point = event.position
	# Pan mouse
	if event is InputEventMouseMotion and Input.is_action_pressed("ui_mouse_pan"):
		global_position -= event.relative.rotated(rotation) * zoom.x
		change = true
		if down_point.distance_to(event.position) > pan_zoom_sensitivity:
			input_capture.is_pan = true
	# Android touch
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
			down_point = event.position
		else:
			events.erase(event.index)
	if event is InputEventScreenDrag:
		events[event.index] = event
		# Pan android
		if events.size() == 1:
			global_position -= event.relative.rotated(rotation) * zoom.x
			change = true
			if down_point.distance_to(event.position) > pan_zoom_sensitivity:
				input_capture.is_pan = true
		# Zoom android
		elif events.size() == 2:
			var drag_distance = events[0].position.distance_to(events[1].position)
			if abs(drag_distance - last_drag_distance) > pan_zoom_sensitivity:
				var new_zoom = (1 + zoom_speed) if drag_distance < last_drag_distance else (1 - zoom_speed)
				new_zoom = clamp(zoom.x * new_zoom, min_zoom, max_zoom)
				zoom = Vector2.ONE * new_zoom
				last_drag_distance = drag_distance
				input_capture.is_pan = true
				change = true
	## Update
	if change:
		var zoom_mod = clamp(zoom.x, 1.0, 2.0) / 1.5
		var w : float = ProjectSettings.get_setting("display/window/size/width") * zoom_mod
		var h : float = ProjectSettings.get_setting("display/window/size/height") * 1.3 * zoom_mod
		global_position.x = clamp(global_position.x, -w, w)
		global_position.y = clamp(global_position.y, -h, h)

func _process(delta):
	apply_shake(delta)
	decay_trauma(delta)
	if Input.is_action_pressed("ui_left"):
		global_position += Vector2.LEFT * delta * MOVE_SPEED * zoom.x
	elif Input.is_action_pressed("ui_right"):
		global_position += Vector2.RIGHT * delta * MOVE_SPEED * zoom.x
	if Input.is_action_pressed("ui_up"):
		global_position += Vector2.UP * delta * MOVE_SPEED * zoom.x
	elif Input.is_action_pressed("ui_down"):
		global_position += Vector2.DOWN * delta * MOVE_SPEED * zoom.x
	if follow_target != null:
		rotation = follow_target.get_global_transform().get_rotation() + PI/2.0
		print(follow_target.position)
		global_position = follow_target.global_position - Vector2(640,360) - Vector2(0, follow_target.ring.radius_array[0] ).rotated(rotation)
		rotating = true
		

func add_trauma(var amount):
	if Global.settings["shake"] == false:
		return
	trauma = min(trauma + amount, amount * 2)
 
func decay_trauma(var delta: float):
	var change := shake_decay * delta
	trauma = max(trauma - change, 0.0)
 
# apply shake to starting camera position
func apply_shake(var delta : float):
	# using a magic number here to get a pleasing effect at speed 1.0
	time += delta * shake_speed * 5000.0
	if trauma == 0:
		return
	var shake := trauma * trauma
	var offset_x := RUMBLE_OFFSET * shake * noise.get_noise_2d(0, time)
	var offset_y := RUMBLE_OFFSET * shake * noise.get_noise_2d(time, 0)
	offset_h = offset_x
	offset_v = offset_y


func _on_Rotate_pressed():
	follow_target = info_dialog.current_building

extends Camera2D

const MOVE_SPEED = 300


##############################
# Shake parameters

export var shake_speed := 0.8
export var shake_decay := 0.3
export var noise : OpenSimplexNoise

const RUMBLE_OFFSET : float = 0.75

var slow_mo_count : int = 0

var trauma := 0.0
var time := 0.0


func _ready():
	set_process_unhandled_input(true)

func _unhandled_input(event):
	var change = false
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP and zoom.x > 0.5:
			zoom /= 1.1
			change = true
		if event.button_index == BUTTON_WHEEL_DOWN and zoom.x < 2.0:
			zoom *= 1.1
			change = true
	elif event is InputEventMagnifyGesture:
		var z = clamp(zoom * event.factor, 0.5, 2.0)
		zoom = Vector2(z, z)
		change = true
	if event is InputEventMouseMotion and Input.is_action_pressed("ui_mouse_pan"):
		global_position -= (event.relative * zoom)
		change = true
	elif event is InputEventPanGesture:
		global_position += (event.delta * zoom)
		change = true
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

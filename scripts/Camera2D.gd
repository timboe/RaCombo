extends Camera2D

const MOVE_SPEED = 300

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			zoom /= 1.1
			print(zoom)
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom *= 1.1
			print(zoom)

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		global_position += Vector2.LEFT * delta * MOVE_SPEED
	elif Input.is_action_pressed("ui_right"):
		global_position += Vector2.RIGHT * delta * MOVE_SPEED
	if Input.is_action_pressed("ui_up"):
		global_position += Vector2.UP * delta * MOVE_SPEED
	elif Input.is_action_pressed("ui_down"):
		global_position += Vector2.DOWN * delta * MOVE_SPEED

extends Button

var prev_ring : Node2D = null
var factory = load("res://scenes/FactoryTemplate.tscn")

onready var centre_node : Node2D = get_tree().get_root().get_node("Root/CentreNode") 
onready var rs : Node2D = get_tree().get_root().get_node("Root/CentreNode/RingSystem")
onready var pause = get_tree().get_root().find_node("Pause", true, false) 
onready var iron_inj_node = get_tree().get_root().find_node("IronInjection0", true, false)
onready var copper_inj_node = get_tree().get_root().find_node("CopperInjection0", true, false)
onready var silica_inj_node = get_tree().get_root().find_node("SilicaInjection0", true, false)

func get_cursor_angle(var centre : Vector2, var cursor : Vector2):
	var cursor_angle : float = atan2(centre.y - cursor.y, centre.x - cursor.x) - PI
	if cursor_angle < 0:
		cursor_angle += 2*PI
	return cursor_angle

func _process(delta):
	var cursor = get_global_mouse_position()
	var dist : float = round( abs( cursor.distance_to( centre_node.position ) ) )
	var ring_index : int = int(dist / rs.RING_RADIUS) - 1 
	var ring : Node2D
	if int(dist) % int(rs.RING_RADIUS) > rs.RING_WIDTH or ring_index >= rs.rings:
		ring = null
	else:
		ring = rs.get_child(ring_index)
		
	var build_mode = (name == "BuildMode")

	# Ring highlighting
	if prev_ring != ring:
		if prev_ring != null:
			prev_ring.get_node("Outline").set_highlight(false)
		if ring != null:
			ring.get_node("Outline").set_highlight(true)
		
	if pressed:
		if build_mode:
			mode_build(ring, cursor)
		else:
			mode_inject(ring)
			
	prev_ring = ring

func mode_inject(var ring):
	var injection : MultiMeshInstance2D = null
	if name == "Iron":
		injection = iron_inj_node
	elif name == "Copper":
		injection = copper_inj_node
	elif name == "Silica":
		injection = silica_inj_node
	else:
		print("ERROR: Unkown button in mode_inject")
		return
	
	if ring != null:
		var free_lane = ring.get_free_or_existing_lane(injection.set_resource)
		if free_lane != -1:
			injection.hint_resource(ring, free_lane)
			if Input.is_action_just_pressed("ui_click"):
				injection.setup_resource(ring, free_lane)
				pressed = false
				disabled = true
	
func mode_build(var ring, var cursor):
	# Show factory build
	if prev_ring != ring:
		if prev_ring != null:
			prev_ring.get_node("Rotation/FactoryTemplate").visible = false
		if ring != null:
			ring.get_node("Rotation/FactoryTemplate").visible = true
	
	if ring != null:
		var cursor_angle = get_cursor_angle(centre_node.position, cursor)
		var factory_template = ring.get_node("Rotation/FactoryTemplate")
			
		print(rad2deg(cursor_angle))
		factory_template.global_rotation = cursor_angle
		
		if Input.is_action_just_pressed("ui_click") and not factory_template.colliding:
			var new_factory = factory_template.duplicate(DUPLICATE_SCRIPTS|DUPLICATE_SIGNALS)
			new_factory.name = "FactoryInstance"
			ring.get_node("Rotation/Factories").add_child(new_factory, true)
			new_factory.add_to_group("FactoryGroup", true)

func _on_Button_toggled(button_pressed):
	if button_pressed:
		# The button calling this method is the one that was just selected
		var pressed_button : Button = group.get_pressed_button()
		if Global.last_pressed == pressed_button:
			# The button calling the method was the last one that was selected (we clicked it twice in a row)
			# Toggle it off and set last_pressed to null so we can click it a third time to toggle it back on
			pressed_button.pressed = false
			button_pressed = false
			Global.last_pressed = null
		# Update the last button pressed if we clicked something different
		else:
			Global.last_pressed = pressed_button
	
	pause.pressed = button_pressed
	pause.disabled = button_pressed
	pause.get_node("../FF").disabled = button_pressed
	
	var build_mode = (name == "BuildMode")
	if not build_mode:
		# Show injection circle targets
		for r in get_tree().get_nodes_in_group("RingGroup"):
			r.get_node("Outline").set_inject(button_pressed)
		# Hide if not placed
		if button_pressed == false:
			for r in get_tree().get_nodes_in_group("InjectorGroup"):
				if r.ring == "":
					r.get_parent().visible = false

extends Button

var prev_ring : Node2D = null

var factory = load("res://scenes/FactoryTemplate.tscn")

func get_cursor_angle(var centre : Vector2, var cursor : Vector2):
	var cursor_angle : float = atan2(centre.y - cursor.y, centre.x - cursor.x) - PI
	if cursor_angle < 0:
		cursor_angle += 2*PI
	return cursor_angle

func _process(delta):

	var rs : Node2D = get_tree().get_root().get_node("Root/RingSystem")
	var cursor = get_global_mouse_position()
	var dist : float = round( abs( cursor.distance_to( rs.position ) ) )
	var ring_index : int = int(dist / rs.RING_RADIUS) - 1 
	var ring : Node2D
	if int(dist) % int(rs.RING_RADIUS) > rs.RING_WIDTH or ring_index >= rs.rings:
		ring = null
	else:
		ring = rs.get_child(ring_index)

	# Ring highlighting
	if prev_ring != ring:
		if prev_ring != null:
			prev_ring.get_node("Outline").set_highlight(false)
		if ring != null:
			ring.get_node("Outline").set_highlight(true)
		
	if pressed:
		# Show factory build
		if prev_ring != ring:
			if prev_ring != null:
				prev_ring.get_node("FactoryTemplate").visible = false
			if ring != null:
				ring.get_node("FactoryTemplate").visible = true
		
		if ring != null:
			var cursor_angle = get_cursor_angle(rs.position, cursor)
			var factory_template = ring.get_node("FactoryTemplate")
				
			print(rad2deg(cursor_angle))
			factory_template.global_rotation = cursor_angle
			
			if Input.is_action_just_pressed("ui_click") and not factory_template.colliding:
				var new_factory = factory_template.duplicate(DUPLICATE_SCRIPTS|DUPLICATE_SIGNALS)
				new_factory.name = "FactoryInstance"
				ring.get_node("Factories").add_child(new_factory, true)
				new_factory.add_to_group("FactoryGroup", true)
				
	prev_ring = ring

func _on_Button_toggled(button_pressed):
	get_tree().paused = button_pressed
	Physics2DServer.set_active(true)
	

extends Button

onready var pause = get_tree().get_root().find_node("Pause", true, false) 
onready var id = get_tree().get_root().find_node("InfoDialog", true, false) 

onready var inj_node = get_tree().get_root().find_node("Injector"+String(int(name)), true, false).get_child(0)

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
	
	if button_pressed:
		id.hide_diag()
		
	for tb in get_tree().get_nodes_in_group("FactoryButtonGroup"):
		tb.visible = !button_pressed
	
	if name == "BuildMode":
		if button_pressed == false: # Hide all 
			for r in get_tree().get_nodes_in_group("RingGroup"):
				r.set_factory_template_visible(false)
	else: # Inject mode
		# Show injection circle targets
		for r in get_tree().get_nodes_in_group("RingGroup"):
			r.get_node("Outline").set_inject(button_pressed, inj_node.set_resource)
		# Hide if not placed
		if button_pressed == false:
			for r in get_tree().get_nodes_in_group("InjectorGroup"):
				r.stop_hint_resource()

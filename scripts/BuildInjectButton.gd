extends Button

onready var pause = get_tree().get_root().find_node("Pause", true, false) 
onready var id = get_tree().get_root().find_node("InfoDialog", true, false) 

onready var iron_inj_node = get_tree().get_root().find_node("IronInjection0", true, false)
onready var copper_inj_node = get_tree().get_root().find_node("CopperInjection0", true, false)
onready var silica_inj_node = get_tree().get_root().find_node("SilicaInjection0", true, false)

func _process(var _delta):
	if name != "BuildMode":
		icon = Global.data[get_resource()]["texture"]
	set_process(false)

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
			r.get_node("Outline").set_inject(button_pressed, get_injecton_node().set_resource)
		# Hide if not placed
		if button_pressed == false:
			for r in get_tree().get_nodes_in_group("InjectorGroup"):
				r.stop_hint_resource()


func get_injecton_node() -> Node:
	if name == "IronButton0":
		return iron_inj_node
	elif name == "CopperButton0":
		return copper_inj_node
	elif name == "SilicaButton0":
		return silica_inj_node
	else:
		return null
		
func get_resource() -> String:
	if name == "IronButton0":
		return "iron"
	elif name == "CopperButton0":
		return "copper"
	elif name == "SilicaButton0":
		return "silica"
	else:
		return "none"


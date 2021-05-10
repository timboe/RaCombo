extends Control

onready var sol = get_tree().get_root().find_node("Sol",true,false)
onready var id = get_tree().get_root().find_node("InfoDialog", true, false) 

func _on_Pause_toggled(button_pressed):
	print("Pause ", button_pressed)
	get_tree().paused = button_pressed
	Physics2DServer.set_active(true)
	sol.get_material().set_shader_param("pause", button_pressed)

func _on_FF_toggled(button_pressed):
	Engine.time_scale = 2.0 if button_pressed else 1.0
	print("Game speed ", Engine.time_scale)

func _on_Outlines_toggled(button_pressed):
	for o in get_tree().get_nodes_in_group("RingOutlineGroup"):
		o.set_show(button_pressed)
	for i in get_tree().get_nodes_in_group("InjectorGroup"):
		i.get_parent().set_show(button_pressed)

func _on_Menu_pressed():
	id.toggle_menu_diag()

func _on_mouse_entered():
	pass # Replace with function body.

func _on_mouse_exited():
	pass # Replace with function body.


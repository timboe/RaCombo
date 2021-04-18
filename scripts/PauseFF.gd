extends Button

func _on_Pause_toggled(button_pressed):
	if button_pressed:
		var pressed_button : Button = group.get_pressed_button()
		if Global.last_pressed_paused == pressed_button:
			pressed_button.pressed = false
			button_pressed = false
			Global.last_pressed_paused = null
		else:
			Global.last_pressed_paused = pressed_button
	
	if name == "Pause":
		print("PAUUUSE ", button_pressed)
		get_tree().paused = button_pressed
		Physics2DServer.set_active(true)

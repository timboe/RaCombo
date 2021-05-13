extends CenterContainer


func show_settings():
	$MC/MC/VB/SC/SG/FullscreenButton.pressed = OS.window_fullscreen
	$MC/MC/VB/SC/SG/SunButton.pressed = Global.settings["fancy_sun"]
	$MC/MC/VB/SC/SG/ShakeButton.pressed = Global.settings["shake"]
	$MC/MC/VB/SC/SG/HideButton.pressed = Global.settings["hide"]
	$MC/MC/VB/SC/SG/TutorialButton.pressed = Global.settings["tutorial"]
	$MC/MC/VB/SC/SG/MusicSlider.value = Global.settings["music"]
	$MC/MC/VB/SC/SG/SFXSlider.value = Global.settings["sfx"]

func set_default():
	Global.settings["music"] = 100
	Global.settings["sfx"] = 100
	Global.settings["fancy_sun"] = true
	Global.settings["shake"] = true	
	Global.settings["hide"] = false
	Global.settings["fullscreen"] = OS.window_fullscreen
	Global.settings["tutorial"] = true
	
func _on_FullscreenButton_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	Global.settings["fulscreen"] = button_pressed

func _on_Back_pressed():
	Global.settings["music"] = $MC/MC/VB/SC/SG/MusicSlider.value
	Global.settings["sfx"] = $MC/MC/VB/SC/SG/SFXSlider.value
	Global.settings["fancy_sun"] = $MC/MC/VB/SC/SG/SunButton.pressed
	Global.settings["shake"] = $MC/MC/VB/SC/SG/ShakeButton.pressed
	Global.settings["hide"] = $MC/MC/VB/SC/SG/HideButton.pressed
	Global.settings["tutorial"] = $MC/MC/VB/SC/SG/TutorialButton.pressed
	
	var file = File.new()
	file.open(Global.SETTINGS_SAVE_FILE, File.WRITE)
	file.store_string(JSON.print(Global.settings))
	file.close()
	
	get_parent().get_node("MainMenu")._on_Back_pressed()

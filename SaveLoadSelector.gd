extends HBoxContainer

# These will only be valid in-game
onready var sl : Node2D = get_tree().get_root().find_node("SaveLoad", true, false)
onready var id : WindowDialog = get_tree().get_root().find_node("InfoDialog", true, false) 

var save_number : int = -1

func _ready():
	save_number = name.to_int()
	var data = Global.saves[name]
	$VBox/Grid/Save.text = "Autosave" if data["autosave"] else "Save %04d" % save_number
	$VBox/Grid/Camapign.text = data["campaign_name"]
	$VBox/Grid/Level.text = "Sandbox" if  data["sandbox"] else "Level %d" % data["level"]
	var h : int = int(data["time_played"]) / 3600
	var remainder : int = int(data["time_played"]) % 3600
	var m = remainder / 60
	var s = remainder % 60
	var file = File.new()
	var path : String = "user://save_%04d.png" % save_number
	if file.file_exists(path):
		var image = Image.new()
		var err = image.load(path)
		if err == OK:
			var tex = ImageTexture.new()
			tex.create_from_image(image, 0)
			$TextureRect.texture = tex
	$VBox/Grid/Time.text = "Time %02d:%02d:%02d" % [h,m,s] 
	if get_parent().name == "SaveVBox":
		$VBox/HBox/Overwrite.visible = true
		$VBox/HBox/Load.visible = false
		$VBox/HBox/Delete.visible = false
	else:
		$VBox/HBox/Overwrite.visible = false
		$VBox/HBox/Load.visible = true
		$VBox/HBox/Delete.visible = true


func _on_Overwrite_pressed():
	$OverwriteConfirmationDialog.dialog_text = "Please confirm overwriting Save %04d" % save_number
	$OverwriteConfirmationDialog.popup_centered()

func _on_Delete_pressed():
	$DeleteConfirmationDialog.dialog_text = "Please confirm deleting Save %04d" % save_number
	$DeleteConfirmationDialog.popup_centered()


func _on_Load_pressed():
	get_tree().paused = false
	Global.request_load = Global.saves[String(save_number)]
	Global.campaign = Global.request_load["campaign"]
	Global.level = Global.request_load["level"]
	Global.sandbox = Global.request_load["sandbox"]
	Global.sandbox_injectors = Global.request_load["sandbox_injectors"]
	Global.rings = Global.request_load["rings"]
	Global.lanes = Global.request_load["lanes"]
	Global.factories_pull_from_above = Global.request_load["factories_pull_from_above"]
	Global.time_played = Global.request_load["time_played"] 
	Global.remaining = Global.request_load["remaining"]
	Global.to_subtract = Global.request_load["to_subtract"]
	Global.exported = Global.request_load["exported"]
	Global.tutorial_message = Global.request_load["tutorial_message"]
	Global.goto_scene("res://Scenes/ShieldGen.tscn")

func _on_DeleteConfirmationDialog_confirmed():
	print("Erasing save ", save_number)
	var path : String = "user://save_%04d.png" % save_number
	var dir = Directory.new()
	dir.remove(path)
	Global.saves.erase(String(save_number))
	var file = File.new()
	file.open(Global.GAME_SAVE_FILE, File.WRITE)
	file.store_string(JSON.print(Global.saves))
	file.close()
	if id:
		id.update_diag()

func _on_OverwriteConfirmationDialog_confirmed():
	sl.save(save_number)
	print("save override in number ",save_number," confirmed")
	id.hide_diag()


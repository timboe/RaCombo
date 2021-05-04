extends Button

const test_save := "res://test_save.json"

func _on_Play_pressed():
	var name = get_parent().get_parent().get_node("CampaignName").text
	var dict : Dictionary = Global.campaigns[name]
	Global.campaign = dict
	Global.level = 0
	Global.sandbox = false
	Global.request_load = null
	Global.goto_scene("res://Scenes/ShieldGen.tscn")

func _on_Sandbox_pressed():
	var name = get_parent().get_parent().get_node("CampaignName").text
	var dict : Dictionary = Global.campaigns[name]
	dict["missions"] = [] # Delete mission data, we don't need it
	Global.campaign = dict
	Global.level = 0
	Global.rings = Global.MAX_RINGS
	Global.lanes = Global.MAX_LANES
	Global.sandbox = true
	Global.request_load = null
	Global.goto_scene("res://Scenes/ShieldGen.tscn")

func _on_Load_pressed():
	var file = File.new()
	if file.file_exists(test_save):
		file.open(test_save, File.READ)
		var result = JSON.parse( file.get_as_text() )
		if result.error == OK:
			Global.request_load = result.result
			Global.campaign = Global.request_load["campaign"]
			Global.level = Global.request_load["level"]
			Global.sandbox = Global.request_load["sandbox"]
			Global.rings = Global.request_load["rings"]
			Global.lanes = Global.request_load["lanes"]
			Global.goto_scene("res://Scenes/ShieldGen.tscn")
		else:
			print("ERROR: JSON ERROR ", result.error_string)
		file.close()

extends Control
tool

func _ready():
	var shield_scene = load("res://scenes/Shield.tscn")
	var globals = load("res://scripts/Global.gd").new()
	for n in get_children():
		n.queue_free()
	var count = 0
	for key in globals.data:
		count += 1
		var value = globals.data[key]
		var shield = shield_scene.instance()
		shield.name = key 
		add_child(shield, true)
		shield.margin_top = 32 * count
		shield.set_owner(get_tree().get_edited_scene_root())
		var back : StyleBoxFlat = shield.get_node("Back").get_stylebox("panel")
		back.bg_color = value["color"]
		back.shadow_color = value["color"].darkened(0.2)
		var label : Label = shield.get_node("Label")
		label.set("custom_colors/font_color", value["color"].contrasted())
		label.text = value["name"]
		var _sign : Label = shield.get_node("Sign")
		_sign.set("custom_colors/font_color", value["color"].contrasted())
		_sign.text = "-" if value["resource"] else "+"

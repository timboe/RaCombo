extends WindowDialog

onready var col : ColorPicker = find_node("ColorPicker")
onready var nme : LineEdit = find_node("LineEdit")
onready var symb : OptionButton = find_node("SymbolButton")
onready var mode : OptionButton = find_node("ModeButton")
onready var tex_rec : TextureRect = find_node("TextureRect")
onready var warn_diag : AcceptDialog = find_parent("CampaignEditor").find_node("WarningDialog", true, false)
onready var campaign_editor : CenterContainer = find_parent("CampaignEditor")

func show_for(var resource):
	if resource != null:
		nme.text = resource
		for i in range(symb.get_item_count()):
			if symb.get_item_metadata(i) == Global.data[resource]["shape"]:
				symb.select(i)
				break
		for i in range(mode.get_item_count()):
			if mode.get_item_metadata(i) == Global.data[resource]["mode"]:
				mode.select(i)
				break
		col.color = Global.data[resource]["color"]
	else:
		nme.text = ""
		symb.select(0)
		mode.select(0)
		col.color = Color.white
	tex_rec.update_prieview()
	show()

func _on_Save_pressed():
	if nme.text == "":
		warn_diag.dialog_text = "New resource must have a name"
		warn_diag.show()
		return
	if nme.text == "H" and mode.get_selected_metadata() == "-":
		warn_diag.dialog_text = "H must be a +ve signed resource"
		warn_diag.show()
		return
	var d = {}
	d["color"] = col.color
	d["color_hex"] = col.color.to_html()
	d["mode"] = mode.get_selected_metadata()
	d["shape"] = symb.get_selected_metadata()
	d["special"] = false
	Global.data[nme.text] = d
	campaign_editor.update_resource_recipy()
	hide()

func _on_Discard_pressed():
	hide()

func _on_Delete_pressed():
	var resource = nme.text
	if resource == "H":
		warn_diag.dialog_text = "Cannot delete the H resource"
		warn_diag.show()
		return
	if resource in Global.data:
		Global.data.erase(resource)
	if resource in Global.recipies:
		Global.recipies.erase(resource)
	for r in Global.recipies:
		var loc = Global.recipies[r]["input"].find(resource)
		if loc != -1:
			Global.recipies[r]["input"].remove(loc)
			Global.recipies[r]["amount_in"].remove(loc)
	campaign_editor.update_resource_recipy()
	hide()

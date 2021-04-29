extends WindowDialog


func show_for(var resource):
#	if resource != null:
#		nme.text = resource
#		for i in range(symb.get_item_count()):
#			if symb.get_item_metadata(i) == Global.data[resource]["shape"]:
#				symb.select(i)
#				break
#		for i in range(mode.get_item_count()):
#			if mode.get_item_metadata(i) == Global.data[resource]["mode"]:
#				mode.select(i)
#				break
#		col.color = Global.data[resource]["color"]
#	else:
#		nme.text = ""
#		symb.select(0)
#		mode.select(0)
#		col.color = Color.white
#	tex_rec.update_prieview()
	show()

func update_resource_recipy():
	for n in get_tree().get_nodes_in_group("ResRecUpdateGroup"):
		n.update_resource_recipy()
	# Note: Do not cache
	var mission_container = get_tree().get_root().find_node("MissionContainer", true, false)
	mission_container.update_configuration()


func _on_Save_pressed():
#	if nme.text == "":
#		return
#	var d = {}
#	d["color"] = col.color
#	d["mode"] = mode.get_selected_metadata()
#	d["shape"] = symb.get_selected_metadata()
#	d["builtin"] = true # remove this...
#	d["special"] = false
#	Global.data[nme.text] = d
	update_resource_recipy()
	hide()

func _on_Discard_pressed():
	hide()

func _on_Delete_pressed():
#	var resource = nme.text
#	if resource in Global.data:
#		Global.data.erase(resource)
#	if resource in Global.recipies:
#		Global.recipies.erase(resource)
#	for r in Global.recipies:
#		var loc = Global.recipies[r]["input"].find(resource)
#		if loc != -1:
#			Global.recipies[r]["input"].remove(loc)
#			Global.recipies[r]["amount_in"].remove(loc)
	update_resource_recipy()
	hide()

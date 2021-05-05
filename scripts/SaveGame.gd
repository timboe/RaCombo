extends Button

const test_save := "res://test_save.json"

func _on_Save_pressed():
	var save_dict = {}
	save_dict["sandbox"] = Global.sandbox
	save_dict["level"] = Global.level
	# This bundles all recipy, mission, resource data. In case it were to change...
	save_dict["campaign"] = Global.campaigns[ Global.campaign["name"] ]
	save_dict["version"] = Global.SAVE_FORMAT_VERSION
	
	if Global.sandbox:
		save_dict["sandbox_injectors"] = Global.sandbox_injectors
		save_dict["rings"] = Global.rings
		save_dict["lanes"] = Global.lanes
	else:
		save_dict["remaining"] = Global.remaining
		save_dict["to_subtract"] = Global.to_subtract
	# Remember what has been exported so far
	save_dict["exported"] = Global.exported
	
	# Save button state
	save_dict["paused"] = get_tree().get_root().find_node("Pause",true,false).pressed
	save_dict["ff"] = get_tree().get_root().find_node("FF",true,false).pressed
	save_dict["outlines"] = get_tree().get_root().find_node("Outlines",true,false).pressed
	
	# Save injectors
	var injector_dict = {}
	for i in get_tree().get_nodes_in_group("InjectorParentGroup"):
		injector_dict[i.name] = i.serialise()
	save_dict["saved_injectors"] = injector_dict
	
	# Save Rigs
	var ring_dict = {}
	for i in get_tree().get_nodes_in_group("RingGroup"):
		ring_dict[i.name] = i.serialise()
	save_dict["saved_rings"] = ring_dict
	
	# Save satelites
	var satelite_dict = {}
	for i in get_tree().get_nodes_in_group("FactoryGroup"):
		if i.name == "FactoryTemplate":
			continue
		satelite_dict[i.get_path()] = i.serialise()
	save_dict["saved_satelites"] = satelite_dict
	
	var file = File.new()
	file.open(test_save, File.WRITE)
	file.store_string(JSON.print(save_dict))
	file.close()

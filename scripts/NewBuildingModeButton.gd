extends Button

func _on_Button_pressed():
	var id : WindowDialog = get_tree().get_root().find_node("InfoDialog",true,false)
	var mode : int
	if get_parent().name == "ExtractorGrid":
		mode = id.current_building.BUILDING_EXTRACTOR
	elif get_parent().name == "InserterGrid":
		mode = id.current_building.BUILDING_INSERTER
	elif get_parent().name == "FactoryGrid":
		mode = id.current_building.BUILDING_FACTORY
	else:
		print("ERROR in assigning new building job")
	id.current_building.configure_building(mode, name)
	id.hide_diag()


extends MarginContainer

onready var rule_changer : Node2D = get_tree().get_root().find_node("RuleChanger", true, false) 
onready var vbox : VBoxContainer = get_node("VBoxContainer")

func update_inputs():
	var config = []
	for i in range(Global.MAX_INPUT_LANES):
		var injector = vbox.get_node("Input"+String(i))
		var resource : OptionButton = injector.get_node("OptionButton")
		if resource.get_selected_metadata() == "None":
			continue
		var d = {}
		d["rate"] = injector.get_node("RateSlider").value
		d["resource"] = resource.get_selected_metadata()
		config.append(d)
	Global.sandbox_injectors = config
	rule_changer.set_inectors(Global.sandbox_injectors)
	

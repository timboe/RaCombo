extends HSlider

onready var tab_container : TabContainer = find_parent("CampaignEditor").find_node("TabContainer", true, false)

func _on_HSlider_value_changed(value):
	get_parent().get_node("N").text = String(value)
	if name == "Missions":
		update_missions_tab(int(value))

func update_missions_tab(var n : int):
#	var tabs = tab_container.get_child_count()
	var largest_tab = -1
	for tab in tab_container.get_children():
		if "deleted" in tab.name:
			continue
		if int(tab.name) > largest_tab:
			largest_tab = int(tab.name)
		if int(tab.name) > n:
			tab.name = "deleted"
			tab.queue_free()
	var new_n = largest_tab + 1
	while new_n <= n:
		var new_tab = load("res://scenes/MissionConfiguration.tscn").instance()
		new_tab.name = String(new_n)
		tab_container.add_child(new_tab, true)
		new_n += 1


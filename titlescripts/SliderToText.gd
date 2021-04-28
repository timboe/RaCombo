extends HSlider

onready var tab_container : TabContainer = find_parent("CampaignEditor").find_node("TabContainer", true, false)

func _on_HSlider_value_changed(value):
	get_parent().get_node("N").text = String(value)
	if name == "Missions":
		update_missions_tab(int(value))

func update_missions_tab(var n : int):
	var tabs = tab_container.get_child_count()
	if tabs > n:
		for i in range(n, tabs):
			tab_container.get_child(i).queue_free()
	elif tabs < n:
		for i in range(tabs, n):
			var new_tab = load("res://scenes/MissionConfiguration.tscn").instance()
			new_tab.name = String(i)
			print("new tab " , i)
			tab_container.add_child(new_tab, true)
			
	
	

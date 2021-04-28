extends CenterContainer

onready var campaign_name : LineEdit = find_node("CampaignName",true,false)
onready var missions_in_campaign : HSlider = find_node("Missions",true,false)
onready var tab_container : TabContainer = find_node("TabContainer", true, false)

const campaign_save := "user://custom_campaign_data.dat"

func _ready():
	load_campaign_from_disk()

func reset():
	campaign_name.text = ""
	missions_in_campaign.value = 1
	for c in tab_container.get_children():
		c.name = "being_deleted"
		c.queue_free()
	var new_tab = load("res://scenes/MissionConfiguration.tscn").instance()
	new_tab.name = "1"
	tab_container.add_child(new_tab, true)

func dedictionise(var campaign : Dictionary):
	reset()
	if not dedictionise_internal(campaign):
		reset()
	
func dedictionise_internal(var campaign : Dictionary) -> bool:
	if not "name" in campaign:
		return false
	
	campaign_name.text = campaign["name"]

	if not "missions" in campaign:
		return false
		
	missions_in_campaign.value = campaign["missions"].size()
	# This adds the new tabs

	var mission_number = 0
	for mission in campaign["missions"]:
		if not "goal" in mission or not "goal_amount" in mission or not "lanes" in mission \
			or not "rings" in mission or not "factories_collect_above" in mission or not "input_lanes" in mission \
			or not "recipies" in mission or not "resources" in mission:
				return false
		
		var new_tab = tab_container.get_child(mission_number)
		mission_number += 1
		
		new_tab.find_node("GoalButton").selected = mission["goal"]
		new_tab.find_node("GoalButton").text = mission["goal"] + Global.data[mission["goal"]]["mode"]
		new_tab.find_node("GoalAmountSlider").value =  mission["goal_amount"]
		new_tab.find_node("LanesSlider").value  =  mission["lanes"]
		new_tab.find_node("RingsSlider").value =  mission["rings"]
		new_tab.find_node("Above").pressed = mission["factories_collect_above"]
		
		var inputs_node : GridContainer = new_tab.find_node("InputGridContainer",true,false)
		var input_number = 0
		for input_dict in mission["input_lanes"]:
			if not "resource" in input_dict or not "rate" in input_dict:
				return false
			var menu_button = inputs_node.get_node("Input" + String(input_number) + "/MenuButton")
			menu_button.selected = input_dict["resource"]
			menu_button.text = input_dict["resource"] + Global.data[input_dict["resource"]]["mode"]
			inputs_node.get_node("Input" + String(input_number) + "/RateSlider").value = input_dict["rate"]
			input_number += 1
			
		var recipies : GridContainer = new_tab.find_node("RecipiesGridContainer",true,false)
		for r in mission["recipies"]:
			var cb : CheckBox = recipies.get_node(r)
			cb.pressed = true
			
		var resources : GridContainer = new_tab.find_node("ResourceGridContainer",true,false)
		for r in mission["resources"]:
			var cb : CheckBox = resources.get_node(r)
			cb.pressed = true
			
		var mission_container : VBoxContainer = new_tab.find_node("MissionContainer",true,false)
		mission_container.call_deferred("update_configuration")
				
	return true
	

func dictionise() -> Dictionary:
	var result := {}
	
	result["name"] = campaign_name.text
	
	var missions := []
	for mission in tab_container.get_children():
		var mission_dict := {}
		mission_dict["goal"] = mission.find_node("GoalButton").selected
		mission_dict["goal_amount"] = mission.find_node("GoalAmountSlider").value
		mission_dict["lanes"] = mission.find_node("LanesSlider").value
		mission_dict["rings"] = mission.find_node("RingsSlider").value
		mission_dict["factories_collect_above"] = mission.find_node("Above").pressed
		#
		var lanes := []
		var inputs_node : GridContainer = mission.find_node("InputGridContainer",true,false)
		for i in range(6):
			var input_resource = inputs_node.get_node("Input" + String(i) + "/MenuButton").selected
			if input_resource == "None":
				continue
			var input_rate = inputs_node.get_node("Input" + String(i) + "/RateSlider").value
			var lane_dict := {}
			lane_dict["resource"] = input_resource
			lane_dict["rate"] = input_rate
			lanes.append(lane_dict)
		mission_dict["input_lanes"] = lanes
		#
		var recipies := []
		for c in mission.find_node("RecipiesGridContainer",true,false).get_children():
			if c is CheckBox and c.pressed:
				recipies.append(c.name)
		mission_dict["recipies"] = recipies
		#
		var resources := []
		for c in mission.find_node("ResourceGridContainer",true,false).get_children():
			if c is CheckBox and c.pressed:
				resources.append(c.name)
		mission_dict["resources"] = resources
		missions.append(mission_dict)
	result["missions"] = missions

	return result
	
func flush_campaign_to_disk():
	var file = File.new()
	file.open(campaign_save, File.WRITE)
	file.store_string(JSON.print(Global.campaigns))
	file.close()
	
func load_campaign_from_disk():
	var file = File.new()
	if file.file_exists(campaign_save):
		file.open(campaign_save, File.READ)
		var result = JSON.parse( file.get_as_text() )
		if result.error == OK:
			Global.campaigns.clear()
			Global.campaigns = result.result
		else:
			print("ERROR: JSON ERROR ", result.error_string)
		file.close()

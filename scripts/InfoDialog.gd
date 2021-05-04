extends WindowDialog

onready var shields = get_tree().get_root().find_node("Shields", true, false) 

var current_building : Area2D  = null
var current_ring : Node2D = null
var current_lanes : Array = []
var page : String = ""

func hide_diag():
	current_ring = null
	current_building = null
	page = ""
	hide()

func show_shared_internal():
	current_building = null
	current_ring = null
	page = ""
	for c in get_children():
		if c is MarginContainer:
			c.visible = false
	show()

func show_ring_diag(var ring : Node2D):
	show_shared_internal()
	$RingContainer.visible = true
	current_ring = ring
	update_ring_diag()
	
func show_building_diag(var factory : Area2D):
	show_shared_internal()
	$FactoryContainer.visible = true
	current_building = factory
	update_building_diag()

func toggle_menu_diag():
	var show : bool = (page != "menu")
	show_shared_internal()
	if show:
		Global.snap = get_viewport().get_texture().get_data()
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		Global.snap.flip_y()
		Global.snap.resize(512,300)
		Global.snap.save_png("res://ss.png")
		$MenuContainer.visible = true
		page = "menu"
		window_title = "Menu"
		$MenuContainer/Container/GridContainer/Mission.disabled = Global.sandbox
	else:
		hide_diag()

func show_named_diag(var n : String):
	if page == n: # Also acts as a toggle
		hide_diag()
		return
	show_shared_internal()
	var node = find_node(n+"Container")
	node.visible = true
	page = n
	window_title = n+" Settings"
	if has_method("update_"+n+"_diag"):
		call("update_"+n+"_diag")
		
# Used to refresh the page when it is being displyed
func update_diag():
	if current_ring != null:
		update_ring_diag()
	elif current_building != null:
		update_building_diag()
	else:
		pass

# Below used to update page on initial draw

func update_Sol_diag():
	window_title = "Sol"
	$SolContainer/VBoxContainer/GridContainer/LIcon1.texture = Global.data["H"]["texture"]
	
func update_Mission_diag():
	window_title = "Current Mission"
	$MissionContainer/VBox/CampaignName.text = Global.campaign["name"]
	var level_str = String(Global.level + 1) + " of " + String(Global.campaign["missions"].size())
	$MissionContainer/VBox/InfoGrid/MissionNumber.text = level_str
	$MissionContainer/VBox/InfoGrid/Rings.text = String(Global.rings - 1) # Avoid Sol
	$MissionContainer/VBox/InfoGrid/Lanes.text = String(Global.lanes)
	var from_above_str = "From above" if Global.factories_pull_from_above else "From below"
	$MissionContainer/VBox/InfoGrid/FromAbove.text = from_above_str
	var goal_res = Global.mission["goal"]
	var goal_amount = Global.mission["goal_amount"]
	print("goal res ", goal_res)
	$MissionContainer/VBox/HBottomBox/GoalTextureRect.texture = Global.data[ goal_res ]["texture"]
	$MissionContainer/VBox/HBottomBox/GoalNumber.text = "x" + String(goal_amount)

func update_building_diag():
	window_title = current_building.descriptive_name
	if current_building.mode == Global.BUILDING_UNSET:
		$FactoryContainer/Unset.visible = true
		$FactoryContainer/Set.visible = false
	else:
		$FactoryContainer/Unset.visible = false
		$FactoryContainer/Set.visible = true
		# Inputs
		if current_building.mode == Global.BUILDING_FACTORY:
			$FactoryContainer/Set/Inputs.visible = true
			var count = 0
			for i in range(current_building.get_process_node().input_content.size()):
				var cont = get_node("FactoryContainer/Set/Inputs/GridContainer/I"+String(i))
				var mm = cont.get_node("Count/Mm")
				var ico = cont.get_node("Icon")
				var resource = current_building.get_process_node().input_content[i]
				cont.visible = true
				ico.texture = Global.data[resource]["texture"]
				mm.set_resource(resource, current_building.get_process_node(), true, i)
				mm.set_visible_count(current_building.get_process_node().input_storage[i])
				count += 1
			while count < 4:
				var cont = get_node("FactoryContainer/Set/Inputs/GridContainer/I"+String(count))
				cont.visible = false
				count += 1
		else:
			$FactoryContainer/Set/Inputs.visible = false
		# Output
		var out_cont = get_node("FactoryContainer/Set/Output/OutAndShip/Out")
		var output = current_building.get_process_node().output_content
		var out_mm = out_cont.get_node("Count/Mm")
		var out_ico = out_cont.get_node("Icon")
		out_ico.texture = Global.data[output]["texture"]
		out_mm.set_resource(output, current_building.get_process_node())
		out_mm.set_visible_count(current_building.get_process_node().output_storage)
		# Output with Ship
		var ship_cont = get_node("FactoryContainer/Set/Output/OutAndShip/Ship")
		var ship = current_building.get_node("FactoryProcess").ship
		if ship != null and is_instance_valid(ship):
			print("Showing ship detail")
			ship_cont.visible = true
			var mm = ship_cont.get_node("Count/Mm")
			var ship_ico = ship_cont.get_node("Ship/Ship")
			ship_ico.set_resource(output)
			mm.set_resource(output, ship)
			mm.set_visible_count(ship.output_storage)
		else:
			print("Not showing ship detaild due to ship ", ship)
			ship_cont.visible = false

func update_ring_diag():
	var count : int = 1
	window_title = "Ring " + String(current_ring.ring_number)
	current_lanes.clear()
	for l in current_ring.get_lanes():
		# current_lanes is used by the bin script
		current_lanes.append(l)
		var tex : ImageTexture = null
		if l.lane_content != null:
			tex = Global.data[l.lane_content]["texture"]
		else:
			tex = Global.data["None"]["texture"]
		var icon : Node = find_node("LIcon"+String(count))
		icon.texture = tex
		var bin : Button = find_node("LBin"+String(count))
		bin.disabled = (l.lane_content == null)
		#
		var list : ItemList = $RingContainer/VBoxContainer/ScrollContainer/FactoriesList
		list.clear()
		var s_count := 0
		for s in current_ring.get_factories():
			list.add_item(s.descriptive_name)
			list.set_item_metadata(s_count, s)
			s_count += 1
		#
		count += 1
		
func update_Sandbox_diag():
	$SandboxContainer/VBoxContainer/FactoryBehaviour/Above.pressed = Global.factories_pull_from_above
	$SandboxContainer/VBoxContainer/Lane/LanesSlider.value = Global.lanes
	$SandboxContainer/VBoxContainer/Ring/RingsSlider.value = Global.rings - 1

func _on_UpdateTimer_timeout():
	if current_building != null:
		for mm in get_tree().get_nodes_in_group("InfoMultimeshGroup"):
			mm.update_visible()

func _on_Sandbox_pressed():
	show_named_diag("Sandbox")

func _on_Mission_pressed():
	show_named_diag("Mission")

func _on_Title_pressed():
	Global.goto_scene("res://Title.tscn")

func _on_Quit_pressed():
	get_tree().quit()

func _on_Back_pressed():
	toggle_menu_diag()

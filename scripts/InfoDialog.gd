extends WindowDialog

onready var shields = get_tree().get_root().find_node("Shields", true, false) 
onready var save_vbox = get_tree().get_root().find_node("SaveVBox", true, false) 
onready var load_vbox = get_tree().get_root().find_node("LoadVBox", true, false) 
onready var save_load = get_tree().get_root().find_node("SaveLoad", true, false) 

var current_building : Area2D  = null
var current_ring : Node2D = null
var current_lanes : Array = []
var page : String = ""

var sb_gray := StyleBoxFlat.new()
var sb_green := StyleBoxFlat.new()
var sb_blue := StyleBoxFlat.new()
var sb_purple := StyleBoxFlat.new()
var sb_orange := StyleBoxFlat.new()

var tut_current : int = 0
var tut_max : int =  0
var show_mission_after_tut : bool = false

func _ready():
	sb_gray.bg_color = Color.gray
	sb_green.bg_color = Color.greenyellow
	sb_blue.bg_color = Color.blue
	sb_purple.bg_color =  Color.purple
	sb_orange.bg_color = Color.orange

func hide_diag():
	print("hide")
	current_ring = null
	current_building = null
	page = ""
	hide()
	if show_mission_after_tut:
		_on_Mission_pressed()

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
		save_load.snap()
		$MenuContainer.visible = true
		page = "menu"
		window_title = "Menu"
		var show_export : bool = (Global.sandbox or Global.game_finished)
		$MenuContainer/Container/GridContainer/Mission.visible = !show_export
		$MenuContainer/Container/GridContainer/Export.visible = show_export
	else:
		print("toggle menu off")
		hide_diag()

func show_named_diag(var n : String):
	if page == n: # Also acts as a toggle
		print("show named toggle off")
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
	elif page == "Export":
		update_Export_diag()
	elif page == "Load":
		update_Load_diag()
	else:
		pass

# Below used to update page on initial draw

func update_Win_diag():
	var h : int = int(Global.time_played) / 3600
	var remainder : int = int(Global.time_played) % 3600
	var m = remainder / 60
	var s = remainder % 60
	window_title = "Congratulations!"
	$WinContainer/VBox/FinishedText.text = Global.campaign["name"] + " Finished in:\n\n"
	$WinContainer/VBox/FinishedText.text += String(h) + " hours, "
	$WinContainer/VBox/FinishedText.text += String(m) + " minutes, "
	$WinContainer/VBox/FinishedText.text += String(s) + " seconds. "

func update_Tutorial_diag():
	window_title = "Tutorial Message " + String(tut_current + 1)
	$TutorialContainer/VBox/HBox/ShowTutorialCheckbox.pressed = Global.settings["tutorial"]
	for t in get_tree().get_nodes_in_group("TutorialGroup"):
		t.visible = (t.name == String(tut_current))
	$TutorialContainer/VBox/HBox2/Prev.disabled = (tut_current == 0)
	$TutorialContainer/VBox/HBox2/Next.disabled = (tut_current == (tut_max - 1))

func update_Save_diag():
	window_title = "Save Game"
	update_SaveLoad_common(save_vbox)

func update_Load_diag():
	window_title = "Load Game"
	update_SaveLoad_common(load_vbox)
	
func update_SaveLoad_common(var vbox):
	var sls = load("res://scenes/SaveLoadSelector.tscn")
	for c in vbox.get_children():
		c.name = "deleted"
		c.queue_free()
	vbox.add_child(HSeparator.new())
	for key in Global.saves:
		var inst = sls.instance()
		inst.name = String(key)
		vbox.add_child(inst, true)
		vbox.add_child(HSeparator.new())

func update_Export_diag():
	var newly_opened = (window_title != "Export")
	window_title = "Export"
#	if not "H" in Global.exported:
#		Global.exported["H"] = 50
	var g = $ExportContainer/VBox/ExportedResourceGridSC/ExportedResourcesGrid
	for i in range(0, g.get_child_count(), 2):
		var n : int = 0
		var res = g.get_child(i).name
		if res in Global.exported:
			n = min(Global.exported[res], 100000)
		var current : float = g.get_child(i + 1).get_child(0).value
		var add = max(1, round((n - current) * 0.01))
		if newly_opened:
			current = n
		elif current != n:
			current += add
		g.get_child(i + 1).get_child(0).max_value = leet_n(current)
		g.get_child(i + 1).get_child(0).value = current
		g.get_child(i + 1).get_child(0).set("custom_styles/fg", leet_color(current))
		g.get_child(i + 1).get_child(1).text = String(current)

func leet_n(var n : int) -> int:
	if n < 10:
		return 10
	elif n < 100:
		return 100
	elif n < 1000:
		return 1000
	elif n < 10000:
		return 10000
	else:
		return 100000

func leet_color(var n : int) -> StyleBoxFlat:
	if n < 10:
		return sb_gray
	elif n < 100:
		return sb_green
	elif n < 1000:
		return sb_blue
	elif n < 10000:
		return sb_purple
	else:
		return sb_orange

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
	elif page == "Export":
		update_Export_diag()

func _on_Sandbox_pressed():
	show_named_diag("Sandbox")

func _on_Mission_pressed():
	show_named_diag("Mission")
	show_mission_after_tut = false

func _on_Title_pressed():
	Global.goto_scene("res://Title.tscn")

func _on_Quit_pressed():
	get_tree().quit()

func _on_Back_pressed():
	if show_mission_after_tut:
		_on_Mission_pressed()
	else:
		toggle_menu_diag()

func _on_Export_pressed():
	show_named_diag("Export")

func _on_Save_pressed():
	show_named_diag("Save")

func _on_Load_pressed():
	show_named_diag("Load")

func _on_Tutorial_pressed():
	show_named_diag("Tutorial")

func _on_Next_pressed():
	tut_current += 1 
	update_Tutorial_diag()

func _on_Prev_pressed():
	tut_current -= 1 
	update_Tutorial_diag()


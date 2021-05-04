extends Node2D

onready var id : WindowDialog = get_tree().get_root().find_node("InfoDialog", true, false) 
onready var injection : Node2D = get_tree().get_root().find_node("InjectionSystem", true, false) 
onready var gui_mission : HBoxContainer = get_tree().get_root().find_node("MissionGUIContainer", true, false) 
onready var gui_goal : TextureRect = get_tree().get_root().find_node("MissionTex", true, false) 
onready var gui_remaining : Label  = get_tree().get_root().find_node("MissionRemaining", true, false) 
onready var gui_mission_label : Label  = get_tree().get_root().find_node("MissionLabel", true, false) 
onready var gui_sandbox : Button  = get_tree().get_root().find_node("SandboxButton", true, false) 
onready var rs = get_tree().get_root().find_node("RingSystem", true, false)
onready var something_changed_node = $"/root/Game/SomethingChanged"

var t = 0

func change_level(var level):
	Global.level = level
	var rings : int = Global.MAX_RINGS
	var lanes : int = Global.MAX_LANES
	var from_above := true
	# Top Gui
	if Global.sandbox:
		Global.mission = null
		Global.remaining = 0
		gui_sandbox.visible = true
		gui_mission.visible = false
	else:
		Global.mission = Global.campaign["missions"][level]
		Global.remaining = Global.mission["goal_amount"]
		gui_sandbox.visible = false
		gui_mission.visible = true
		gui_goal.texture = Global.data[ Global.mission["goal"] ]["texture"]
		gui_remaining.text = "x" + String(Global.remaining)
		gui_mission_label.text = "Mission " + String(Global.level + 1)
		rings = Global.mission["rings"]
		lanes = Global.mission["lanes"]
		from_above = Global.mission["factories_collect_above"]
	# Number of rings
	set_rings(rings)
	# Number of lanes
	set_lanes(lanes)
	# Factory behaviour
	set_factories_collect(from_above)
	# Injectors
	if Global.sandbox:
		set_inectors(Global.sandbox_injectors)
	else:
		set_inectors(Global.mission["input_lanes"])
	# UI elements
	for g in get_tree().get_nodes_in_group("UIGridsGroup"):
		g.update_grid()
	# Show new mission intro
	if Global.sandbox:
		id.show_named_diag("Sandbox")
	else:
		id.show_named_diag("Mission")

# A ship has departed
func deposit(var resource : String, var amount : int):
	if not resource in Global.exported:
		Global.exported[resource] = 0
	Global.exported[resource] += amount
	if resource == Global.mission["goal"]:
		Global.to_subtract += amount
		set_process(true)
		
func _process(delta):
	t += delta
	while t > 0.1:
		t -= 0.1
		if Global.to_subtract == 0:
			set_process(false)
			return
		var sub = max(1, round(Global.to_subtract * 0.2))
		Global.to_subtract -= sub
		Global.remaining = int(max(0, Global.remaining - sub))
		gui_remaining.text = "x" + String(Global.remaining)
		if Global.remaining == 0:
			Global.to_subtract = 0
			change_level(Global.level + 1)

func set_inectors(var inj_data):
	for i in range(Global.MAX_INPUT_LANES): 
		var injector : MultiMeshInstance2D = injection.get_node("Injector"+String(i)).get_node("InjectorMm")
		if i < inj_data.size():
			# Change or update
			var res : String = inj_data[i]["resource"]
			var rate : float = inj_data[i]["rate"]
			injector.update_resource(res, 1.0/rate)
		else:
			injector.update_resource("None", 1.0)

func set_factories_collect(var from_above):
	pass
	#TODO. First clear all input lanes, change the rule, and let something_changed handle it

func set_lanes(var l : int):
	Global.lanes = l

	for ring_i in range(rs.get_child_count() -1, -1, -1):
		if ring_i == 0:
			continue
		print("Processing ring ", ring_i)
		var ring = rs.get_node("Ring"+String(ring_i))
		var lanes = ring.get_node("Rotation/Lanes")
		for lane_i in lanes.get_child_count():
			var lane = lanes.get_child(lane_i)
			if "deleted" in lane.name:
				continue
			if lane_i >= Global.lanes: # Remove
				if lane.lane_content != null:
					print("LANE ", lane_i ," REMOVE")
					lane.deregister_resource()
					id.update_diag()
					something_changed_node.something_changed()
			else:
				print("LANE ", lane_i ," KEEP")
	for o in get_tree().get_nodes_in_group("RingOutlineGroup"):
		o.update()
	
func set_rings(var r : int):
	var rs = get_tree().get_root().find_node("RingSystem", true, false)
	r += 1
	Global.rings = r
	# Note iterating backwards to remove ring above before running check_add_remove_ship on ring below
	for i in range(rs.get_child_count() -1, -1, -1):
		if i == 0:
			continue
		var ring = rs.get_node("Ring"+String(i))
		if i >= r: # Disable
			print("RING ", i ," REMOVE")
			ring.reset()
			ring.visible = false
		else:
			print("RING ", i ," KEEP")
			ring.visible = true
			for f in ring.get_factories():
				f.check_add_remove_ship()

func _on_Game_ready():
	change_level(0)

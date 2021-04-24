extends WindowDialog

onready var shields = get_tree().get_root().find_node("Shields", true, false) 

var current_building : Area2D  = null
var current_ring : Node2D = null
var current_lanes : Array = []
var sandbox : bool = false

func hide_diag():
	current_ring = null
	current_building = null
	hide()

func show_shared():
	current_building = null
	current_ring = null
	sandbox = false
	for c in get_children():
		if c is MarginContainer:
			c.visible = false
	show()

func show_ring_diag(var ring : Node2D):
	show_shared()
	$RingContainer.visible = true
	current_ring = ring
	update_ring_diag()
	
func show_building_diag(var factory : Area2D):
	show_shared()
	$RingContainer.visible = false
	current_building = factory
	update_building_diag()
	
func show_sandbox_diag(var factory : Area2D):
	show_shared()
	$SandboxContainer.visible = false
	sandbox = true
	update_sandbox_diag()
	
func update_diag():
	if current_ring != null:
		update_ring_diag()
	elif current_building != null:
		update_building_diag()
	elif sandbox:
		update_sandbox_diag()

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
		if ship != null:
			ship_cont.visible = true
			var mm = ship_cont.get_node("Count/Mm")
			var ship_ico = ship_cont.get_node("Ship/Ship")
			ship_ico.set_resource(output)
			mm.set_resource(output, ship)
			mm.set_visible_count(ship.output_storage)
		else:
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
			tex = Global.data["none"]["texture"]
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

func update_sandbox_diag():
	pass

func _on_UpdateTimer_timeout():
	if current_building != null:
		for mm in get_tree().get_nodes_in_group("InfoMultimeshGroup"):
			mm.update_visible()

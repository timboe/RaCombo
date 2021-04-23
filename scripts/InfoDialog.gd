extends WindowDialog

onready var shields = get_tree().get_root().find_node("Shields", true, false) 

var current_building : Area2D  = null
var current_ring : Node2D = null
var current_lanes : Array = []

func hide_diag():
	current_ring = null
	current_building = null
	hide()

func show_ring_diag(var ring : Node2D):
	$RingContainer.visible = true
	$FactoryContainer.visible = false
	current_ring = ring
	current_building = null
	update_ring_diag()
	show()
	
func show_building_diag(var factory : Area2D):
	$RingContainer.visible = false
	$FactoryContainer.visible = true
	current_building = factory
	current_ring = null
	update_building_diag()
	show()
	
func update_diag():
	if current_ring != null:
		update_ring_diag()
	if current_building != null:
		update_building_diag()

func update_building_diag():
	window_title = current_building.descriptive_name
	if current_building.mode == current_building.BUILDING_UNSET:
		$FactoryContainer/Unset.visible = true
		$FactoryContainer/Set.visible = false
	else:
		$FactoryContainer/Unset.visible = false
		$FactoryContainer/Set.visible = true
		# Inputs
		if current_building.mode == current_building.BUILDING_FACTORY:
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
		var out_cont = get_node("FactoryContainer/Set/Output/O")
		var output = current_building.get_process_node().output_content
		var out_mm = out_cont.get_node("Count/Mm")
		var out_ico = out_cont.get_node("Icon")
		out_ico.texture = Global.data[output]["texture"]
		out_mm.set_resource(output, current_building.get_process_node())
		out_mm.set_visible_count(current_building.get_process_node().output_storage)
		

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


func _on_UpdateTimer_timeout():
	if current_building != null:
		for mm in get_tree().get_nodes_in_group("InfoMultimeshGroup"):
			mm.update_visible()

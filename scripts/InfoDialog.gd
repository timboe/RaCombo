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
	print("show diag fact")
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
	if current_building.mode == current_building.BUILDING_FACTORY:
		window_title = "Factory "
	elif current_building.mode == current_building.BUILDING_INSERTER:
		window_title = "Inserter "
	elif current_building.mode == current_building.BUILDING_EXTRACTOR:
		window_title = "Extractor "
	window_title += "Satelite "
	window_title += String(current_building.name.to_int())

func update_ring_diag():
	var count : int = 1
	window_title = "Ring " + String(current_ring.set_ring)
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
		var list : ItemList = $RingContainer/VBoxContainer/FactoriesList
		list.clear()
		for f in current_ring.get_factories():
			list.add_item(f.name)
		#
		count += 1

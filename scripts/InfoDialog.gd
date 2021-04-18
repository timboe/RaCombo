extends WindowDialog

onready var shields = get_tree().get_root().find_node("Shields", true, false) 

var current_factory : Area2D  = null
var current_ring : Node2D = null
var current_lanes : Array = []

func show_ring_diag(var ring : Node2D):
	$RingContainer.visible = true
	$FactoryContainer.visible = false
	current_ring = ring
	update_ring_diag()
	show()
	
func show_factory_diag(var factory : Area2D):
	print("show diag fact")
	$RingContainer.visible = false
	$FactoryContainer.visible = true
	current_factory = factory
	update_factory_diag()
	show()

func update_factory_diag():
	window_title = "Factory " + String(current_factory.name.to_int())

func update_ring_diag():
	var count : int = 1
	window_title = "Ring " + String(current_ring.set_ring)
	current_lanes.clear()
	for l in current_ring.get_lanes():
		current_lanes.append(l)
		var ico = null
		if l.lane_content != null:
			ico = shields.get_node(l.lane_content).duplicate()
		else:
			ico = shields.get_node("none").duplicate()
		var holder : Node = find_node("LIcon"+String(count))
		for c in holder.get_children():
			c.queue_free()
		holder.add_child(ico)
		var bin : Button = find_node("LBin"+String(count))
		bin.disabled = (l.lane_content == null)
		#
		var list : ItemList = $RingContainer/VBoxContainer/FactoriesList
		list.clear()
		for f in current_ring.get_factories():
			list.add_item(f.name)
		#
		count += 1

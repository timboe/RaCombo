extends Node2D

onready var id = get_tree().get_root().find_node("InfoDialog", true, false) 
onready var something_changed_node = $"/root/Game/SomethingChanged"

func change_level():
	var level := Global.level
	var rings :int = Global.campaign["missions"][level]["rings"]
	set_rings(rings)
	var lanes : int = Global.campaign["missions"][level]["lanes"]
	set_lanes(lanes)
	var from_above : bool = Global.campaign["missions"][level]["factories_collect_above"]
	set_factories_collect(from_above)

func set_factories_collect(var from_above):
	pass
	#TODO

func set_lanes(var l : int):
	Global.lanes = l
	var rs = get_tree().get_root().find_node("RingSystem", true, false)
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


func _on_CentreNode_ready():
	change_level()

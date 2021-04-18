extends Button


func _on_Button_pressed():
	var i : int = name.to_int() - 1
	var id : WindowDialog = get_tree().get_root().find_node("InfoDialog",true,false)
	var lane : MultiMeshInstance2D = id.current_lanes[i]
	print("Binning lane ",i," which is ", lane)
	lane.deregister_resource()
	id.update_ring_diag()


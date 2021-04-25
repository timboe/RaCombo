extends Button

onready var id : WindowDialog = get_tree().get_root().find_node("InfoDialog",true,false)
onready var sc : Timer = get_tree().get_root().find_node("SomethingChanged",true,false)

func _on_Button_pressed():
	var i : int = name.to_int() - 1

	var lane : MultiMeshInstance2D = id.current_lanes[i]
	print("Binning lane ",i," which is ", lane)
	lane.deregister_resource()
	id.update_diag()
	sc.something_changed()
	
func _on_RemoveAll_pressed():
	id.current_ring.reset()
	id.hide_diag()
	sc.something_changed()

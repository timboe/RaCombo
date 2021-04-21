extends Timer

onready var id = get_tree().get_root().find_node("InfoDialog", true, false)

# Called from InjectorMultimesh - new input into lane
# Called from BinLane - lane reset
# Called from Factory - I/O changed which could affect other factories
func something_changed():
	print("Something changed! Start timer")
	start()

func _on_SomethingChanged_timeout():
	print("Something changed! Timeout")
	for f in get_tree().get_nodes_in_group("FactoryGroup"):
		f.lane_system_changed()
	id.update_diag()

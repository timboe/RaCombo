extends Timer

onready var id = get_tree().get_root().find_node("InfoDialog", true, false)

# Called from InjectorMultimesh - new input into lane
# Called from BinLane - lane reset
# Called from Factory - I/O changed which could affect other factories
func something_changed():
	start()

func _on_SomethingChanged_timeout():
	print("Something changed!")
	for f in get_tree().get_nodes_in_group("FactoryProcessGroup"):
		f.lane_system_changed()
	id.update_diag()

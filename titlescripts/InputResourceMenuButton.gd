extends MenuButton
tool

onready var pm : PopupMenu = get_popup() 
onready var mission_container : VBoxContainer = find_parent("MissionContainer")

export(String) var selected

func _ready():

	pm.clear()
	pm.connect("index_pressed", self, "_on_MenuButton_index_pressed")
	pm.add_item("None")
	pm.set_item_metadata(0, "None")
	selected = pm.get_item_metadata(0)
	text = pm.get_item_text(0)
	var i : int = 1
	for key in Global.data:
		if Global.data[key]["special"] == true:
			continue
		if Global.data[key]["from_sun"] == true:
			continue
		pm.add_item(key + Global.data[key]["mode"])
		pm.set_item_metadata(i, key)
		i += 1

func _on_MenuButton_index_pressed(var i):
	selected = pm.get_item_metadata(i)
	text = pm.get_item_text(i)
	mission_container.update_configuration()

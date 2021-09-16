extends Button

onready var hints : WindowDialog = get_tree().get_root().find_node("Hints", true, false)

func _on_SetHints_pressed():
	hints.popup()

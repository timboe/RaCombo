extends Button

onready var tab_container : TabContainer = find_parent("Campaign").find_node("TabContainer", true, false)
onready var warn_diag : AcceptDialog = find_parent("Campaign").find_node("WarningDialog", true, false)
onready var delete_conf_diag : ConfirmationDialog = find_parent("Campaign").find_node("DeleteConfirmationDialog", true, false)
onready var campaign_name : LineEdit = find_parent("Campaign").find_node("CampaignName", true, false)

func _on_Save_pressed():
	var bad_missions : String = ""
	var first = true
	for c in tab_container.get_children():
		var warn = c.find_node("WarningButton", true, false)
		if warn.visible:
			if first:
				first = false
			else:
				bad_missions += ", "
			bad_missions += c.name
	if bad_missions != "":
		warn_diag.dialog_text = "Problems with the configuration!\n\n"
		warn_diag.dialog_text += "Fix issues on the following missions before saving.\n\n"
		warn_diag.dialog_text += bad_missions
		warn_diag.show()
		return
		
	if campaign_name.text == "Main Campaign":
		warn_diag.dialog_text = "Cannot overwrite the 'Main Campaign'\n\n"
		warn_diag.dialog_text += "Please choose a different name."
		warn_diag.show()
		return
	
func _on_Delete_pressed():
	delete_conf_diag.show()

func _on_DeleteConfirmationDialog_confirmed():
	print("delete")

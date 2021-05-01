extends CenterContainer

onready var campaigns = get_tree().get_root().find_node("Campaigns", true, false)
onready var camp_editor = get_tree().get_root().find_node("CampaignEditor", true, false)

func _ready():
	show_menu("MainMenu")

func show_menu(var menu : String, var extra = null):
	for c in get_tree().get_nodes_in_group("PrimaryMenuElement"):
		c.visible = false
	get_parent().get_node(menu).visible = true
	
	if self.has_method(menu):
		self.call(menu, extra)

func CampaignManager(var _extra):
	for c in campaigns.get_node("Container").get_children():
		c.queue_free()
	for camp in Global.campaigns:
		var campaign = load("res://scenes/CampaignSelector.tscn").instance()
		campaigns.get_node("Container").add_child(campaign)
		campaign.get_node("CampaignName").text = camp

func CampaignEditor(var extra):
	if extra is String:
		camp_editor.dedictionise(Global.campaigns[extra])
	else:
		camp_editor.reset()

func _on_Editor_pressed():
	show_menu("CampaignManager")


func _on_Back_pressed():
	show_menu("MainMenu")


func _on_NewCampaign_pressed():
	show_menu("NewCampaign")

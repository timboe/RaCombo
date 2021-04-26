extends VBoxContainer

onready var goal_node : MenuButton = find_node("GoalButton",true,false)
onready var inputs_node : GridContainer = find_node("InputGridContainer",true,false)
onready var recipies_node : GridContainer = find_node("RecipiesGridContainer",true,false)
onready var resource_node : GridContainer = find_node("ResourceGridContainer",true,false)
onready var warning_button : Button = find_node("WarningButton",true,false)
onready var warning_placeholder : Container = find_node("WarningPlaceholder",true,false)
onready	var pd : AcceptDialog = get_parent().get_node("CenterContainer/PopupDialog")

var required_resources = {}
var required_recipies = {}
var input_lanes = []
var missing = []

func _ready():
	update_configuration()

func update_configuration():
	required_resources.clear()
	required_recipies.clear()
	input_lanes.clear()
	missing.clear()
	
	# Un-tick any things we previously required
	untick_for(recipies_node)
	untick_for(resource_node)
	
	# First we get the goal resource
	var goal = goal_node.selected
	
	# Now we get all incoming resources
	for i in range(6):
		var input_resource = inputs_node.get_node("Input" + String(i) + "/MenuButton").selected
		if input_resource == "None":
			continue
		if not input_resource in input_lanes:
			input_lanes.append(input_resource)
			add_required_resource(input_resource, "On input lane")
			
	# H is always available
	input_lanes.append("H")
	add_required_resource("H", "Always required")
	
	# Now we recursivly make sure that we can make the target object
	add_required_resource(goal, "Goal resource")
	recursive_check(goal)
	
	set_required(recipies_node, required_recipies)
	set_required(resource_node, required_resources)
	
	if missing.size():
		pd.dialog_text = "The goal cannot be reached given the current configuration.\n\n"
		pd.dialog_text += "Add the following resources to input lanes (or add derived resources)\n\n"
		for m in missing:
			pd.dialog_text += m + "  "
	warning_button.visible = missing.size() > 0
	warning_placeholder.visible = !warning_button.visible
	
func recursive_check(var r : String):
	# Is this thing available in an input lane?
	if r in input_lanes:
		return
	# Is this thing made in a factory?
	if not r in Global.recipies:
		# Then we cannot get it!
		if not r in missing and r != "Sol":
			missing.append(r)
		return
	add_required_recipy(r, "Required")
	for input_resource in Global.recipies[r]["input"]:
		add_required_resource(input_resource, "Required to make "+r)
		recursive_check(input_resource)
	
func add_required_resource(var r : String, var reason : String):
	if r in required_resources:
		return
	required_resources[r] = reason
	
func add_required_recipy(var r : String, var reason : String):
	if r in required_recipies:
		return
	required_recipies[r] = reason

func untick_for(var grid : GridContainer):
	for c in grid.get_children():
		if not c is CheckBox:
			continue
		if not c.disabled:
			continue
		c.disabled = false
		c.pressed = false
		grid.get_node(c.name + "_note").text = ""

func set_required(var node, var required):
	for req in required:
		if req == "Sol":
			continue
		var cb = node.get_node(req)
		cb.disabled = true
		cb.pressed = true
		node.get_node(req + "_note").text = required[req]
	


func _on_WarningButton_pressed():
	pd.show()

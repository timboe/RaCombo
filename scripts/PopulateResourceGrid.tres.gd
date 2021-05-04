extends GridContainer

func update_grid():
	for c in get_children():
		c.name = "deleted"
		c.queue_free()
	if name == "FactoryGrid" or name == "NewRecipiesGrid" or name == "TransmuteGrid":
		update_grid_factory()
	else:
		update_grid_resource()

func include_recipe(var r : String ):
	if not Global.sandbox:
		var this_level = Global.mission["recipies"]
		if not r in this_level:
			return false 
	var comaprison_bool := false
	if name == "TransmuteGrid":
		if Global.recipies[r]["factory"] == true:
			return false
	elif name == "FactoryGrid":
		if Global.recipies[r]["factory"] == false:
			return false
	if name == "NewRecipies":
		var last_level = []
		if Global.level > 0:
			last_level = Global.campaign["missions"][Global.level - 1]["recipies"]
		if r in last_level:
			return false
	return true

func update_grid_factory():
	for key in Global.recipies:
		if include_recipe(key):
			# B + B + B + B = B = 9 entries in the grid
			var recipe = Global.recipies[key]
			var entries = 0
			# Output - top
			var out_txt = Label.new()
			out_txt.text = String(recipe["amount_out"]) + "x " + String(recipe["time"]) + "s"
			out_txt.align = HALIGN_CENTER
			add_child(out_txt)
			add_child(Label.new()) # =
			entries += 2
			# Input - top
			for ai in range(recipe["amount_in"].size()):
				var in_txt = Label.new()
				in_txt.text = String(recipe["amount_in"][ai]) + "x"
				in_txt.align = HALIGN_CENTER
				add_child(in_txt)
				entries += 1
				if ai != recipe["amount_in"].size() - 1: # If not last
					add_child(Label.new()) # +
					entries += 1
			while entries < 9:
				add_child(Label.new()) # +
				entries += 1
			# Output - bottom
			entries = 0
			var n
			if name == "FactoryGrid":
				n = Button.new()
				n.rect_min_size = Vector2(64,64)
				n.expand_icon = true
				n.icon = Global.data[ key ]["texture"]
				n.name = key
				n.set_script(load("res://scripts/NewBuildingModeButton.gd"))
				n.connect("pressed", n, "_on_Button_pressed")
			else:
				n = TextureRect.new()
				n.rect_min_size = Vector2(64,64)
				n.expand = true
				n.texture = Global.data[ key ]["texture"]
			add_child(n)
			var out_txt2 = Label.new()
			out_txt2.text = "="
			out_txt2.align = HALIGN_CENTER
			add_child(out_txt2)
			entries += 2
			# Input - bottom
			for i in recipe["input"]:
				var tr := TextureRect.new()
				tr.rect_min_size = Vector2(64,64)
				tr.expand = true
				tr.texture = Global.data[ i ]["texture"]
				add_child(tr)
				entries += 1
				if i != recipe["input"][ recipe["input"].size() - 1 ]: # If not last
					var in_txt2 = Label.new()
					in_txt2.align = HALIGN_CENTER
					in_txt2.text = "+"
					add_child(in_txt2)
					entries += 1
			while entries < 9:
				add_child(Label.new()) # =
				entries += 1

func include_resource(var r : String ):
	if not Global.sandbox:
		var this_level = Global.mission["resources"]
		if not r in this_level:
			return false 
	if Global.data[r]["special"]:
		return false
	if name == "ExtractorGrid":
		if Global.data[r]["mode"] == "-":
			print("veto ",r," from ",name)
			return false
	elif name == "InserterGrid":
		if Global.data[r]["mode"] == "+":
			return false
	elif name == "NewResourcesGrid":
		var last_level = []
		if Global.level > 0:
			last_level = Global.campaign["missions"][Global.level - 1]["resources"]
		if r in last_level:
			return false
	return true
	

func update_grid_resource():
	for key in Global.data:
		if include_resource(key):
			var n
			if name == "ExtractorGrid" or name == "InserterGrid":
				n = Button.new()
				n.expand_icon = true
				n.rect_min_size = Vector2(64,64)
				n.icon = Global.data[key]["texture"]
				n.name = key
				n.set_script(load("res://scripts/NewBuildingModeButton.gd"))
				n.connect("pressed", n, "_on_Button_pressed")
			else:
				n = TextureRect.new()
				n.expand = true
				n.rect_min_size = Vector2(64,64)
				n.texture = Global.data[key]["texture"]
			add_child(n)


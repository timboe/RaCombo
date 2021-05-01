extends GridContainer

func update_grid():
	for c in get_children():
		c.name = "deleted"
		c.queue_free()
	if name == "FactoryGrid" or name == "NewRecipiesGrid":
		update_grid_factory()
	else:
		update_grid_resource()

func include_recipe(var r : String ):
	var this_level = Global.mission["recipies"]
	if not Global.sandbox and not r in this_level:
		return false 
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
			var dummy : int = 3 - Global.recipies[key]["input"].size()
			for _d in range(dummy):
				var c := Container.new()
				c.rect_min_size = Vector2(64,64)
				add_child(c)
			for i in Global.recipies[key]["input"]:
				var tr := TextureRect.new()
				tr.rect_min_size = Vector2(64,64)
				tr.expand = true
				tr.texture = Global.data[i]["texture"]
				add_child(tr)
			var ch := TextureRect.new()
			ch.rect_min_size = Vector2(64,64)
			ch.expand = true
			ch.texture = load("res://images/right-chevron.png")
			add_child(ch)
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

func include_resource(var r : String ):
	var this_level = Global.mission["resources"]
	if not Global.sandbox and not r in this_level:
		return false 
	if name == "ExtractorGrid":
		if Global.data[r]["mode"] == "-" or Global.data[r]["special"]:
			return false
	elif name == "InserterGrid":
		if Global.data[r]["mode"] == "+" or Global.data[r]["special"]:
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


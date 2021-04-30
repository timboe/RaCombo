extends GridContainer

func update_resource_recipy():
	if Global.data == null:
		return
		
	var was_pressed = []
	for c in get_children():
		if "Keep" in c.name:
			continue
		if c is CheckBox and c.pressed:
			was_pressed.append(c.name)
		c.name = "delete"
		c.queue_free()

	for key in Global.data:
		var d = Global.data[key]
		
		if d["special"] == true:
			continue

		var cb = CheckBox.new()
		add_child(cb)
		cb.name = key
		cb.pressed = (key in was_pressed)
		
		var prod = Label.new()
		prod.text += key + Global.data[ key ]["mode"]
		add_child(prod)
		
		var note = Label.new()
		note.name = key + "_note"
		note.text = ""
		add_child(note)

func _ready():
	update_resource_recipy()

		

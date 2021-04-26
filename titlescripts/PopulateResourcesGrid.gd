extends GridContainer

func _ready():

	for key in Global.data:
		var d = Global.data[key]
		
		if d["special"] == true:
			continue

		var cb = CheckBox.new()
		add_child(cb)
		cb.name = key
		
		var prod = Label.new()
		prod.text += key + Global.data[ key ]["mode"]
		add_child(prod)
		
		var note = Label.new()
		note.name = key + "_note"
		note.text = ""
		add_child(note)
		

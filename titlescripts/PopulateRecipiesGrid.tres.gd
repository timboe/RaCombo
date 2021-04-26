extends GridContainer

func _ready():
	for key in Global.recipies:

		var cb = CheckBox.new()
		add_child(cb)
		cb.name = key
		cb.disabled = true
		cb.pressed = true
		
		var d = Global.recipies[key]
		
		var time = Label.new()
		time.text = String(d["time"]) + "s"
		add_child(time)
		
		var prod = Label.new()
		prod.text = String(d["amount_out"]) + "x "
		prod.text += key + Global.data[ key ]["mode"]
		add_child(prod)
		
		var eq = Label.new()
		eq.text = "="
		add_child(eq)
		
		for i in range(4):
			var input = Label.new()
			if i < d["input"].size():
				input.text = String(d["amount_in"][i]) + "x " + d["input"][i]
				input.text += Global.data[ d["input"][i] ]["mode"]
			add_child(input)
			
		var note = Label.new()
		note.name = key + "_note"
		note.text = ""
		add_child(note)
		

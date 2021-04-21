extends Control
tool

const REGENERATE = false

var keys = []
var count = 0

onready var rendered_node = get_tree().get_root().find_node("Render", true, false)
onready var shield_scene = load("res://scenes/Shield.tscn")
onready var globals = load("res://scripts/Global.gd").new()

func _ready():
	set_process(REGENERATE)
	if REGENERATE:
		for n in get_children():
			n.queue_free()
		for n in rendered_node.get_children():
			n.queue_free()
		keys = globals.data.keys()
	else:
		set_data()
		
func set_data():
	for key in globals.data.keys():
		Global.data[key]["texture"] = rendered_node.find_node(key).texture
	
func _process(var _delta):
	var key = keys[count]
	var value = globals.data[key]
	var shield = shield_scene.instance()
	shield.name = key
	add_child(shield, true)
	shield.set_owner(get_tree().get_edited_scene_root())
	var back : StyleBoxFlat = shield.get_node("Back").get_stylebox("panel")
	back.bg_color = value["color"]
	back.shadow_color = value["color"].darkened(0.2)
	var label : Label = shield.get_node("Label")
	label.set("custom_colors/font_color", value["color"].contrasted())
	label.text = value["name"]
	var _sign : Label = shield.get_node("Sign")
	_sign.set("custom_colors/font_color", value["color"].contrasted())
	_sign.text = "-" if value["mode"] == "insert" else "+"
	# Specials
	if key == "none":
		_sign.text = ""
	# Render
	# Wait until the frame has finished before getting the texture.
	get_parent().set_update_mode(Viewport.UPDATE_ONCE)
	yield(VisualServer, "frame_post_draw")
	var img = get_parent().get_texture().get_data()
	var err = img.generate_mipmaps()
	if err != OK:
		print("Failure! ", err)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	var tr := TextureRect.new()
	rendered_node.add_child(tr)
	tr.set_owner(get_tree().get_edited_scene_root())
	tr.texture = tex
	tr.name = key
	tr.margin_left = 256 * (count % 4)
	tr.margin_top = 256 * floor(count / 4)
	count += 1
	if count == keys.size():
		set_process(false)
		set_data()

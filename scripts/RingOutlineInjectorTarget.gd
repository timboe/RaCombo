extends Node2D

export(String) var inject = ""

onready var ring = find_parent("Ring*")

func serialise() -> Dictionary:
	var d = {}
#	d["inject"] = inject
	d["visible"] = visible
	return d
	
func deserialise(var d : Dictionary):
#	inject = d["inject"]
	visible = d["visible"] 
	#update()

func _ready():
	update()

func set_inject(var i):
	inject = i

func _draw():
	var p : Node2D = get_parent()
	if p.name == "Ring0":
		return
	var to_draw : int =  Global.lanes 
	var inner : float = p.radius_array[ 0 ] - p.LANE_OFFSET/2.0
	var outer : float = p.radius_array[ to_draw-1] + p.LANE_OFFSET/2.0
	var width = (outer - inner) / 2.0
	var hl : float = 0.2
	var c1 = Color(0.8 + hl, 0.8 + hl, 0.8 + hl)
	var c2 = Color(0.6 + hl, 0.6 + hl, 0.6 + hl)

	if inject != "" and get_parent().get_free_or_existing_lane(inject) != -1:
		var mid = inner + width
		draw_arc(Vector2(0, -mid), width, 0, 2*PI, 128, c2, 1, true)
		draw_arc(Vector2(0, -mid), width + p.LANE_OFFSET, 0, 2*PI, 128, c1, 1, true)
	
	draw_line(Vector2(0,0), Vector2(0,0), Color(1,1,1)) # Reset palette (bug)

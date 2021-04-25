extends Node2D
tool

export(bool) var highlight setget set_highlight
export(String) var inject = ""
export(bool) var show setget set_show

func set_highlight(var i : bool):
	highlight = i
	update()
	
func set_inject(var i:  bool, var resource : String):
	inject = resource if i else ""
	update()

func set_show(var i : bool):
	show = i
	update()

func _draw():
	var p : Node2D = get_parent()
	var to_draw : int = p.set_lanes if p.name == "Ring0" else Global.lanes 
	var outer : float = p.radius_array[ to_draw-1] + p.LANE_OFFSET/2.0
	var hl : float = 0.2 if highlight else 0.0
	var c1 = Color(0.8 + hl, 0.8 + hl, 0.8 + hl)
	var c2 = Color(0.6 + hl, 0.6 + hl, 0.6 + hl)
	
	if show:
		for i in range(to_draw):
			var r : float = p.radius_array[i] - p.LANE_OFFSET/2.0
			var c = c1 if i == 0 else c2
			draw_arc(Vector2(0,0), r, 0, 2*PI, 256, c, 1, true)

		draw_arc(Vector2(0,0), outer, 0, 2*PI, 256, c1, 1, true)
	
	if inject != "" and get_parent().get_free_or_existing_lane(inject) != -1:
		var inner = p.radius_array[0] - p.LANE_OFFSET/2.0
		var width = (outer - inner) / 2.0
		var mid = inner + width
		draw_arc(Vector2(0, -mid), width, 0, 2*PI, 128, c2, 1, true)
		draw_arc(Vector2(0, -mid), width + p.LANE_OFFSET, 0, 2*PI, 128, c1, 1, true)
	
	draw_line(Vector2(0,0), Vector2(0,0), Color(1,1,1)) # Reset palette (bug)

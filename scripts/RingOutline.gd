extends Node2D
tool

export(bool) var highlight setget set_highlight

func set_highlight(var hl : bool):
	highlight = hl
	update()

func _draw():
	var p : Node2D = get_parent()
	var hl : float = 0.2 if highlight else 0.0
	var c1 = Color(0.6 + hl, 0.6 + hl, 0.6 + hl)
	var c2 = Color(0.4 + hl, 0.4 + hl, 0.4 + hl)
	for i in range(get_parent().set_lanes):
		var r : float = p.radius_array[i] - p.LANE_OFFSET/2.0
		var c = c1 if i == 0 else c2
		draw_arc(Vector2(0,0), r, 0, 2*PI, 256, c, 1, true)
	var r : float = p.radius_array[ p.set_lanes-1] + p.LANE_OFFSET/2.0
	draw_arc(Vector2(0,0), r, 0, 2*PI, 256, c1, 1, true)

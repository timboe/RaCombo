extends Node2D
tool

export(bool) var show setget set_show

onready var mm : MultiMeshInstance2D = get_child(0)
var r_scr = load("res://scripts/Ring.gd").new()

func set_show(var i : bool):
	show = i
	update()

func _draw():
	if show:
		draw_line(Vector2(0, -(mm.radius + r_scr.LANE_OFFSET/2.0)),
		  Vector2(-(mm.WIDTH+mm.EXTRA_MARGIN), -(mm.radius + r_scr.LANE_OFFSET/2.0)),
		  Color(0.8,0.8,0.8))
		draw_line(Vector2(0, -(mm.radius - r_scr.LANE_OFFSET/2.0)),
		  Vector2(-(mm.WIDTH+mm.EXTRA_MARGIN), -(mm.radius - r_scr.LANE_OFFSET/2.0)),
		  Color(0.8,0.8,0.8))

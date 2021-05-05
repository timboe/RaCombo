extends Node2D

export(bool) var show setget set_show

const c = Color(1,1,1)

onready var mm : MultiMeshInstance2D = get_child(0)
var r_scr = load("res://scripts/Ring.gd").new()

func set_show(var i : bool):
	show = i
	update()

func _draw():
	if show:
		draw_line(Vector2(0, -(mm.radius + r_scr.LANE_OFFSET/2.0)),
		  Vector2(-(mm.WIDTH+mm.EXTRA_MARGIN), -(mm.radius + r_scr.LANE_OFFSET/2.0)), c)
		draw_line(Vector2(0, -(mm.radius - r_scr.LANE_OFFSET/2.0)),
		  Vector2(-(mm.WIDTH+mm.EXTRA_MARGIN), -(mm.radius - r_scr.LANE_OFFSET/2.0)), c)

func serialise() -> Dictionary:
	var d = mm.serialise()
	d["show"] = show
	d["visible"] = visible
	return d

func deserialise(var d : Dictionary):
	show = d["show"]
	visible = d["visible"]
	mm.deserialise(d)
	update()

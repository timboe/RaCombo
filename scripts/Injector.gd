extends Node2D
tool

const c = Color(1,1,1)

onready var mm : MultiMeshInstance2D = get_parent().get_node("InjectorMm")
var r_scr = load("res://scripts/Ring.gd").new()

func _draw():
	print("Injector lines update is vis ",visible)
	draw_line(Vector2(0, -(mm.radius + r_scr.LANE_OFFSET/2.0)),
	  Vector2(-(mm.WIDTH+mm.EXTRA_MARGIN), -(mm.radius + r_scr.LANE_OFFSET/2.0)), c)
	draw_line(Vector2(0, -(mm.radius - r_scr.LANE_OFFSET/2.0)),
	  Vector2(-(mm.WIDTH+mm.EXTRA_MARGIN), -(mm.radius - r_scr.LANE_OFFSET/2.0)), c)

func serialise() -> Dictionary:
	var d = mm.serialise()
	d["visible"] = visible
	return d

func deserialise(var d : Dictionary):
	visible = d["visible"]
	mm.deserialise(d)
	update()

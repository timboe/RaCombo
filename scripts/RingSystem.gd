extends Node2D
tool

const RING_RADIUS := 40

export(int) var rings

func _ready():
	rings = 0
	for c in get_children():
		rings += 1
		c.setup_resource(RING_RADIUS * rings)


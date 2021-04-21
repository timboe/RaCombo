extends Node2D
tool

const RING_RADIUS := 40
const RING_WIDTH := 20

export(int) var rings

func _ready():
	rings = 0
	for c in get_children():
		rings += 1
		c.setup_resource(RING_RADIUS * rings)
		if rings == 1: # Sol
			c.get_lane(3).register_resource("hydrogen", null)
			c.get_lane(3).set_as_source_lane()



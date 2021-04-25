extends Node2D
tool

const RING_RADIUS := 40
const RING_WIDTH := 20

func _ready():
	var rings = 0
	for c in get_children():
		rings += 1
		c.setup_resource(RING_RADIUS * rings)
		if rings == 1: # Sol
			c.get_lane(3).register_resource("H", null)
			c.get_lane(3).set_as_source_lane()
			c.get_lane(2).register_resource("Cf", null)
			c.get_lane(1).register_resource("T", null)
			# Any cunife deposited in lane 2 becomes tritium in lane 1
			c.get_lane(2).set_laneswap( c.get_lane(1) )
			c.get_lane(0).set_as_sink_lane()



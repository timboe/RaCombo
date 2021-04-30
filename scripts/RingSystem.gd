extends Node2D
tool

const RING_RADIUS := 40
const RING_WIDTH := 20

func _ready():
	var rings = 0
	for c in get_children():
		rings += 1
		c.setup_resource(RING_RADIUS * rings)
	setup_sol()

# Note: Changing level does not affect this - only need to do it once
func setup_sol():
	var sol = get_child(0)
	if sol.get_lane(7).source == false:
		sol.get_lane(7).register_resource("H", null)
		sol.get_lane(7).set_as_source_lane()
	if sol.get_lane(0).sink == false:
		sol.get_lane(0).set_as_sink_lane()
	# Setup transmute
	var next_out := 1
	var next_in := 2
	for r in Global.recipies:
		if Global.recipies[r]["factory"] == true:
			continue
		var tranmute_from = Global.recipies[r]["input"][0]
		var transmute_to = r
		sol.get_lane(next_out).register_resource(transmute_to, null)
		sol.get_lane(next_in).register_resource(tranmute_from, null)
		sol.get_lane(next_out).forbid_send = true
		# Any "tranmute_from" deposited in lane "next_in" becomes "transmute_to" in lane "next_out
		sol.get_lane(next_in).set_laneswap( sol.get_lane(next_out) )
		next_out += 2
		next_in += 2

	

extends Button

var prev_ring : Node2D = null

func _process(delta):
	if not pressed:
		return
	var rs : Node2D = get_tree().get_root().get_node("Root/RingSystem")
	var cursor = get_global_mouse_position()
	var dist : float = abs( cursor.distance_to( rs.position ) )
	var ring_index : int = clamp(round(dist / rs.RING_RADIUS) - 1, 0, rs.rings - 1)
	var ring : Node2D = rs.get_child(ring_index)
	if prev_ring == null:
		prev_ring = ring
		ring.get_node("Outline").set_highlight(true)
		ring.get_node("FactoryTemplate").visible = true
	if prev_ring != ring:
		prev_ring.get_node("Outline").set_highlight(false)
		prev_ring.get_node("FactoryTemplate").visible = false
		ring.get_node("Outline").set_highlight(true)
		ring.get_node("FactoryTemplate").visible = true
		prev_ring = ring
	var cursor_angle : float = atan2(rs.position.y - cursor.y, rs.position.x - cursor.x) - PI
	if cursor_angle < 0:
		cursor_angle += 2*PI
	print(rad2deg(cursor_angle))
	ring.get_node("FactoryTemplate").global_rotation = cursor_angle
	

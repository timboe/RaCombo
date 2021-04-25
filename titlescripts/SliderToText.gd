extends HSlider

func _on_HSlider_value_changed(value):
	get_parent().get_node("N").text = String(value)

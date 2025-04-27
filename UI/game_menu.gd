extends Control



func _on_h_slider_value_changed(value: float) -> void:
	%SizeLabel.text = str(int(value))

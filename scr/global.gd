extends Node
func _process(delta: float) -> void:
	get_tree().root.content_scale_factor = DisplayServer.window_get_size().x / 1920.0 * 4.0

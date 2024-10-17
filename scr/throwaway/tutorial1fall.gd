extends Area2D
var current = 0

func _process(_delta: float) -> void:
	for area in get_overlapping_areas():
		if area.get_parent() is player:
			area.get_parent().locked = true
			if current == 0:
				$Fall.play()
				current = 1
				$Timer.start()




func _on_timer_timeout() -> void:

	get_tree().change_scene_to_file("res://lvl/tutorial2.tscn")

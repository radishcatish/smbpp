extends Area2D
# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_area_entered(area: Area2D) -> void:
		if area.get_parent() is player:
			area.get_parent().cant_move = false
			area.get_parent().state = player.PlayerState.DIVE
			queue_free()

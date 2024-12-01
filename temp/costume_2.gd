extends Sprite2D
@onready var area_2d: Area2D = $Area2D
@onready var plants: Node = $"../plants"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _process(_delta: float) -> void:
	for area in area_2d.get_overlapping_areas():
		if area.get_parent() is player:
			plants.queue_free()
			audio_stream_player.play()
			self.queue_free()

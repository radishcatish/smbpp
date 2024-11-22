extends Node2D
@onready var timer: Timer = $Timer
var velocity = Vector2(randi_range(-500, 500) / 100.0, -20) * .25
@onready var deadporghetqioph: AudioStreamPlayer = $AudioStreamPlayer


func _physics_process(delta: float) -> void:
	
	if timer.is_stopped():
		position += velocity
		rotation += velocity.x / 16
		velocity.y += 0.25
	 



func _on_audio_stream_player_finished() -> void:
	get_tree().reload_current_scene()

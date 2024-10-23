extends Sprite2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	visible = true

func _process(_delta: float) -> void:
	self.modulate = Color(0,0,0,timer.time_left / 2)
	global_position = global.camera.global_position + global.camera.offset

func _on_timer_timeout() -> void:
	queue_free()

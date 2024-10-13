extends Node2D
class_name Coin
const COIN_AMOUNT = 1
var state = 0
@onready var coin: AnimatedSprite2D = $coin
@onready var sparkles: AnimatedSprite2D = $sparkles
@onready var shape: Area2D = $shape
@onready var timer: Timer = $Timer

@onready var light_occluder_2d: LightOccluder2D = $LightOccluder2D
@onready var point_light_2d: PointLight2D = $PointLight2D


func _process(_delta):
	
	if state == 0 and not coin.visible == true:
		shape.monitorable = true
		coin.visible = true
		sparkles.visible = false
		light_occluder_2d.visible = true
		point_light_2d.visible = false
		
	if state == 1 and not coin.visible == false:
		timer.stop()
		sparkles.visible = true
		sparkles.play(&"animation")
		coin.visible = false
		light_occluder_2d.visible = false
		point_light_2d.visible = true
		state = 2
		
	if sparkles.frame == 2 and state == 2 and timer.is_stopped():
		sparkles.frame = 0
		sparkles.stop()
		sparkles.visible = false
		light_occluder_2d.visible = false
		point_light_2d.visible = false
		shape.monitorable = false
		timer.start()


func _on_timer_timeout() -> void:
	state = 0

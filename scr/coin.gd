extends Node2D
class_name Coin
var state = 0
@onready var coin: AnimatedSprite2D = $coin
@onready var sparkles: AnimatedSprite2D = $sparkles
@onready var shape: Area2D = $shape

@onready var light_occluder_2d: LightOccluder2D = $LightOccluder2D
@onready var point_light_2d: PointLight2D = $PointLight2D


func _process(_delta):
	if state == 0:
		shape.monitorable = true
		coin.visible = true
		sparkles.visible = false
		light_occluder_2d.visible = true
		point_light_2d.visible = false
		
	if state == 1:
		sparkles.visible = true
		sparkles.play(&"animation")
		coin.visible = false
		light_occluder_2d.visible = false
		point_light_2d.visible = true
		state = 2
		
	if sparkles.frame == 2 and state == 2:
		sparkles.visible = false
		light_occluder_2d.visible = false
		point_light_2d.visible = false
		shape.monitorable = false
		await get_tree().create_timer(180).timeout
		state = 0

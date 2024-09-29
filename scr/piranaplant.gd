extends Node2D
@export var isInPipe: bool
@export var aggression: float
@onready var stem: Sprite2D = $stem
@onready var mouth: AnimatedSprite2D = $stem/mouth
@onready var mariodetectionradius: Area2D = $mariodetectionradius

var animationposition := 0.0
var distance: float

func _ready() -> void:
	if isInPipe:
		position.y += 14
		$stem/hurtbox.position.y = 2
func _physics_process(_delta: float) -> void:
	var angle_to_mario = 0

	distance = 0
	for area in mariodetectionradius.get_overlapping_areas():
		if area.get_parent() is player:
			angle_to_mario = position.direction_to(area.get_parent().global_position).angle()

	stem.rotation = lerp_angle(rotation, angle_to_mario, 0.5)

	
	if isInPipe:
		animationposition += (0.05 + aggression / 7.0)
		stem.position.y = (sin(animationposition) * 16)
	

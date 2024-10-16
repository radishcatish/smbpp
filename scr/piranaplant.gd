extends Node2D
class_name Enemy
const DAMAGE: int = 1
@export var isInPipe: bool
@export var aggression: float
@onready var stem: Sprite2D = $stem
@onready var mouth: AnimatedSprite2D = $stem/mouth
@onready var mariodetectionradius: Area2D = $mariodetectionradius
@onready var openoccluder: LightOccluder2D = $stem/mouth/openoccluder
@onready var closedocculder: LightOccluder2D = $stem/mouth/closedocculder
var angle_to_mario: float = 0
var mario_angle_lerped: float = 0
var animationposition := 0.0
var distance: float

func _ready() -> void:
	if isInPipe:
		position.y += 14
		$stem/hurtbox.position.y = 2

func _physics_process(_delta: float) -> void:
	angle_to_mario = 0
	

	for area in mariodetectionradius.get_overlapping_areas():
		if area.get_parent() is player:
			angle_to_mario = position.direction_to(area.get_parent().global_position).angle()
	if angle_to_mario != 0:
		mario_angle_lerped = lerp(mario_angle_lerped, angle_to_mario + deg_to_rad(90), 0.1) 
	else:
		mario_angle_lerped = lerp(mario_angle_lerped, 0.0, 0.1)
	stem.rotation =  mario_angle_lerped / 4
	mouth.rotation =  mario_angle_lerped / 4
	
	if isInPipe:
		animationposition += (0.05 + aggression / 7.0)
		stem.position.y = (sin(animationposition) * 16)
	

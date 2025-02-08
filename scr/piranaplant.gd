extends Node2D
class_name Enemy
const DAMAGE: int = 1
@export var isInPipe: bool
@export var aggression: float
@onready var stem: Sprite2D = $stem
@onready var mouth: AnimatedSprite2D = $stem/mouth



var animationposition := 0.0
var distance: float

func _ready() -> void:
	if isInPipe:
		position.y += 14
		$stem/hurtbox.position.y = 2

func _physics_process(_delta: float) -> void:

	if isInPipe:
		animationposition += (0.05 + aggression / 7.0)
		stem.position.y = (sin(animationposition) * 16)
	

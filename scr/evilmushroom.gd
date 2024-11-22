extends Node2D
@onready var mario = get_tree().get_first_node_in_group("Player")
var marioexists: bool = true
## Most fair speed is 5.4, Mario's running speed
@export var difficulty = 5.4
## Leave at 1 unless difficulty is too high or too low. Cannot be 0
@export var turningSharpness = 1
var mushroomAngle = Vector2.ZERO
@onready var cam: CollisionShape2D = $cam/CollisionShape2D
var positional_velocity = Vector2.ZERO
var last_pos = Vector2.ZERO
var marioDead = false

@onready var squish: AudioStreamPlayer2D = $Squish

func _ready() -> void:
	if turningSharpness < 0.1:
		turningSharpness = 0.1
	if is_instance_valid(get_tree().get_first_node_in_group("Player")):
		mario = get_tree().get_first_node_in_group("Player")
	else:
		visible = false
		marioexists = false


func _physics_process(_delta: float) -> void:
	if marioexists:
		if last_pos != position:
			
			positional_velocity = last_pos - position
			positional_velocity *= .1
			last_pos = position
		
		var marioDir = position.direction_to(mario.position)
		if marioDead:
			marioDir = Vector2(-1,-.7)
			difficulty = 8
			turningSharpness = .2
			
		mushroomAngle = lerp(mushroomAngle, marioDir, 0.01 * (difficulty * 1.5 ) * turningSharpness)
		position += mushroomAngle * (difficulty / 2)
		cam.scale.x = 1 + positional_velocity.length_squared()
		cam.scale.y = cam.scale.x
		cam.position = mushroomAngle
		
		if (mario.position - position).length_squared() < 20:
			mario.health = 0
			marioDead = true
			marioDir = Vector2(-1,-.7)
			difficulty = 8
			turningSharpness = .2
			squish.play()
		

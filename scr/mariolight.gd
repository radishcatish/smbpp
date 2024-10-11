extends CharacterBody2D
@onready var ball: Sprite2D = $ball
@onready var ambient: Sprite2D = $ambient

var mario
var marioexists: bool = true

func _ready() -> void:
	if is_instance_valid(get_tree().get_first_node_in_group("Player")):
		mario = get_tree().get_first_node_in_group("Player")
	else:
		self.queue_free()
		
var last_pos := Vector2(0,0)
var positional_velocity := Vector2(0,0)
func _physics_process(delta: float) -> void:
	
	if last_pos != position:
		positional_velocity = last_pos - position
		last_pos = position
		
	ball.scale.x = 0.008 + abs(positional_velocity / 4).length() * delta
	ball.position.x =  abs(positional_velocity * 120).length() * delta
	rotation = positional_velocity.angle()
	ambient.scale.x = 0.17 + abs(positional_velocity / 4).length() * delta
	ambient.position.x = ball.position.x 
	position = Vector2(
		lerp(position.x, mario.position.x - mario.directionnotzero * 15, 0.1),
		lerp(position.y, mario.position.y - 15 - Input.get_axis("down", "up") * 20, 0.1))
	
	move_and_slide()

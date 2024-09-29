extends Node2D
enum platformmode {default, circle, halfcircle}
@export var set_mode = platformmode.default
## If setmode is set to default or halfcircle, this is the position where the platform stops moving. If it is set to circle, then it's the circle's radius. 
@export var end_position: Vector2 = Vector2.ZERO
@export var speed: float = 1
@export var lerp_speed: float = 0.3
var plusone: float = 0.0
@onready var initialposition := global_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$bolt.queue_free()
	end_position *= 16



func _physics_process(delta):
	plusone += delta
	if set_mode == platformmode.circle:
		global_position = initialposition + Vector2(sin(plusone * speed), cos(plusone * speed)) * end_position

extends Node2D
enum platformmode {default, circle}
@export var set_mode = platformmode.default
## If setmode is set to default, this is the position where the platform stops moving. If it is set to circle, then it's the circle's radius. 
@export var end_position: Vector2 = Vector2.ZERO
@export var starting_speed: float = 1
@export var starting_tween_mode = Tween.TRANS_SINE
@export var ending_speed: float = 1
@export var ending_tween_mode = Tween.TRANS_SINE

@onready var initialposition := global_position
var time: float = 0.0
var position_in_movement: int = 0
var difference_in_position: float


func _ready() -> void:
	$bolt.queue_free()
	end_position *= 16
	
	if set_mode == platformmode.default:
		var tween = get_tree().create_tween()
		end_position += position 
		tween.set_loops().set_parallel(false)
		tween.tween_property(self, "position", end_position, starting_speed).set_trans(starting_tween_mode)
		tween.tween_property(self, "position", initialposition, ending_speed).set_trans(ending_tween_mode)

func _physics_process(delta):
	if set_mode == platformmode.circle:
		time += delta
		global_position = initialposition + Vector2(sin(Time.get_ticks_msec() / 1000.0 * starting_speed), cos(Time.get_ticks_msec() / 1000.0 * starting_speed)) * end_position
	

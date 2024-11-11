extends CanvasLayer
@onready var static_text: RichTextLabel = $Static
@onready var coins_counter: RichTextLabel = $CoinsCounter
@onready var score_counter: RichTextLabel = $ScoreCounter
@onready var hpcounter: Control = $hpcounter
@onready var hpcircle: AnimatedSprite2D = $hpcounter/hpcircle
@onready var coinhpcount: AnimatedSprite2D = $hpcounter/coinhpcount
@onready var bg: Sprite2D = $hpcounter/bg
@onready var text: Sprite2D = $hpcounter/text
@onready var camera: Camera2D = $Camera2D


var last_pos = Vector2.ZERO
var positional_velocity = Vector2.ZERO
 
@onready var mario = get_tree().get_first_node_in_group("Player")
var marioexists: bool = true

func _ready() -> void:
		
	if is_instance_valid(get_tree().get_first_node_in_group("Player")):
		mario = get_tree().get_first_node_in_group("Player")
		camera.global_position = mario.global_position
		
	else:
		visible = false
		marioexists = false
		
var coins: int = 0
var score: int = 0
var healthbefore: int
func _process(delta: float) -> void:
	

	if is_instance_valid(get_tree().get_first_node_in_group("Player")):
		mario = get_tree().get_first_node_in_group("Player")
		visible = true
		marioexists = true
	else:
		visible = false
		marioexists = false
		
	if marioexists == true:
		coins_counter.text = " %06d" % coins
		score_counter.text = " %07d" % score
		hpcircle.play(str(mario.health)) 
		coinhpcount.play(str(mario.coins_until_hp))
			
		if healthbefore != mario.health:
			
			if healthbefore < 0:
				hpcounter.scale = Vector2(1.1,1.1)
				get_tree().create_tween().tween_property(hpcounter, "scale", Vector2(1,1), 0.3).set_ease(Tween.EASE_OUT)
			else:
				hpcounter.scale = Vector2(.9,.9)
				get_tree().create_tween().tween_property(hpcounter, "scale", Vector2(1,1), 0.3).set_ease(Tween.EASE_OUT)
		
		healthbefore = mario.health
		
		camera.position = mario.position
		if mario.camera_interested_in_pos != Vector2(0,0):
			camera.offset = lerp(camera.offset, Vector2(0, -32.0) + (mario.global_position - mario.camera_interested_in_pos) * -0.5, 4.0 * delta)

		if last_pos != camera.position:
			
			positional_velocity = last_pos - camera.position
			positional_velocity *= -4500 * delta
			last_pos = camera.position

		camera.offset = Vector2(
			lerp(camera.offset.x,  positional_velocity.x / 16.0, 6.0 * delta),
			lerp(camera.offset.y, (10 * float(Input.get_axis("up", "down"))) + -24.0 + positional_velocity.y / 24.0, 10.0 * delta)
			) 

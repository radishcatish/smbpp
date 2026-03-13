extends CharacterBody2D
class_name Mario
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var I: InputHelper = $InputHelper
var last_on_floor := 10
var last_off_floor := 10
var last_on_wall := 10
var last_wall_normal: int = 0

var dived_midair: bool = false
var kicked_midair: bool = false
var spun_midair: bool = false
enum PlayerState {GENERAL, KICK, DIVE, SPINJUMP}
var state := PlayerState.GENERAL
func _physics_process(_d):
	last_on_floor = 0 if is_on_floor() else last_on_floor + 1
	last_off_floor = 0 if not is_on_floor() else last_off_floor + 1
	last_on_wall = 0 if is_on_wall_only() else last_on_wall + 1
	last_wall_normal = get_wall_normal().x as int if is_on_wall_only() else last_wall_normal
	dived_midair = false if is_on_floor() else dived_midair
	kicked_midair = false if is_on_floor() else kicked_midair
	spun_midair = false if is_on_floor() else spun_midair
	
	if I.last_z_press < 6:
		I.last_z_press = 6
		if last_on_floor < 5:
			last_on_floor = 6
			velocity.y = -400 - abs(velocity.x) / 10
			sprite.snd_jump.play()
			state = PlayerState.GENERAL if state == PlayerState.DIVE else state
		elif last_on_wall < 5:
			last_on_wall = 6
			velocity.x = last_wall_normal * 300
			velocity.y = -400
			sprite.snd_kick.play()
	
	if I.last_x_press == 1:
		if I.d.y != 0 and not spun_midair:
			spun_midair = true
			sprite.snd_spinjump.play()
			state = PlayerState.SPINJUMP
			sprite.play("spin")
			velocity.y = -350 if is_on_floor() else -200
		elif (I.d.x == 0 or is_on_floor()) and not kicked_midair:
			kicked_midair = true
			sprite.snd_kick.play()
			state = PlayerState.KICK
			sprite.play("kick")
			velocity.y = -300
		elif not is_on_floor() and not dived_midair:
			dived_midair = true
			sprite.snd_whoosh.play()
			state = PlayerState.DIVE
			sprite.play("dive")
			velocity.y = -200
			velocity.x = 350 * sprite.dir
			
	velocity.y += 20 - int(I.z_pressed and velocity.y < 0) * 5
	if not state == PlayerState.DIVE:
		var target_speed = I.d.x * 300 if I.shift_pressed else I.d.x * 150
		if abs(velocity.x) < abs(target_speed) or sign(velocity.x) != sign(target_speed):
			velocity.x = move_toward(velocity.x, target_speed, 10 + int(sign(velocity.x) != sign(target_speed) and is_on_floor()) * 20)
		velocity.y = clamp(velocity.y, -INF, 100) if is_on_wall_only() else velocity.y
		velocity.y = -100.0 if I.last_z_release == 1 and velocity.y < -100.0 else velocity.y
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, 10)
			
	move_and_slide()

	if is_on_wall_only() and state == PlayerState.DIVE:
		state = PlayerState.GENERAL
	if is_on_floor() and state == PlayerState.SPINJUMP:
		state = PlayerState.GENERAL

func sprite_anim_finish() -> void:
	match sprite.animation:
		"kick":
			state = PlayerState.GENERAL

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
enum PlayerState {GENERAL, KICK, DIVE, SPINJUMP, TWIRL, GROUNDPOUND, SLIDEKICK}
var state := PlayerState.GENERAL
func _physics_process(_d):
	last_on_floor = 0 if is_on_floor() else last_on_floor + 1
	last_off_floor = 0 if not is_on_floor() else last_off_floor + 1
	last_on_wall = 0 if is_on_wall_only() else last_on_wall + 1
	last_wall_normal = get_wall_normal().x as int if is_on_wall_only() else last_wall_normal
	if I.last_z_press < 6:
		I.last_z_press = 6
		if last_on_floor < 5:
			last_on_floor = 6
			velocity.y = -400 - abs(velocity.x) / 200
			sprite.snd_jump.play()
		elif last_on_wall < 5:
			last_on_wall = 6
			velocity.x = last_wall_normal * 300
			velocity.y = -400 - abs(velocity.x) / 200
			sprite.snd_kick.play()

	if I.last_x_press == 1:
		if I.d.y == -1:
			if is_on_floor():
				sprite.snd_spinjump.play()
				state = PlayerState.SPINJUMP
				sprite.play("spinjump")
				velocity.y = -300
			else:
				print("Ground Pound")
				sprite.snd_bump.play()
		elif I.d.x == 0 or is_on_floor():
			sprite.snd_kick.play()
			state = PlayerState.KICK
			sprite.play("kick")
			velocity.y = -300
		elif not is_on_floor():
			sprite.snd_whoosh.play()
			state = PlayerState.DIVE
			sprite.play("dive")
			velocity.y = -200
			velocity.x = 350 * sprite.dir
			
	var target_speed = I.d.x * 300 if I.shift_pressed else I.d.x * 150
	if abs(velocity.x) < abs(target_speed) or sign(velocity.x) != sign(target_speed):
		velocity.x = move_toward(velocity.x, target_speed, 10 + int(sign(velocity.x) != sign(target_speed) and is_on_floor()) * 20)
	velocity.y = clamp(velocity.y, -INF, 100) if is_on_wall_only() else velocity.y
	velocity.y = -100.0 if I.last_z_release == 1 and velocity.y < -100.0 else velocity.y
	velocity.y += 20 - int(I.z_pressed and velocity.y < 0) * 5
	move_and_slide()

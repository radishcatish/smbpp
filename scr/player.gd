extends CharacterBody2D
class_name player
#Nodes
#region Nodes
@onready var sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
@onready var tmr_coyotetime: Timer = $tmr/coyotetime
@onready var tmr_jumpqueue: Timer = $tmr/jumpqueue
@onready var tmr_wallcoyotetime: Timer = $tmr/wallcoyotetime
@onready var snd_jump: AudioStreamPlayer = $snd/jump
@onready var snd_skid: AudioStreamPlayer = $snd/skid
@onready var snd_bump: AudioStreamPlayer = $snd/bump
@onready var snd_kick: AudioStreamPlayer = $snd/kick

@onready var area_2d: Area2D = $Area2D
@onready var snd_coin: AudioStreamPlayer = $snd/coin
@onready var tmr_stuntime: Timer = $tmr/stuntime
@onready var snd_hurt: AudioStreamPlayer = $snd/hurt
@onready var tmr_iframes: Timer = $tmr/iframes

#endregion

#Variables

var pause := false
var direction = 1 
var friction := .99
var can_jump := true
var health := 3
var last_not_on_floor := false
var just_now_not_on_floor := false
var last_on_floor := false
var just_now_on_floor := false
var ceiling_hit_velocity := 0.0
var floor_angle: float = 0
var just_now_not_on_wall_only := false
var last_not_on_wall_only := false
var last_walljump_direction: int = 0
var coins_until_hp := 0
var y_inertia := 0.0
var directionnotzero = 1
var last_pos := Vector2.ZERO
var positional_velocity := Vector2.ZERO



enum PlayerStates {none, idle, walk, jump, fall, skid, hurt, wallslide, crouch, wavedash}
var state := PlayerStates.none

const JUMP_HEIGHT: float = -250
const RUN_SPEED := 160
const ACCEL := 8.0

func _process(delta):
	sprite.skew = (velocity.x / 720) * .9
	sprite.rotation = floor_angle / 2
	$temp.text = "\n [center]" + PlayerStates.find_key(state) + "[/center]"

	if direction == 1: sprite.flip_h = false
	if direction == -1: sprite.flip_h = true



	
	
	match state:
		PlayerStates.none:
			sprite.play(&"gangnam")

		PlayerStates.idle:
			sprite.play(&"idle")

		PlayerStates.walk:
			sprite.play(&"walk", self.velocity.x / 154)

		PlayerStates.jump:
			sprite.play(&"jump")
			
		PlayerStates.fall:
			sprite.play(&"fall")
			if velocity.y > -JUMP_HEIGHT:
				sprite.play(&"fastfall")
				
		PlayerStates.hurt:
			sprite.play(&"hurt")
			
		PlayerStates.crouch:
			sprite.play(&"crouch")
			
		PlayerStates.wallslide:
			sprite.play(&"wallsliding")
			
		PlayerStates.skid:
			sprite.play(&"skid")
			if not snd_skid.is_playing():
				snd_skid.play()
				
		PlayerStates.wavedash:
			sprite.play(&"wavedash")
			
	var flicker: bool = true
	if not tmr_iframes.is_stopped():
		flicker = bool(int(tmr_iframes.time_left * 100 ) % 2)
	else: 
		flicker = true
		
	if flicker:
		sprite.self_modulate = Color(1,1,1,1)
	else:
		sprite.self_modulate = Color(1,1,1,0.2)
	
	sprite.scale = Vector2(
		move_toward(sprite.scale.x, 1 , 3 * delta), 
		move_toward(sprite.scale.y, 1 , 3 * delta)
		)

	sprite.position = Vector2(
		velocity.x / 64,
		move_toward(sprite.position.y, .25, 1)
		)
		
	if not get_platform_velocity().length_squared():
		camera.offset = Vector2(
			lerp(camera.offset.x, get_real_velocity().x / 8.0, 8.0 * delta),
			lerp(camera.offset.y, clamp(-32.0 + get_real_velocity().y / 8.0, -24.0, 64.0), 8.0 * delta)
			) 
	else:
		camera.offset = Vector2(
			lerp(camera.offset.x, get_real_velocity().x / 16.0, 8.0 * delta),
			lerp(camera.offset.y, -24.0 + get_real_velocity().x / 24.0, 10.0 * delta)
			) 
		
	
		
		
	for area in area_2d.get_overlapping_areas():

		if area.get_parent() is Coin and area.get_parent().state == 0:
			area.get_parent().state = 1
			global.coins += 1
			global.score += 3
			snd_coin.play()
			if coins_until_hp >= 5:
				health += 1
				coins_until_hp = 0

				global.hpcounter.scale = Vector2(1.1,1.1)
				get_tree().create_tween().tween_property(global.hpcounter, "scale", Vector2(1,1), 0.3).set_ease(Tween.EASE_OUT)
			if not health >= 3:
				coins_until_hp += 1
			else:
				coins_until_hp = clamp(coins_until_hp, 0, 4)

				
			
		if area.name == "hurtbox" and ((not state == PlayerStates.hurt) and tmr_iframes.is_stopped()):
			velocity.x =  int(sprite.scale.x) * -300
			health -= area.damage
			tmr_stuntime.start()
			sprite.play(&"hurt")
			state = PlayerStates.hurt
			velocity.y = -200
			sprite.skew = 0
			sprite.scale.y = 1
			sprite.position = Vector2.ZERO
			direction = 0
			snd_hurt.play()
			snd_jump.stop()
			global.hpcounter.scale = Vector2(.9,.9)
			get_tree().create_tween().tween_property(global.hpcounter, "scale", Vector2(1,1), 0.3).set_ease(Tween.EASE_OUT)
			

func _physics_process(_delta):
	
	if abs(velocity.x) < 30 and not direction:
		velocity.x = 0
	
	if is_on_floor():
		floor_angle =  get_floor_angle(up_direction) * sign(get_floor_normal().x)
	else:
		floor_angle = 0

		
	if last_pos != position:
		positional_velocity = last_pos - position
		last_pos = position
	floor_snap_length = 8 + positional_velocity.length()
	if not state in [PlayerStates.hurt, PlayerStates.wavedash]:
		direction = Input.get_axis("left", "right")
		
	if direction != 0:
		directionnotzero = direction
		
	if direction == 0 and not state == PlayerStates.wavedash: 
		friction = .8
	else: 
		friction = .99
	
		
	if tmr_stuntime.is_stopped():

#region single frame code filler

		if not is_on_wall_only() and last_not_on_wall_only == true:
			last_not_on_wall_only = is_on_wall_only()
			just_now_not_on_wall_only = true
			
			tmr_wallcoyotetime.stop()
			tmr_wallcoyotetime.start()
		else:
			just_now_not_on_wall_only = false
			last_not_on_wall_only = is_on_wall_only()
		
		if not is_on_floor() and last_not_on_floor == true:
			last_not_on_floor = is_on_floor()
			just_now_not_on_floor = true
		else:
			just_now_not_on_floor = false
			last_not_on_floor = is_on_floor()
		
		if is_on_floor() and last_on_floor == false:
			last_on_floor = is_on_floor()
			just_now_on_floor = false
		else:
			just_now_on_floor = true
			last_on_floor = is_on_floor()
#endregion
	
			
		if state == PlayerStates.wavedash and abs(velocity.x) < RUN_SPEED:
			state = PlayerStates.walk
			
		if is_on_floor():
			if direction:
				velocity.x += get_floor_normal().x * 10
			if abs(floor_angle) > .79:
				velocity.x += get_floor_normal().x * 30
			print(floor_angle)
			tmr_wallcoyotetime.stop()
			last_walljump_direction = 0
			can_jump = true
			
			if !just_now_on_floor and Input.is_action_pressed("down") and not state == PlayerStates.wavedash:
				direction = 0
				state = PlayerStates.wavedash
				velocity.x = (230 + y_inertia / 8) * directionnotzero
				friction = .99


			if abs(velocity.x) < 25 and direction == 0:
				state = PlayerStates.idle
			elif not state == PlayerStates.wavedash:
				state = PlayerStates.walk
				
			if ((direction == 1 and velocity.x < 0) or (direction == -1 and velocity.x > 0)) and abs(velocity.x) < 35:
					state = PlayerStates.skid
			print(velocity.x)
			if Input.is_action_pressed("down") and state == PlayerStates.idle or state == PlayerStates.crouch:
				state = PlayerStates.crouch
			if Input.is_action_just_pressed("down"):
				
				if state == PlayerStates.walk:
					direction = 0
					state = PlayerStates.wavedash
					velocity.x = 230 * directionnotzero
					friction = .99
					

		
		if (Input.is_action_just_pressed("Z") or not tmr_jumpqueue.is_stopped()) and can_jump: 
			jump()
		if not is_on_floor(): midair()
	else:
		velocity.y += 14
		velocity.x *= 0.9
		state = PlayerStates.hurt
		direction = 0
		

	if not abs(velocity.x) > RUN_SPEED:
		velocity.x = velocity.x + direction * (ACCEL)
	velocity.x *= friction

	
	velocity.y = clamp(velocity.y, -600, 500)
	move_and_slide()

func jump():

	can_jump = false
	if abs(-get_floor_normal().x) < 0.5:
		velocity.y = JUMP_HEIGHT + clamp(abs(velocity.x / 3) * -1, -100, 100) + (positional_velocity.y * -30)
	else:
		velocity.y = -get_floor_normal().y * (JUMP_HEIGHT + (positional_velocity.y * -30) )
		
		velocity.x = 1.5 * -get_floor_normal().x * (-200 + positional_velocity.y * 30)
	position.y -= 3
	state = PlayerStates.jump
	sprite.scale.y = 1.5
	snd_jump.play()
	snd_jump.pitch_scale = 1 + clamp(abs(velocity.x) / 1000, 0.0, 0.200)
	
	
func midair():
	y_inertia = velocity.y
	friction = .99
	
	if just_now_not_on_floor: tmr_coyotetime.start()
	if velocity.y < -50 and not state == PlayerStates.wallslide:
		state = PlayerStates.jump
	else:
		state = PlayerStates.fall
		
	velocity.y += 14 - (int(Input.is_action_pressed("Z")) * 3) + sign(velocity.y) 
	
	if (Input.is_action_just_released("Z") or not Input.is_action_pressed("Z")) and velocity.y < -100:
		velocity.y = -100
		
	if Input.is_action_just_pressed("Z"):
		tmr_jumpqueue.start()
		
	walljumpcode() 
	
	if Input.is_action_just_pressed("down") and velocity.y < 200:
		velocity.y = 200
	
	if not is_on_ceiling() and velocity.y < 0: 
		ceiling_hit_velocity = velocity.y 
		
	if is_on_ceiling_only():
		position.y += 2
		velocity.y -= ceiling_hit_velocity / 4
		sprite.scale.y = .9 - ((ceiling_hit_velocity * -1)) / 800
		sprite.scale.x = 1 + ((ceiling_hit_velocity * -1)) / 800
		sprite.position.y =  2 - (ceiling_hit_velocity) / 100
		snd_jump.stop()
		snd_bump.play()

func walljumpcode():
	
	var walljumpangle =  -int(Input.is_action_pressed("up"))
	if !pause or tmr_stuntime.is_stopped():
		if is_on_wall_only() and (get_wall_normal().x > 0 and not last_walljump_direction == 1 or get_wall_normal().x < 0 and not last_walljump_direction == -1) and direction != 0:

			state = PlayerStates.wallslide
			velocity.y = 50
		if (not tmr_wallcoyotetime.is_stopped()) or state == PlayerStates.wallslide:
			if Input.is_action_just_pressed("Z") or not tmr_jumpqueue.is_stopped():

				snd_kick.play()
				state = PlayerStates.jump
				tmr_jumpqueue.stop()
				sprite.scale.y = 1.35
				velocity.y = JUMP_HEIGHT + (walljumpangle * 30)
				
				if get_wall_normal().x > 0 and not last_walljump_direction == 1:
					last_walljump_direction = 1
					velocity.x = RUN_SPEED - walljumpangle * 30
				if get_wall_normal().x < 0 and not last_walljump_direction == -1:
					last_walljump_direction = -1
					velocity.x = -RUN_SPEED - walljumpangle * 30
				tmr_wallcoyotetime.stop()
# Timers
func coyotetimetimeout(): can_jump = false
func _on_stuntime_timeout(): tmr_iframes.start()

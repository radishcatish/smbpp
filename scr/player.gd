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
@onready var  tmr_iframes: Timer = $tmr/iframes

#endregion

#Variables

var pause := false
var direction = 1 
var walkSpeed := 90
var accelSpeed := 8.0
var friction := .99
var canJump := true
var health := 3
var last_not_on_floor := false
var just_now_not_on_floor := false
var last_on_floor := false
var just_now_on_floor := false
var beforeCeilingHitYVel := 0.0

var just_now_not_on_wall_only := false
var last_not_on_wall_only := false
var lastWalljumpDir: int = 0
var coinsuntilhp := 0
var storedYVel := 0.0
var directionnotzero = 1
var speedMod := 0.0
var last_pos := Vector2.ZERO
var positional_velocity := Vector2.ZERO
enum plrStates {none, idle, walk, jump, fall, skid, hurt, wallslide, crouch, wavedash}
var state := plrStates.none


func _process(delta):
	sprite.skew = (velocity.x / 720)
	$temp.text = "\n [center]" + plrStates.find_key(state) + "[/center]"

	if direction == 1: sprite.flip_h = false
	if direction == -1: sprite.flip_h = true



	
	
	match state:
		plrStates.none:
			sprite.play(&"gangnam")

		plrStates.idle:
			sprite.play(&"idle")

		plrStates.walk:
			sprite.play(&"walk", self.velocity.x / 154)

		plrStates.jump:
			sprite.play(&"jump")
			
		plrStates.fall:
			sprite.play(&"fall")
			if velocity.y > 250:
				sprite.play(&"fastfall")
				
		plrStates.hurt:
			sprite.play(&"hurt")
			
		plrStates.crouch:
			sprite.play(&"crouch")
			
		plrStates.wallslide:
			sprite.play(&"wallsliding")
			
		plrStates.skid:
			sprite.play(&"skid")
			if not snd_skid.is_playing():
				snd_skid.play()
				
		plrStates.wavedash:
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
			if coinsuntilhp >= 5:
				health += 1
				coinsuntilhp = 0

				global.hpcounter.scale = Vector2(1.1,1.1)
				get_tree().create_tween().tween_property(global.hpcounter, "scale", Vector2(1,1), 0.3).set_ease(Tween.EASE_OUT)
			if not health >= 3:
				coinsuntilhp += 1
			else:
				coinsuntilhp = clamp(coinsuntilhp, 0, 4)

				
			
		if area.name == "hurtbox" and ((not state == plrStates.hurt) and tmr_iframes.is_stopped()):
			velocity.x =  int(sprite.scale.x) * -300
			health -= area.damage
			tmr_stuntime.start()
			sprite.play(&"hurt")
			state = plrStates.hurt
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

	if last_pos != position:
		positional_velocity = last_pos - position
		last_pos = position
		
	if not state in [plrStates.hurt, plrStates.wavedash]:
		direction = Input.get_axis("left", "right")
		
	if direction != 0:
		directionnotzero = direction
		
	if direction == 0 and not state == plrStates.wavedash: 
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
		

		if not Input.is_action_pressed("C"): 
			walkSpeed = 160
		else:
			walkSpeed = 90
			
		if state == plrStates.wavedash and abs(velocity.x) < walkSpeed:
			state = plrStates.walk
			
		if is_on_floor():
			velocity.x += get_floor_normal().x * 5
			tmr_wallcoyotetime.stop()
			lastWalljumpDir = 0
			canJump = true
			
			if !just_now_on_floor and Input.is_action_pressed("down") and not state == plrStates.wavedash:
				direction = 0
				state = plrStates.wavedash
				velocity.x = (230 + storedYVel / 8) * directionnotzero
				friction = .99


			if abs(velocity.x) < 25 and direction == 0:
				state = plrStates.idle
			elif not state == plrStates.wavedash:
				state = plrStates.walk
				
			if (direction == 1 and velocity.x < 0) or (direction == -1 and velocity.x > 0):
				state = plrStates.skid

			if Input.is_action_pressed("down") and state == plrStates.idle or state == plrStates.crouch:
				state = plrStates.crouch
			if Input.is_action_just_pressed("down"):
				
				if state == plrStates.walk:
					direction = 0
					state = plrStates.wavedash
					velocity.x = 230 * directionnotzero
					friction = .99
					

		
		if (Input.is_action_just_pressed("Z") or not tmr_jumpqueue.is_stopped()) and canJump: 
			jump()
		if not is_on_floor(): midair()
	else:
		velocity.y += 14
		velocity.x *= 0.9
		state = plrStates.hurt
		direction = 0
		

	if not abs(velocity.x) > walkSpeed:
		velocity.x = velocity.x + direction * (accelSpeed)
	velocity.x *= friction

	
	velocity.y = clamp(velocity.y, -600, 500)
	move_and_slide()

func jump():

	canJump = false
	if abs(-get_floor_normal().x) < 0.1:
		velocity.y = -250 + clamp(abs(velocity.x / 3) * -1, -100, 100) + (positional_velocity.y * -30)
	else:
		velocity.y = -get_floor_normal().y * (-250 + (positional_velocity.y * -30) )
		
		velocity.x = -get_floor_normal().x * (-250 + (positional_velocity.x * 30) + positional_velocity.y * 30)
	position.y -= 3
	state = plrStates.jump
	sprite.scale.y = 1.5
	snd_jump.play()
	snd_jump.pitch_scale = 1 + clamp(abs(velocity.x) / 1000, 0.0, 0.200)
	
	
func midair():
	storedYVel = velocity.y
	friction = .99
	
	if just_now_not_on_floor: tmr_coyotetime.start()
	if velocity.y < -50 and not state == plrStates.wallslide:
		state = plrStates.jump
	else:
		state = plrStates.fall
		
	velocity.y += 14 - (int(Input.is_action_pressed("Z")) * 3) + sign(velocity.y) 
	
	if (Input.is_action_just_released("Z") or not Input.is_action_pressed("Z")) and velocity.y < -100:
		velocity.y = -100
		
	if Input.is_action_just_pressed("Z"):
		tmr_jumpqueue.start()
		
	walljumpcode() 
	
	if Input.is_action_just_pressed("down") and velocity.y < 200:
		velocity.y = 200
	
	if not is_on_ceiling() and velocity.y < 0: 
		beforeCeilingHitYVel = velocity.y 
		
	if is_on_ceiling_only():
		position.y += 2
		velocity.y -= beforeCeilingHitYVel / 4
		sprite.scale.y = .9 - ((beforeCeilingHitYVel * -1)) / 800
		sprite.scale.x = 1 + ((beforeCeilingHitYVel * -1)) / 800
		sprite.position.y =  2 - (beforeCeilingHitYVel) / 100
		snd_jump.stop()
		snd_bump.play()

func walljumpcode():
	if !pause or tmr_stuntime.is_stopped():
		if is_on_wall_only() and (get_wall_normal().x > 0 and not lastWalljumpDir == 1 or get_wall_normal().x < 0 and not lastWalljumpDir == -1) and direction != 0:

			state = plrStates.wallslide

		if (not tmr_wallcoyotetime.is_stopped()) or state == plrStates.wallslide:
			if Input.is_action_just_pressed("Z") or not tmr_jumpqueue.is_stopped():

				snd_kick.play()
				state = plrStates.jump
				tmr_jumpqueue.stop()
				sprite.scale.y = 1.35
				velocity.y = -300
				
				if get_wall_normal().x > 0 and not lastWalljumpDir == 1:
					lastWalljumpDir = 1
					velocity.x = walkSpeed 
				if get_wall_normal().x < 0 and not lastWalljumpDir == -1:
					lastWalljumpDir = -1
					velocity.x = -walkSpeed
				tmr_wallcoyotetime.stop()
# Timers
func coyotetimetimeout(): canJump = false
func _on_stuntime_timeout(): tmr_iframes.start()

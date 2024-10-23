extends CharacterBody2D


@onready var sprite: AnimatedSprite2D = $sprite

@onready var collision: CollisionShape2D = $collision
@onready var hitbox: Area2D = $hitbox


@onready var tmr_iframes:        Timer = $tmr/iframes
@onready var tmr_stuntime:       Timer = $tmr/stuntime

@onready var snd_jump: AudioStreamPlayer = $snd/jump
@onready var snd_bump: AudioStreamPlayer = $snd/bump
@onready var snd_hurt: AudioStreamPlayer = $snd/hurt

#Variables

var pause := false
@export var direction = 0

var can_jump := false
var health := 3
var ceiling_hit_velocity := 0.0
var floor_angle: float = 0
var y_inertia := 0.0
var directionnotzero = 1
var last_pos := Vector2.ZERO
var positional_velocity := Vector2.ZERO
var need_jump: bool = false
var hold_jump: bool = false
@export var locked: bool = false
 
@onready var mario = get_tree().get_first_node_in_group("Player")
@onready var mario_pos_diff



enum PlayerState {NONE, IDLE, WALK, JUMP, HURT}
#var cock: PlayerState
@export var state := PlayerState.NONE
	#get:
		#return cock
	#set(value):
		#if cock == PlayerState.KICK:
			#breakpoint # this will break when it changes from kick to anything else
		#cock = value
func _ready() -> void:

		
	if is_instance_valid(get_tree().get_first_node_in_group("Player")):
		mario = get_tree().get_first_node_in_group("Player")
		
	else:
		queue_free()
		
	if locked:
		state = PlayerState.NONE
		sprite.play(&"invisible")
		
	
const JUMP_HEIGHT: float = -250
const RUN_SPEED := 170
const ACCEL := 10.0
const FRICTION := .95

func _process(delta):
	if is_instance_valid(get_tree().get_first_node_in_group("Player")):
		mario = get_tree().get_first_node_in_group("Player")
	else:
		return
	sprite.skew = (velocity.x / 720) * .9
	


	if direction == 1: sprite.flip_h = false
	if direction == -1: sprite.flip_h = true

	match state:
		PlayerState.NONE:
			sprite.play(&"invisible")

			
		PlayerState.IDLE:
			sprite.play(&"idle")
			sprite.rotation = floor_angle / 4
			
		PlayerState.WALK:
			sprite.speed_scale = 1
			sprite.play(&"walk", self.velocity.x / 154)
			sprite.rotation = floor_angle / 2
			
		PlayerState.JUMP:
			sprite.play(&"jump")
		
				
		PlayerState.HURT:
			sprite.play(&"hurt")
		

			
			
			
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
		

	

	
func _physics_process(_delta):
	if not mario:
		return
	mario_pos_diff = position - mario.position
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
	if direction != 0: directionnotzero = direction
	
	if tmr_stuntime.is_stopped():

		for area in hitbox.get_overlapping_areas():
			interactions(area)
			
		if is_on_floor():
			if direction:
				velocity.x += get_floor_normal().x * 10
			if abs(floor_angle) > .79:
				velocity.x += get_floor_normal().x * 30

			can_jump = true

					
			if abs(velocity.x) < 25 and direction == 0:
				state = PlayerState.IDLE
			else:
				state = PlayerState.WALK
			
			if ((direction == 1 and velocity.x < 0) or (direction == -1 and velocity.x > 0)) and abs(velocity.x) > 45:
					velocity.x *= 0.998
			
	
		if need_jump and is_on_floor(): 
			jump()
		if not is_on_floor() and !locked: midair()
	else:
		velocity.y += 14
		velocity.x *= 0.9
		state = PlayerState.HURT
		direction = 0
		

	if Input.is_action_just_pressed("Z") or (mario_pos_diff.y > 1 and not mario.velocity.y > 0):
		need_jump = true
	else:

		need_jump = false


	

	if abs(mario_pos_diff.x) > 25:
		if mario_pos_diff.x < 0:
			direction = 1
		elif mario_pos_diff.x > 0:
			direction = -1
	else:
		direction = 0
			
			
	if not abs(velocity.x) > RUN_SPEED:
		velocity.x = velocity.x + direction * (ACCEL)
		
	
	velocity.x *= FRICTION
	

	if !locked:
		move_and_slide()

func jump():
	can_jump = false
	if abs(-get_floor_normal().x) < 0.5:
		velocity.y = JUMP_HEIGHT - 30
	else:
		velocity.y = -get_floor_normal().y * (JUMP_HEIGHT + (positional_velocity.y * -30) )
		
		velocity.x = 1.5 * -get_floor_normal().x * (-200 + positional_velocity.y * 30)
	position.y -= 3
	state = PlayerState.JUMP
	sprite.scale.y = 1.5
	#snd_jump.play()
	snd_jump.pitch_scale = 1 + clamp(abs(velocity.x) / 1000, 0.0, 0.200)

func midair():
	y_inertia = velocity.y
	
	state = PlayerState.JUMP

	velocity.y += 11
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


func interactions(area):

		
	if area is Hurtbox and ((not state == PlayerState.HURT) and tmr_iframes.is_stopped()):
		velocity.x =  directionnotzero * -300
		health -= area.get_owner().DAMAGE
		tmr_stuntime.start()
		sprite.play(&"hurt")
		state = PlayerState.HURT
		velocity.y = -200
		sprite.skew = 0
		sprite.scale.y = 1
		sprite.position = Vector2.ZERO
		direction = 0
		snd_hurt.play()
		snd_jump.stop()

# Timers
func coyotetimetimeout(): 
	can_jump = false
func _on_stuntime_timeout(): 
	tmr_iframes.start()

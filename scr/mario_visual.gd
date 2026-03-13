extends AnimatedSprite2D
@onready var mario: CharacterBody2D = $".."
@onready var input_helper: Node = $"../InputHelper"
@onready var snd_bump: AudioStreamPlayer = $Bump
@onready var snd_hurt: AudioStreamPlayer = $Hurt
@onready var snd_jump: AudioStreamPlayer = $Jump
@onready var snd_kick: AudioStreamPlayer = $Kick
@onready var snd_skid: AudioStreamPlayer = $Skid
@onready var snd_spinjump: AudioStreamPlayer = $Spinjump
@onready var snd_whoosh: AudioStreamPlayer = $Whoosh

var dir: int = 1
func _physics_process(_d):
	dir = input_helper.d.x if input_helper.d.x != 0 else dir
	flip_h = false if dir == 1 else true
	rotation = 0
	if mario.is_on_floor():
		if abs(mario.velocity.x) >= 30:
			if sign(mario.velocity.x) != dir:
				play("skid")
				if not snd_skid.playing:
					snd_skid.play()
			else:
				play("walk", abs(mario.velocity.x) / 100)
		else:
			play("idle")
	else:
		if mario.state == mario.PlayerState.GENERAL:
			if not mario.is_on_wall_only():
				play("midair")
				var t = clamp((mario.velocity.y + 100.0) / 500.0, 0.0, 1.0)
				frame = int(t * 3)
			else:
				play("onwall")

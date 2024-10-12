extends CanvasLayer
@onready var static_text: RichTextLabel = $Static
@onready var coins_counter: RichTextLabel = $CoinsCounter
@onready var score_counter: RichTextLabel = $ScoreCounter
@onready var hpcounter: Control = $hpcounter
@onready var hpcircle: AnimatedSprite2D = $hpcounter/hpcircle
@onready var coinhpcount: AnimatedSprite2D = $hpcounter/coinhpcount
@onready var bg: Sprite2D = $hpcounter/bg
@onready var text: Sprite2D = $hpcounter/text
@onready var mario = get_tree().get_first_node_in_group("Player")
var marioexists: bool = true

func _ready() -> void:
	if is_instance_valid(get_tree().get_first_node_in_group("Player")):
		mario = get_tree().get_first_node_in_group("Player")
	else:
		visible = false
		marioexists = false
var coins: int = 0
var score: int = 0
var healthbefore: int
func _process(_delta: float) -> void:
	if marioexists == true:
		coins_counter.text = " %06d" % coins
		score_counter.text = " %07d" % score
		hpcircle.play(str(mario.health)) 
		if mario.coins_until_hp != 0:
			coinhpcount.play(str(mario.coins_until_hp))
			
		if mario.health == 3:
			coinhpcount.play("1")
			
		if healthbefore != mario.health:
			print (healthbefore - mario.health)
		
		healthbefore = mario.health
	
	
	

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



var coins: int = 0
var score: int = 0
var healthbefore: int
func _process(_delta: float) -> void:
	coins_counter.text = " %06d" % coins
	score_counter.text = " %07d" % score
	hpcircle.play(str(mario.health)) 
	if mario.coinsuntilhp != 0:
		coinhpcount.play(str(mario.coinsuntilhp))
		
	if mario.health == 3:
		coinhpcount.play("1")
		
	if healthbefore != mario.health:
		print (healthbefore - mario.health)
	
	healthbefore = mario.health
	
	
	

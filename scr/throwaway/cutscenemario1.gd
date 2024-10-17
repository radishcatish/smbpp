extends AnimatedSprite2D
@onready var mario: player = $"../level/Mario"
@onready var polygon_2d: Polygon2D = $"../level/basetilemap/Polygon2D"

func _physics_process(_delta):

	if frame > 1:
		mario.locked = false
		queue_free()
		mario.jump()

extends Node2D
var mario
@onready var block: Sprite2D = $block

func _ready() -> void:
	if is_instance_valid(get_tree().get_first_node_in_group("Player")):
		mario = get_tree().get_first_node_in_group("Player")
	else:
		self.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	block.position = (mario.camera.offset + mario.position) / 6

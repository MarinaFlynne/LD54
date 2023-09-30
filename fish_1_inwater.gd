extends AnimatedSprite2D

@export var speed = 10
var fish_name = "fish_1"
@export var physics_version: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(fish_speed):
	speed = fish_speed
	linear_velocity = Vector2(speed, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

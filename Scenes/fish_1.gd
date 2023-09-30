extends RigidBody2D

var default_gravity_scale: float
@export var swim_speed: float
# direction that the fish swim. either -1 (left) or 1 (right)
@export var direction: int = 1

@export var mouth_pos: NodePath

signal caught(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	default_gravity_scale = gravity_scale
	disable_boat_physics()
	
	
func init(speed, dir):
	swim_speed = speed
	direction = dir
	if direction == 1:
		flip()

func flip():
	$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
	$CollisionShape2D.position.x *= -1
	$CollisionShape2D2.position.x *= -1
	$MouthArea.position.x *= -1

func disable_boat_physics():
	gravity_scale = 0
	set_collision_layer_value(5, false)

func disable_swim_physics():
	linear_velocity = Vector2.ZERO

func rotate_towards():
	pass

func enable_swim_physics():
	gravity_scale = 0
	set_collision_layer_value(5, false)
	linear_velocity = Vector2(swim_speed * direction, 0)
	linear_damp = 0
	
func enable_in_boat_physics():
	gravity_scale = default_gravity_scale
	set_collision_layer_value(5, true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_mouth_area_body_entered(body):
	caught.emit(self)
	pass # Replace with function body.

func launch():
	linear_velocity = Vector2(20, -500)
	
func get_mouth():
	return get_node(mouth_pos)

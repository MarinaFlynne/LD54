extends RigidBody2D

var default_gravity_scale: float
@export var swim_speed: float
# direction that the fish swim. either -1 (left) or 1 (right)
@export var direction: int = 1

@export var mouth_pos: NodePath
# list where each item represents a rect in the minigame circle. first value is size, second is rotation in degrees
@export var rects_list: Array[Array] = [[.8, 0], [1, 100], [1.2, 200]]
# speed of the catching minigame arrow
@export var game_speed: int = 200

@export var scene = "res://Scenes/fish_1.tscn"

var physics = false
var drop_game_active: bool = false
var drop_game_move_speed = 60
var drop_game_length = 1.5 # length of the game in secs

signal caught(body)
signal drop_game_end()

# Called when the node enters the scene tree for the first time.
func _ready():
	default_gravity_scale = gravity_scale
#	disable_boat_physics()

func enable_placement_physics():
	# TODO
	pass
	
func init(speed, dir):
	swim_speed = speed
	direction = dir
	if direction == 1:
		flip()

func flip():
	$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
	$CollisionShape2D.position.x *= -1
	$CollisionShape2D2.position.x *= -1
	$MouthArea/CollisionShape2D.position.x *= -1
	$MouthPos.position.x *= -1

func disable_boat_physics():
	gravity_scale = 0
	set_collision_layer_value(5, false)
	set_collision_mask_value(7, false)
	set_collision_mask_value(5, false)

func disable_swim_physics():
	linear_velocity = Vector2.ZERO

func rotate_towards():
	pass

func enable_swim_physics():
	gravity_scale = 0
	set_collision_layer_value(5, false)
	set_collision_mask_value(7, false)
	set_collision_mask_value(5, false)
	linear_velocity = Vector2(swim_speed * direction, 0)
	linear_damp = 0
	
func start_drop_game():
	gravity_scale = 0
	drop_game_active = true
	set_collision_mask_value(9, true)
	set_collision_mask_value(5, true)
	await get_tree().create_timer(drop_game_length).timeout
	physics = true
	end_drop_game()

func end_drop_game():
	drop_game_end.emit()
	drop_game_active = false
	set_collision_mask_value(9, false)
	enable_in_boat_physics()

func enable_in_boat_physics():
	gravity_scale = 1
	set_collision_layer_value(5, true)
	set_collision_mask_value(7, true)
	set_collision_mask_value(5, true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if drop_game_active:
		if Input.is_action_pressed("drop_game_left"):
			linear_velocity = Vector2(-drop_game_move_speed, 0)
		elif Input.is_action_pressed("drop_game_right"):
			linear_velocity = Vector2(drop_game_move_speed, 0)
		else:
			linear_velocity = Vector2.ZERO

func _on_mouth_area_body_entered(body):
	caught.emit(self)
	pass # Replace with function body.

func launch():
	linear_velocity = Vector2(0, -500)
	
func get_mouth():
	return get_node(mouth_pos)

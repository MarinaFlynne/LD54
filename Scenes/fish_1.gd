extends RigidBody2D

var default_gravity_scale: float
var swim_speed: float
# direction that the fish swim. either -1 (left) or 1 (right)
var direction: int = 1
var rotate_up: bool
var rotation_speed = 100
# list where each item represents a rect in the minigame circle. first value is size, second is rotation in degrees
@export var rects_list: Array[Array] = [[.8, 0], [1, 100], [1.2, 200]]
# speed of the catching minigame arrow
@export var game_speed: int = 200
@export var max_move_speed: int = 80
@export var min_move_speed: int = 30
@export var max_spawn_range: float = 1
@export var min_spawn_range: float = 0
@export var spawn_chance: float = 1 # between 0 and 1. percentage chance that the fish will spawn
@export var catch_fill_percent = 20
@export var fish_name: String
var rod_2_gravity_scale = 0.4


@export var scene = "res://Scenes/fish_1.tscn"

var physics = false
var drop_game_active: bool = false
var drop_game_move_speed = 60
var drop_game_length = 2.5 # length of the game in secs

signal caught(body)
signal drop_game_end()

# Called when the node enters the scene tree for the first time.
func _ready():
	default_gravity_scale = gravity_scale
#	disable_boat_physics()
	$Hologram.hide()

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
	$Hologram.flip_h = not $Hologram.flip_h
	for child in get_children():
		if child != $AnimatedSprite2D and child != $Hologram:
			child.position.x *=-1
	$MouthArea/CollisionShape2D.position.x *=-1
#	$CollisionShape2D.position.x *= -1
#	$CollisionShape2D2.position.x *= -1
#	$MouthArea/CollisionShape2D.position.x *= -1
#	$MouthPos.position.x *= -1

func disable_boat_physics():
	gravity_scale = 0
	set_collision_layer_value(5, false)
	set_collision_mask_value(7, false)
	set_collision_mask_value(5, false)

func disable_swim_physics():
	linear_velocity = Vector2.ZERO

func enable_swim_physics():
	gravity_scale = 0
	set_collision_layer_value(5, false)
	set_collision_mask_value(7, false)
	set_collision_mask_value(5, false)
	linear_velocity = Vector2(swim_speed * direction, 0)
	linear_damp = 0
	
func start_drop_game():
	
#	AudioManager.stop_playing("res://SFX/rod_reeling.wav")
	gravity_scale = 0
	$Hologram.show()
	drop_game_active = true
	set_collision_mask_value(9, true)
	set_collision_mask_value(5, true)
	await get_tree().create_timer(drop_game_length).timeout
	physics = true
	end_drop_game()

func end_drop_game():
	$Hologram.hide()
	drop_game_end.emit()
	drop_game_active = false
	set_collision_mask_value(9, false)
	enable_in_boat_physics()

func enable_in_boat_physics():
	if GameData.rod_selected == 2:
		gravity_scale = rod_2_gravity_scale
	else:
		gravity_scale = 1
	if fish_name == "Squid":
		$AnimatedSprite2D.stop()
#	gravity_scale = 1
	set_collision_layer_value(5, true)
	set_collision_mask_value(7, true)
	set_collision_mask_value(5, true)
	if GameData.rod_selected == 2:
		await get_tree().create_timer(5).timeout
		gravity_scale = 1
	
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
	rotate_up = true
#	AudioManager.play("res://SFX/rod_reeling.wav")
	
func get_mouth():
	return $MouthPos
	
func set_anim_speed(speed):
	$AnimatedSprite2D.speed_scale = speed

func stop_anim():
	$AnimatedSprite2D.stop()

func disable_catching():
	$MouthArea.set_collision_layer_value(6, false)
	$MouthArea.set_collision_mask_value(4, false)

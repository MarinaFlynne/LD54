extends CharacterBody2D

signal entered_water

@export var max_throw_velocity = Vector2(-200, -400) # Adjust as needed

@export var default_gravity_scale: float = 1
@export var underwater_gravity_scale: float = 0.1
@export var enter_water_velocity_y: float = 30
@export var enter_water_velocity_x_scale: float = 0.1
@export var drag_coefficient = 0.000 # Adjust as needed
@export var drag_coefficient_x = 0.5 # Adjust as needed

@export var nudge_speed = 40
@export var nudge_speed2 = 80
@export var pull_velocity = 200
@export var AttachPoint: NodePath


var gravity_scale: int = default_gravity_scale
var in_water: bool = false
var is_thrown: bool = false
var gravity_on: bool = false
var is_hooked: bool = false
var is_attached: bool = false
var in_catch_mode = true
var attached_to
var throw_enabled: bool = true

# to store previous velocity for pulling
var previous_velocity = 40
@export var previous_velocity_rod1 = 40
@export var previous_velocity_rod2 = 80
@export var previous_velocity_rod3 = 40
var returning_to_prev_velocity: bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	if GameData.rod_selected == 0:
		previous_velocity = previous_velocity_rod1 
	elif GameData.rod_selected == 1:
		previous_velocity = previous_velocity_rod2
		nudge_speed = nudge_speed2
	elif GameData.rod_selected == 2:
		previous_velocity = previous_velocity_rod1
		
	pass

func _physics_process(delta):
	if is_thrown:
		# Apply drag force
		var drag_force = -velocity.normalized() * drag_coefficient * velocity.length()
		velocity += drag_force * delta
		
#		var motion = velocity * delta
	# adjust the gravity depending on whether or not in water
	if !gravity_on:
		gravity_scale = 0
	else:
		if in_water: 
			gravity_scale = underwater_gravity_scale
			var drag_force_x = -velocity.normalized().x * drag_coefficient_x * velocity.length()
			velocity.x += drag_force_x * delta
#			var drag_force_y = -velocity.normalized().y * drag_coefficient * velocity.length()
#			velocity.y += drag_force_y * delta
		else:
			gravity_scale = default_gravity_scale
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta 

	if returning_to_prev_velocity and velocity.y <= previous_velocity:
		velocity.y += 20
	elif returning_to_prev_velocity and velocity.y > previous_velocity:
		returning_to_prev_velocity = false

	# Nudge the hook left or right
	if Input.is_action_pressed("nudge_hook_left"):
		velocity.x = -1 * nudge_speed
	elif Input.is_action_pressed("nudge_hook_right"):
		velocity.x = 1 * nudge_speed
#	elif Input.is_action_pressed("nudge_hook_down"):
#		velocity.y += 1 * nudge_speed
#	if Input.is_action_just_pressed("pull_hook"):
#		var direction_of_rod: Vector2 = (get_node(AttachPoint).global_position - global_position).normalized()
#		velocity += pull_velocity * delta * direction_of_rod
#		AudioManager.play("res://SFX/rod_reeling.wav")
#	elif Input.is_action_just_pressed("reel_in") and not returning_to_prev_velocity:
#		previous_velocity = velocity.y
#		previous_velocity = 300
	if Input.is_action_just_pressed("reel_in"):
		AudioManager.play("res://SFX/rod_reeling.wav", -9)
	if Input.is_action_pressed("reel_in"):
		var direction_of_rod: Vector2 = (get_node(AttachPoint).global_position - global_position).normalized()
		velocity += pull_velocity * delta * direction_of_rod
	if Input.is_action_just_released("reel_in"):
		returning_to_prev_velocity = true
		
		pass
	if (not Input.is_action_pressed("reel_in")) or is_hooked or throw_enabled:
		AudioManager.stop_playing("res://SFX/rod_reeling.wav")
	move_and_slide()
	

func _on_water_collision_body_entered(body):
	in_water = true
#	is_thrown = false
	# reduce velocity when landing in water
	velocity.x *= enter_water_velocity_x_scale
	velocity.y = enter_water_velocity_y
	entered_water.emit()
	await get_tree().create_timer(0.2).timeout
	returning_to_prev_velocity = true


func _on_water_collider_body_exited(body):
	in_water = false
	if is_hooked:
		AudioManager.play("res://SFX/splash_from_water.wav", -10)

func throw(power):
	velocity = Vector2(max_throw_velocity.x * (power/100), max_throw_velocity.y * (power/100))
	gravity_on = true
	is_thrown = true
	
func attach(attachment):
	set_physics_process(false)
	attached_to = attachment
	is_attached = true
	is_hooked = true

func _process(delta):
	if is_attached:
		global_position = attached_to.global_position
		pass
	throw_enabled = get_parent().throw_enabled

func unattach():
	is_attached = false
	is_hooked = false
	gravity_on = false
	is_thrown = false
	get_node(AttachPoint).position = Vector2(-9.333 ,-2)
	global_position = get_node(AttachPoint).global_position 

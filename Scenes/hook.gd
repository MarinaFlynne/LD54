extends CharacterBody2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

var throw_velocity = Vector2(-200, -400) # Adjust as needed

@export var default_gravity_scale: float = 1
@export var underwater_gravity_scale: float = 0.05
@export var enter_water_velocity_scale: float = 0.1
@export var drag_coefficient = 0.01 # Adjust as needed

var gravity_scale: int = default_gravity_scale
var in_water: bool = false
var is_thrown: bool = false
var gravity_on: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
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
		else:
			gravity_scale = default_gravity_scale
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * gravity_scale * delta 

	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
#	var direction = Input.get_axis("ui_left", "ui_right")
#	if direction:
#		velocity.x = direction * SPEED
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_water_collision_body_entered(body):
	in_water = true
#	is_thrown = false
	# reduce velocity when landing in water
	velocity.x = 0
	velocity.y = 30


func _on_water_collider_body_exited(body):
	in_water = false


func _on_button_pressed():
	velocity = throw_velocity
	gravity_on = true
	is_thrown = true

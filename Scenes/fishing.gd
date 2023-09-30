extends Node2D

var rod_point
var hook_point
var throw_charging: bool = false # true iff the player is currently charging their throw power
var throw_enabled = true # true iff throwing the rod is currently enabled

@export var cloud_speed = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_fishing_line()
	move_clouds(delta)
	
	if throw_charging:
		if Input.is_action_pressed("throw_rod"):
			$ThrowProgress.value += 2
		else:
			throw_charging = false
			throw_enabled = false
			throw_rod($ThrowProgress.value)
	elif Input.is_action_just_pressed("throw_rod") and throw_enabled:
		throw_charging = true
	
		pass

func move_clouds(delta):
	var cloud1_pos = $Clouds/Cloud1.position.x
	var cloud2_pos = $Clouds/Cloud2.position.x
	
	if cloud2_pos >= 2304:
		$Clouds/Cloud2.position.x = -2301
	if cloud1_pos >= 2304:
		$Clouds/Cloud1.position.x = -2301
	$Clouds/Cloud1.position.x += cloud_speed * delta
	$Clouds/Cloud2.position.x += cloud_speed * delta
	

func throw_rod(power):
	$Hook.throw(power)
	$ThrowProgress.hide()

func update_fishing_line():
	rod_point = $FishingRod/AttachPoint.get_global_position()
	hook_point = $Hook.get_global_position()
	$FishingLine.set_point_position(0, rod_point)
	$FishingLine.set_point_position(1, hook_point)


func _on_reload_pressed():
	SceneManager.RestartScene()

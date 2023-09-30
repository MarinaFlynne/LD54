extends Node2D

var rod_point
var hook_point
var throw_charging: bool = false # true iff the player is currently charging their throw power
var throw_enabled = true # true iff throwing the rod is currently enabled

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_fishing_line()
	
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

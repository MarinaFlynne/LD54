extends Control

var cloud_speed = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_clouds(delta)
	

func move_clouds(delta):
	var cloud1_pos = $Clouds.position.x
	var cloud2_pos = $Clouds2.position.x
	
	if cloud2_pos >= 2304:
		$Clouds2.position.x = -2301
	if cloud1_pos >= 2304:
		$Clouds.position.x = -2301
	$Clouds.position.x += cloud_speed * delta
	$Clouds2.position.x += cloud_speed * delta

func _on_play_pressed():
	AudioManager.play("res://SFX/titlestart.wav", -8)
	print("play")
	SceneManager.SwitchScene("fishing")


func _on_blink_timer_timeout():
	if $"Press Space".visible:
		$"Press Space".hide()
	else:
		$"Press Space".show()

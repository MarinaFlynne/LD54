extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(8).timeout
	$AudioStreamPlayer/AnimationPlayer.play("Fade")
	await get_tree().create_timer(1).timeout
	if GameData.day == 2:
		SceneManager.SwitchScene("day_2_shop")
	elif GameData.day == 3:
		SceneManager.SwitchScene("day_3_shop")
	else:
		SceneManager.SwitchScene("game_end")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/AnimationPlayer.play("Fade")
	await get_tree().create_timer(4).timeout
	SceneManager.SwitchScene("main_menu", true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

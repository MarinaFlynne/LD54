extends Node2D

# rotation speed in degrees per frame
@export var rotation_speed = 10
# the percentage that the heart will fill each successful action
@export var heart_fill_percent = 20
# the percentage that the heart will deplete each unsuccessful action
@export var heart_deplete_percent = 20

# list where each item represents a rect in the circle. first value is size, second is length
@export var rects_list: Array[Array] = []

# false if arrow is not pointing towards a rect, true if it is
var entered = false
var game_on: bool = false

# false if the player has not made an input yet
var first_input_made = false

signal game_end(win: bool)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass


func init():
	$AnimationPlayer.play("Fade_in")
	$ProgressBar.value = 1
	$ArrowPivot.rotation = 0
	for rect in $Rects.get_children():
		rect.queue_free()
	for rect_info in rects_list:
		var x_scale = rect_info[0]
		var rotation_degs = rect_info[1]
		create_rect(x_scale, rotation_degs)
	game_on = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_on:
		$ArrowPivot.rotate(deg_to_rad(rotation_speed) * delta)
		
		if entered:
			if Input.is_action_just_pressed("letter_1"):
				entered = false
				first_input_made = true
				if $ProgressBar.value < 100:
					AudioManager.play("res://SFX/success.wav", -18)
					$ProgressBar.value += heart_fill_percent
				pass
			pass
		else:
			if Input.is_action_just_pressed("letter_1"):
				if first_input_made:
					$ProgressBar.value -= heart_deplete_percent
					AudioManager.play("res://SFX/fail.wav", -18)
				first_input_made = true

func create_rect(x_scale, rotation_degs):
	var rect = preload("res://Scenes/catch_rect.tscn")
	var rect_instance = rect.instantiate()
	$Rects.call_deferred("add_child", rect_instance)
	rect_instance.rotation_degs = rotation_degs
	rect_instance.x_scale = x_scale
	rect_instance.init()
	pass

#func _on_catch_rect_entered():
#	pass # Replace with function body.
#
#
#func _on_catch_rect_exited():
#	print("Exited")


func _on_arrow_collider_area_entered(area):
	entered = true

func _on_arrow_collider_area_exited(area):
	entered = false


func _on_progress_bar_value_changed(value):
	if $ProgressBar.value == 100:
		AudioManager.play("res://SFX/fish_CAUGHT.wav", -13)
		game_end.emit(true)
		
		game_on = false
		# play sound effect
		$AnimationPlayer.play_backwards("Fade_in")
	if $ProgressBar.value == 0:
		AudioManager.play("res://SFX/SlamFX.wav", -17)
		game_end.emit(false)
		game_on = false
		# play lose sound effect
		$AnimationPlayer.play_backwards("Fade_in")
	
		

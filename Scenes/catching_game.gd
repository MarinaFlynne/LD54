extends Node2D

# rotation speed in degrees per frame
@export var rotation_speed = 10
# the percentage that the heart will fill each successful action
@export var heart_fill_percent = 20
# the percentage that the heart will deplete each unsuccessful action
@export var heart_deplete_percent = 20
@export var rects_list: Array[Array] = []

# false if arrow is not pointing towards a rect, true if it is
var entered = false

# false if the player has not made an input yet
var first_input_made = false

signal game_win
signal game_lose

# Called when the node enters the scene tree for the first time.
func _ready():
	for rect_info in rects_list:
		var x_scale = rect_info[0]
		var rotation_degs = rect_info[1]
		create_rect(x_scale, rotation_degs)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ArrowPivot.rotate(deg_to_rad(rotation_speed) * delta)
	
	if entered:
		if Input.is_action_just_pressed("letter_1"):
			entered = false
			first_input_made = true
			if $ProgressBar.value < 100:
				$ProgressBar.value += heart_fill_percent
			pass
		pass
	else:
		if Input.is_action_just_pressed("letter_1"):
			if first_input_made:
				$ProgressBar.value -= heart_deplete_percent
			first_input_made = true

func create_rect(x_scale, rotation_degs):
	var rect = preload("res://Scenes/catch_rect.tscn")
	var rect_instance = rect.instantiate()
	$Rects.add_child(rect_instance)
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
		game_win.emit()
		# play sound effect
		queue_free()
	if $ProgressBar.value == 0:
		game_lose.emit()
		# play lose sound effect
		queue_free()
	
		

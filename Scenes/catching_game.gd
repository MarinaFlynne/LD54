extends Node2D

# rotation speed in degrees per frame
@export var rotation_speed = 10

@export var rects_list: Array[Array] = []

var entered = false

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
			if $ProgressBar.value < 100:
				$ProgressBar.value += 1
				print("filling")
			pass
		pass

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
	print("entered")
	entered = true

func _on_arrow_collider_area_exited(area):
	print("exited")
	entered = false

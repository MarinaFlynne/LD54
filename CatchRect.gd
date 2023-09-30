extends Node2D

# Starting rotation in degrees
@export var rotation_degs = 0

# Horizontal size in pixels
@export var x_scale = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# initializes the rect
func init():
#	$RectSprite.scale.x = x_scale
	scale.x = x_scale
	rotate(deg_to_rad(rotation_degs))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


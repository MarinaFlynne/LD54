extends Node

#var fish_list = {"Scissortail Damselfish": 2, "Minafish": 5, "Barred Conger": 1, "Squid": 4}
var fish_list: Dictionary
var money: int = 0
var points: int = 12000
var day = 1
var boat = 1
var rod = 0
@export var fish_list_worth: Dictionary

var boat1_avail = true
var boat2_avail = true
var rod1_avail = true
var rod2_avail = true

var rod_selected: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

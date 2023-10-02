extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var total = GameData.points
	$Label2.text = "Your total money earned was $" + str(total) + "\nThank you for playing!"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

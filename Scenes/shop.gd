extends Control



var mouse_on_boat1 = false
var mouse_on_boat2 = false
var mouse_on_rod1 = false
var mouse_on_rod2 = false

var boat1price = 200
var boat2price = 400
var rod1price = 250
var rod2price = 400

# Called when the node enters the scene tree for the first time.
func _ready():
	$CurrentMoney.text = "You have $" + str(GameData.money)
	
	if GameData.boat1_avail == false:
		$Boat1.hide()
	if GameData.boat2_avail == false:
		$Boat2.hide()
	
	$Boat1/Price.hide()
	$Boat2/Price.hide()
	$Rod1/Price.hide()
	$Rod2/Price.hide()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("mouseleft"):
		if mouse_on_boat1 and GameData.boat1_avail and GameData.money >= boat1price:
			$Boat1.hide()
			GameData.boat1_avail = false
			GameData.boat = 2
			purchased(boat1price)
		elif mouse_on_boat2 and GameData.boat2_avail and GameData.money >= boat2price:
			$Boat2.hide()
			GameData.boat2_avail = false
			GameData.boat = 3
			purchased(boat2price)
		elif mouse_on_rod1 and GameData.rod1_avail and GameData.money >= rod1price:
#			$Rod1.hide()
			GameData.rod1_avail = false
			$Rod1/Price.hide()
			$Rod1/Desc.show()
			GameData.rod_selected = 2
			$Rod1/Desc.text = "Slow Fish Fall\nSelected"
			$Rod2/Desc.text = "Heavier\nHook"
			purchased(rod1price)
		elif mouse_on_rod2 and GameData.rod2_avail and GameData.money >= rod2price:
#			$Rod2.hide()
			
			GameData.rod2_avail = false
			$Rod2/Price.hide()
			$Rod2/Desc.show()
			GameData.rod_selected = 1
			$Rod1/Desc.text = "Slow Fish Fall"
			$Rod2/Desc.text = "Heavier\nHook\nSelected"
			purchased(rod2price)
		elif mouse_on_rod1 and not GameData.rod1_avail:
			GameData.rod_selected = 2
			AudioManager.play("res://SFX/Coin.wav", -10)
			$Rod1/Desc.text = "Slow Fish Fall\nSelected"
			$Rod2/Desc.text = "Heavier\nHook"
		elif mouse_on_rod2 and not GameData.rod2_avail:
			GameData.rod_selected = 1
			AudioManager.play("res://SFX/Coin.wav", -10)
			$Rod1/Desc.text = "Slow Fish Fall"
			$Rod2/Desc.text = "Heavier\nHook\nSelected"

func purchased(amount: int):
	AudioManager.play("res://SFX/Coin.wav", -10)
	GameData.money -= amount
	$CurrentMoney.text = "You have $" + str(GameData.money)
	$Mermaid.play("purchase")
	await $Mermaid.animation_finished
	$Mermaid.play("default")

func _on_boat_1_area_mouse_entered():
	mouse_on_boat1 = true
	$Boat1/Price.show()

func _on_boat_1_area_mouse_exited():
	mouse_on_boat1 = false
	$Boat1/Price.hide()

func _on_boat_2_area_mouse_entered():
	mouse_on_boat2 = true
	$Boat2/Price.show()

func _on_boat_2_area_mouse_exited():
	mouse_on_boat2 = false
	$Boat2/Price.hide()

func _on_rod_2_area_mouse_entered():
	mouse_on_rod2 = true
	if GameData.rod2_avail:
		$Rod2/Price.show()
	else:
		$Rod2/Desc.show()


func _on_rod_2_area_mouse_exited():
	mouse_on_rod2 = false
	$Rod2/Price.hide()
	$Rod2/Desc.hide()

func _on_rod_1_area_mouse_entered():
	mouse_on_rod1 = true
	if GameData.rod1_avail:
		$Rod1/Price.show()
	else:
		$Rod1/Desc.show()
	
func _on_rod_1_area_mouse_exited():
	mouse_on_rod1 = false
	$Rod1/Price.hide()
	$Rod1/Desc.hide()




func _on_continue_pressed():
	AudioManager.play("res://SFX/titlestart.wav")
	SceneManager.SwitchScene("fishing")

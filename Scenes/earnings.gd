extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var fish_list = GameData.fish_list
	var fish_list_worth = GameData.fish_list_worth
	var day = GameData.day
	var fish_list_string = ""
	var totals_string = ""
	var dollarx_string = ""
	var final_total_amount_string = ""
	var total = 0
	
	$EarningsTitle.text = "Day " + str(day) + " Earnings:"
	
	await get_tree().create_timer(2).timeout
	
	
	for fish in fish_list:
		await get_tree().create_timer(0.5).timeout
		AudioManager.play("res://SFX/earningsappear.wav", -9)
		var count = fish_list[fish]
		var worth = fish_list_worth[fish]
		total += count * worth
		fish_list_string += fish + "\n"
		dollarx_string += "$" + str(worth) + " x\n"
		totals_string += str(count) + "\n"
		$FishList.text = fish_list_string
		$Totals.text = totals_string
		$DollarX.text = dollarx_string
		
	await get_tree().create_timer(0.5).timeout
	final_total_amount_string = "$" + str(total)
	$FinalTotalAmount.text = final_total_amount_string
	GameData.money += total
	AudioManager.play("res://SFX/Coin.wav", -10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

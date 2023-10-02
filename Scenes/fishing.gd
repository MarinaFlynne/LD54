extends Node2D

var rod_point
var hook_point
var throw_charging: bool = false # true iff the player is currently charging their throw power
var throw_enabled = true # true iff throwing the rod is currently enabled

# represents the current time since the fishing began, in intervals of 30s
var time = 0

var fishing_minigame_active = false

@export var MorningAnimPlayers: Array[NodePath]
@export var AfternoonAnimPlayers: Array[NodePath]
@export var AfternoonCloudPlayers: Array[NodePath]

@export var cloud_speed = 200
# controls the dampening for rigid body fish when they land in the water
@export var rigid_fish_water_dampen = 10

@export var fishes: Array[PackedScene]
@export var minigame: PackedScene

#@export var fish_max_speed = 80
#@export var fish_min_speed = 30

@export var fish_catch_delay: float = 0.3

@export var charge_speed: float = 2

@export var boat1: PackedScene
@export var boat2: PackedScene
@export var boat3: PackedScene

var camera_limit_top = 324
var camera_limit_bottom = 1428

signal pulling_back()
signal throwing()


# Called when the node enters the scene tree for the first time.
func _ready():
	$Hook.set_physics_process(false)
	$Clouds/Cloud1/Afternoon.modulate = Color(1,1,1,0)
	$Clouds/Cloud2/Afternoon.modulate = Color(1,1,1,0)
	$MinigameLayer/ThrowProgress.hide()
	$CameraMain.enabled = true
	
	$MusicPlayer.volume_db = -10
	
	var boat
	
	if GameData.boat == 1:
		boat = boat1.instantiate()
		pass
	if GameData.boat == 2:
		boat = boat2.instantiate()
		pass
	if GameData.boat == 3:
		boat = boat3.instantiate()
		pass
	add_child(boat)
	
	
#	$MinigameLayer/CatchingGame.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_fishing_line()
	move_clouds(delta)
	
	if Input.is_action_just_pressed("throw_rod") and throw_enabled:
		$MinigameLayer/ThrowProgress.value = 0
		$MinigameLayer/ThrowProgress.show()
		pulling_back.emit()
	
	if throw_charging:
		if Input.is_action_pressed("throw_rod"):
			$MinigameLayer/ThrowProgress.value += charge_speed
			throw_charging = true
		else:
			throw_charging = false
			throw_enabled = false
			throwing.emit()
			
	elif Input.is_action_just_pressed("throw_rod") and throw_enabled:
		throw_charging = true

	
		pass
	$CameraMain.position.y = $Hook.position.y
	$CameraMain.position.y = clamp($CameraMain.position.y, camera_limit_top, camera_limit_bottom)

func move_clouds(delta):
	var cloud1_pos = $Clouds/Cloud1.position.x
	var cloud2_pos = $Clouds/Cloud2.position.x
	
	if cloud2_pos >= 2304:
		$Clouds/Cloud2.position.x = -2301
	if cloud1_pos >= 2304:
		$Clouds/Cloud1.position.x = -2301
	$Clouds/Cloud1.position.x += cloud_speed * delta
	$Clouds/Cloud2.position.x += cloud_speed * delta
	

func throw_rod(power):
	
	
	$Hook.set_physics_process(true)
	$Hook.throw(power)
	$MinigameLayer/ThrowProgress.hide()
	
#	await get_tree().create_timer(0.1).timeout
	AudioManager.play("res://SFX/rod_cast_CLICKTRACK.wav", 4)
	await $Hook.entered_water
	AudioManager.stop_playing("res://SFX/rod_cast_CLICKTRACK.wav")
	AudioManager.play("res://SFX/rod_hook_hitting_water.wav", 0)
	
func update_fishing_line():
	rod_point = $FishingRod/AttachPoint.get_global_position()
	hook_point = $Hook.get_global_position()
	$FishingLine.set_point_position(0, rod_point)
	$FishingLine.set_point_position(1, hook_point)


func _on_reload_pressed():
	SceneManager.RestartScene()


func _on_area_2d_body_entered(body):
	if ($Hook.in_catch_mode):
		$Hook.set_physics_process(false)
		$Hook.global_position = $FishingRod/AttachPoint.global_position
		throw_enabled = true
		AudioManager.stop_playing("res://SFX/rod_reeling.wav")
		pass # Replace with function body.


func _on_s_clock_timeout():
	time += 30
	var am_pm
	if time < 240:
		am_pm = "am"
	else:
		am_pm = "pm"
	
	var start_hour = 8
	var hours = int(time / 60) + start_hour
	if time < 240:
		am_pm = "am"
	else:
		am_pm = "pm"
		if hours != 12:
			hours -= 12
	var minutes = (time % 60)/10
	
	$MinigameLayer/Clock/Label.text = str(hours) + ":" + str(minutes) + "0 " + am_pm
	
	if time == 240:
		for path in MorningAnimPlayers:
			var AniPlayer = get_node(path)
			AniPlayer.play("Fade")
		for path in AfternoonCloudPlayers:
			var Aniplayer = get_node(path)
			Aniplayer.play_backwards("Fade")
	if time == 540:
		for path in AfternoonAnimPlayers:
			var AniPlayer = get_node(path)
			AniPlayer.play("Fade")
		for path in AfternoonCloudPlayers:
			var Aniplayer = get_node(path)
			Aniplayer.play("FadeFast")
		$MusicPlayer/AnimationPlayer.play("Fade")
		await $MusicPlayer/AnimationPlayer.animation_finished
		await get_tree().create_timer(20).timeout
		$MusicPlayer.stream = load("res://Music/song_2.wav")
		$MusicPlayer.volume_db = 0
		$MusicPlayer.play()
		if GameData.day == 3:
			$MinigameLayer/SharkSpotted/AnimationPlayer.play("Fade")
	if time == 810:
		$MusicPlayer/AnimationPlayer.play("Fade")	
	
	if time == 840:
		day_end()


func _on_fish_collider_body_entered(body):
	# Fish rigidbody collision with water
	if body is RigidBody2D:
		# Slow down rigid body
		var rigid_body = body
		rigid_body.linear_damp = rigid_fish_water_dampen #adjust this to control amount of damping
		rigid_body.set_collision_mask_value(5, false)

# Spawn a fish
func _on_fish_timer_timeout():
	# Choose a random fish from the list
	var index
	if GameData.day == 3 and time >= 540:
#	if GameData.day == 3:
		index = randi_range(0, fishes.size()-1)
	elif GameData.day >= 2:
		index = randi_range(0, fishes.size()-2)
	else:
		index = randi_range(0, fishes.size()-3)
		
	# choose which direction our fish will come from
	var direction = randi_range(0, 1)
	if direction == 0: direction = -1
	# Instantiate our fish
	var fish = fishes[index].instantiate()
	var spawn_chance = fish.spawn_chance
	var rand_num = randf()
	if rand_num <= spawn_chance:
		# Choose a random location on the Path2D corresponding to the direction
		var spawn_location
		if direction == 1:
			spawn_location = get_node("SpawnPaths/FishSpawnPath1/FishSpawnLocation")
		else: 
			spawn_location = get_node("SpawnPaths/FishSpawnPath2/FishSpawnLocation")
		
		var max_spawn_range = fish.max_spawn_range
		var min_spawn_range = fish.min_spawn_range
		
		spawn_location.progress_ratio = randf_range(min_spawn_range, max_spawn_range)
		
		fish.position = spawn_location.position
		
		var max_speed = fish.max_move_speed
		var min_speed = fish.min_move_speed
		
		var speed = randi_range(min_speed, max_speed)
		fish.init(speed, direction)
		fish.enable_swim_physics()
		add_child(fish)
		fish.caught.connect(on_fish_caught)
	else:
		fish.queue_free()

func _on_despawn_area_body_entered(body):
	body.queue_free()

func on_fish_caught(fish):
	if not $Hook.is_hooked:
		AudioManager.play("res://SFX/fish_hooked_SMALL.wav", -20)
		AudioManager.stop_playing("res://SFX/rod_reeling.wav")
		$Hook.in_catch_mode = false
		var catch_game = $MinigameLayer/CatchingGame
		fish.disable_swim_physics()
		fish.set_anim_speed(2)
		var mouth = fish.get_mouth()
	#
		catch_game.rects_list = fish.rects_list
		catch_game.rotation_speed = fish.game_speed
		catch_game.heart_fill_percent = fish.catch_fill_percent
		if fish.fish_name == "Blue Shark":
			#If blahaj, then use the blahaj version of catch game
			catch_game.init(true)
		else:
			catch_game.init()
		
		$Hook.attach(mouth)
		var win: bool
		win = await catch_game.game_end
		
		
		
#		$FishingRod.play("pull_back")
		if win:
			$FishingRod.play("catch_fish")
			await get_tree().create_timer(0.2).timeout
			$FishingRod/AttachPoint.position = Vector2(8.666 ,-18)
			fish.launch()
			pass
		else:
			$Hook.is_attached = false
			$Hook.is_hooked = false
			$Hook.set_physics_process(true)
			$Hook.in_catch_mode = true
			fish.physics = true
			fish.stop_anim()
			fish.enable_in_boat_physics()
			fish.disable_catching()
			fish.linear_damp = 0

func start_boat_placement(scene_path: String):
	
	$FishingRod.play("default")
#	await get_tree().create_timer(1).timeout
	$CameraDrop.make_current()
	$Boat/BoatOutside.modulate = Color(1,1,1, 0.2)
	var fish_scene = load(scene_path)
	var fish = fish_scene.instantiate()
#	call_deferred("initialize_fish", fish)
	initialize_fish(fish)
	
func initialize_fish(fish):
#	fish.physics = true
	fish.global_position = $FishPlacementPos.global_position
#	call_deferred("add_child", fish)
	call_deferred("add_child", fish)
	await get_tree().create_timer(0.1).timeout
	fish.start_drop_game()
	await fish.drop_game_end
	await get_tree().create_timer(1).timeout
	fishing_minigame_active = false
	throw_enabled = true
	$Boat/BoatOutside.modulate = Color(1,1,1, 1)
	$CameraMain.make_current()
	$Hook.in_catch_mode = true
	

func _on_fish_catch_detect_area_entered(area):
	await get_tree().create_timer(fish_catch_delay).timeout
	if not fishing_minigame_active:
		var scene_path = area.get_parent().scene
		area.get_parent().queue_free()
		
		$Hook.unattach()
	#	var body = area.get_parent()
	#	var scene_path = area.get_parent().scene
		start_boat_placement(scene_path)
#		call_deferred("start_boat_placement", scene_path)
#		start_boat_placement(scene_path)
		fishing_minigame_active = true
	


func _on_pulling_back():
	$Hook.hide()
	$FishingLine.hide()
	$FishingRod.play("pull_back")
	await $FishingRod.animation_finished
	if throw_charging == true:
		$FishingRod.play("pull_back_loop")
	pass # Replace with function body.


func _on_throwing():
	$FishingRod.play("throw")
	$FishingRod/AttachPoint.position = Vector2(-17 ,-9)
	AudioManager.play("res://SFX/rod_cast.wav", -6)
	await get_tree().create_timer(0.15).timeout
	$Hook.show()
	$FishingLine.show()
#	await $FishingRod.animation_finished
	throw_rod($MinigameLayer/ThrowProgress.value)
	await get_tree().create_timer(1).timeout
	$FishingRod/AttachPoint.position = Vector2(-9.333 ,-2)
	$FishingRod.play("default")


func _on_hook_fish_catch_detect_area_entered(area):
	$Hook.is_attached = false
	
func get_fish_on_boat() -> Dictionary:
	var fish_dict = {}
	for fish in $Boat/DetectFishOnBoat.get_overlapping_bodies():
		var name = fish.fish_name
		if name in fish_dict:
			fish_dict[name] += 1
		else:
			fish_dict[name] = 1
	return fish_dict
		
		
func day_end():
	var fish_list = get_fish_on_boat()
	GameData.fish_list = fish_list
	GameData.day += 1
	SceneManager.SwitchScene("earnings")


func _on_end_day_pressed():
	day_end()

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

@export var fish_max_speed = 80
@export var fish_min_speed = 30

var camera_limit_top = 324
var camera_limit_bottom = 1428

# Called when the node enters the scene tree for the first time.
func _ready():
	$Hook.set_physics_process(false)
	$Clouds/Cloud1/Afternoon.modulate = Color(1,1,1,0)
	$Clouds/Cloud2/Afternoon.modulate = Color(1,1,1,0)
	$ThrowProgress.hide()
	$CameraMain.enabled = true
#	$MinigameLayer/CatchingGame.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_fishing_line()
	move_clouds(delta)
	
	if Input.is_action_just_pressed("throw_rod") and throw_enabled:
		$ThrowProgress.value = 0
		$ThrowProgress.show()
		throw_charging = true
	
	if throw_charging:
		if Input.is_action_pressed("throw_rod"):
			$ThrowProgress.value += 2
			throw_charging = true
		else:
			throw_charging = false
			throw_enabled = false
			throw_rod($ThrowProgress.value)
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
	$ThrowProgress.hide()
	AudioManager.play("res://SFX/rod_cast.wav")
#	await get_tree().create_timer(0.1).timeout
	AudioManager.play("res://SFX/rod_cast_CLICKTRACK.wav")
	await $Hook.entered_water
	AudioManager.stop_playing("res://SFX/rod_cast_CLICKTRACK.wav")
	AudioManager.play("res://SFX/rod_hook_hitting_water.wav")
	
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
		pass # Replace with function body.


func _on_s_clock_timeout():
	time += 30
	
	if time == 30:
		for path in MorningAnimPlayers:
			var AniPlayer = get_node(path)
			AniPlayer.play("Fade")
		for path in AfternoonCloudPlayers:
			var Aniplayer = get_node(path)
			Aniplayer.play_backwards("Fade")
	if time == 90:
		for path in AfternoonAnimPlayers:
			var AniPlayer = get_node(path)
			AniPlayer.play("Fade")
		for path in AfternoonCloudPlayers:
			var Aniplayer = get_node(path)
			Aniplayer.play("FadeFast")


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
	var index = randi_range(0, fishes.size()-1)
	# choose which direction our fish will come from
	var direction = randi_range(0, 1)
	if direction == 0: direction = -1
	# Instantiate our fish
	var fish = fishes[index].instantiate()
	
	# Choose a random location on the Path2D corresponding to the direction
	var spawn_location
	if direction == 1:
		spawn_location = get_node("SpawnPaths/FishSpawnPath1/FishSpawnLocation")
	else: 
		spawn_location = get_node("SpawnPaths/FishSpawnPath2/FishSpawnLocation")
		
	spawn_location.progress_ratio = randf()
	
	fish.position = spawn_location.position
	
	var speed = randi_range(fish_min_speed, fish_max_speed)
	fish.init(speed, direction)
	fish.enable_swim_physics()
	add_child(fish)
	fish.caught.connect(on_fish_caught)

func _on_despawn_area_body_entered(body):
	body.queue_free()

func on_fish_caught(fish):
	if not $Hook.is_hooked:
		AudioManager.play("res://SFX/fish_hooked_SMALL.wav", -20)
		$Hook.in_catch_mode = false
		var catch_game = $MinigameLayer/CatchingGame
		fish.disable_swim_physics()
		var mouth = fish.get_mouth()
	#
		catch_game.rects_list = fish.rects_list
		catch_game.rotation_speed = fish.game_speed
		
		catch_game.init()
		
		$Hook.attach(mouth)
		var win: bool
		win = await catch_game.game_end
		if win:
			fish.launch()
			pass
		else:
			$Hook.is_attached = false
			$Hook.is_hooked = false
			$Hook.set_physics_process(true)
			$Hook.in_catch_mode = true
			fish.physics = true
			fish.enable_in_boat_physics()
			fish.linear_damp = 0

func start_boat_placement(scene_path: String):
#	await get_tree().create_timer(1).timeout
	$CameraDrop.make_current()
	
	print("START BOAT PLACEMENT")
	var fish_scene = load(scene_path)
	var fish = fish_scene.instantiate()
#	call_deferred("initialize_fish", fish)
	initialize_fish(fish)
	
func initialize_fish(fish):
	print("initialize")
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
	$CameraMain.make_current()
	

func _on_fish_catch_detect_area_entered(area):
	if not fishing_minigame_active:
		var scene_path = area.get_parent().scene
		area.get_parent().queue_free()
	#	var body = area.get_parent()
		$Hook.unattach()
		
	#	var scene_path = area.get_parent().scene
		start_boat_placement(scene_path)
#		call_deferred("start_boat_placement", scene_path)
#		start_boat_placement(scene_path)
		fishing_minigame_active = true
	

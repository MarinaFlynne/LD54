extends Node

# This script manages playing audio within the game. Whenever an object needs to play audio,
# it can send a request to the audio manager to play the specific audio file needed.
# This script is added as an autoload in project settings.

var num_players: int = 8
var bus = "master"

var available = [] # The available players
var queue = [] # The queue of sounds to play
var in_use = [] # array of players in use

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in num_players:
		# Create new audioStreamPlayer
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus

func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)
	in_use.remove_at(in_use.find(stream))
	
func play(sound_path: String, volume = 0):
	queue.append([sound_path, volume])
	if not available.is_empty():
		return available[0]

func stop_playing(sound_path: String):
	if not in_use.is_empty():
		for player in in_use:
			if player.stream == load(sound_path):
				player.stop()
				_on_stream_finished(player)
		pass
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if available.is_empty():
		print("WARNING: NO AVAILABLE SOUND PLAYERS")
	# Play queued sound if any players are available.
	if not queue.is_empty() and not available.is_empty():
		# Louds sound from the queue into our sound player's stream
		var sound = queue.pop_front()
		available[0].stream = load(sound[0])
		available[0].volume_db = sound[1]
		available[0].play()
		in_use.append(available.pop_front())

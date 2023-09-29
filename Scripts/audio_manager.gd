extends Node

# This script manages playing audio within the game. Whenever an object needs to play audio,
# it can send a request to the audio manager to play the specific audio file needed.
# This script is added as an autoload in project settings.

var num_players: int = 8
var bus = "master"

var available = [] # The available players
var queue = [] # The queue of sounds to play

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
	
func play(sound_path: String):
	queue.append(sound_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Play queued sound if any players are available.
	if not queue.is_empty() and not available.is_empty():
		# Louds sound from the queue into our sound player's stream
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()

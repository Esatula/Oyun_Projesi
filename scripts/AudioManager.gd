extends Node

var click_sound = preload("res://assets/sounds/tıklama.mp3")
var gel_sound = preload("res://assets/sounds/jel.mp3")
var cream_sound = preload("res://assets/sounds/krem1.mp3")
var bandage_sound = preload("res://assets/sounds/bandaj1.mp3")
# Placeholder for music if not found, or use one of the existing as placeholder?
# I'll check for music files or just leave it for now. User didn't specify music file name.

var music_player: AudioStreamPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	# Load music if available (Placeholder logic)
	# if FileAccess.file_exists("res://assets/sounds/music.mp3"):
	# 	music_player.stream = load("res://assets/sounds/music.mp3")
	# 	music_player.play()

func play_click():
	play_sound(click_sound)

func play_gel():
	play_sound(gel_sound)

func play_cream():
	play_sound(cream_sound)
	
func play_bandage():
	play_sound(bandage_sound)

func play_sound(stream):
	if stream:
		var p = AudioStreamPlayer.new()
		p.stream = stream
		add_child(p)
		p.connect("finished", p.queue_free)
		p.play()

func set_volume(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

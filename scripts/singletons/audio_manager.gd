extends Node

@export var audio_library: AudioLibrary

const MAX_SFX_PLAYERS := 5
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

var is_muted := false

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	# SFX players setup
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		sfx_players.append(player)
		add_child(player)

	print("AudioManager initialized")

# --- MUSIC ---
func play_music_by_key(name: String):
	if not audio_library or not audio_library.music_tracks.has(name):
		push_warning("Music track not found: %s" % name)
		return
	play_music(audio_library.music_tracks[name])

func play_music(stream: AudioStream):
	music_player.stream = stream
	music_player.play()

# --- SFX ---
func play_sfx_by_key(name: String):
	if not audio_library or not audio_library.sfx_clips.has(name):
		push_warning("SFX not found: %s" % name)
		return
	play_sound(audio_library.sfx_clips[name])

func play_sound(sfx: AudioStream):
	for player in sfx_players:
		if not player.playing:
			player.stream = sfx
			player.play()
			return
	push_warning("All SFX players are busy — consider increasing MAX_SFX_PLAYERS.")

# --- MUTE ---
func toggle_mute():
	is_muted = !is_muted
	var music_index = AudioServer.get_bus_index("Music")
	var sfx_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(music_index, is_muted)
	AudioServer.set_bus_mute(sfx_index, is_muted)

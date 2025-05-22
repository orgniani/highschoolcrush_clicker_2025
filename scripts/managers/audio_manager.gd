extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS := 5  # Number of simultaneous SFX allowed

var is_muted := false

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		sfx_players.append(player)
		add_child(player)

	print("AudioManager initialized")

# --- MUSIC ---
func play_music(music: AudioStream):
	music_player.stream = music
	music_player.play()

# --- SOUND EFFECTS ---
func play_sound(sfx: AudioStream):
	for player in sfx_players:
		if not player.playing:
			player.stream = sfx
			player.play()
			return

	push_warning("All SFX players are busy — consider increasing MAX_SFX_PLAYERS.")

func toggle_mute():
	is_muted = !is_muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), is_muted)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), is_muted)

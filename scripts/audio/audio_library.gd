extends Resource
class_name AudioLibrary

@export_category("Music")
@export var music_tracks: Dictionary[String, AudioStream] = {}

@export_category("SFX")
@export var sfx_clips: Dictionary[String, AudioStream] = {}

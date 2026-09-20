extends Node

const AMBIENCE := preload("res://audio/generated/ambience_main.ogg")
const AMBIENCE_ALT := preload("res://audio/generated/ambience_alt.ogg")
const MUSIC := preload("res://audio/generated/music.ogg")
const DOOR_OPEN := preload("res://audio/generated/door_open.ogg")
const DOOR_CLOSE := preload("res://audio/generated/door_close.ogg")
const FOOTSTEP_01 := preload("res://audio/generated/footstep_01.ogg")
const FOOTSTEP_02 := preload("res://audio/generated/footstep_02.ogg")

var ambience: AudioStreamPlayer
var ambience_alt: AudioStreamPlayer
var music: AudioStreamPlayer
var door: AudioStreamPlayer
var footstep: AudioStreamPlayer
var bus_ids := {}
var next_footstep := 0

func setup(explorer: CharacterBody3D) -> void:
	name = "ShipAudio"
	bus_ids["music"] = make_bus("Music")
	bus_ids["ambience_main"] = make_bus("AmbienceMain")
	bus_ids["ambience_alt"] = make_bus("AmbienceAlt")
	bus_ids["footsteps"] = make_bus("Footsteps")
	bus_ids["doors"] = make_bus("Doors")
	ambience = make_player(AMBIENCE,"Ambience")
	ambience.bus = "AmbienceMain"
	ambience_alt = make_player(AMBIENCE_ALT,"AmbienceAlt")
	music = make_player(MUSIC,"Music")
	door = make_player(null,"Doors")
	footstep = make_player(null,"Footsteps")
	explorer.footstep_requested.connect(play_footstep)
	ambience.play()
	ambience_alt.play()
	music.play()
	loop_player(ambience)
	loop_player(ambience_alt)
	loop_player(music)
	set_volume("music",.16)
	set_volume("ambience_main",.28)
	set_volume("ambience_alt",.0)
	set_volume("footsteps",.78)
	set_volume("doors",.62)

func make_bus(title: String) -> int:
	var existing := AudioServer.get_bus_index(title)
	if existing >= 0:
		return existing
	AudioServer.add_bus()
	var index := AudioServer.bus_count-1
	AudioServer.set_bus_name(index,title)
	return index

func make_player(stream: AudioStream, bus: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	add_child(player)
	return player

func loop_player(player: AudioStreamPlayer) -> void:
	player.finished.connect(func(): player.play())

func set_volume(kind: String, value: float) -> void:
	if not bus_ids.has(kind):
		return
	AudioServer.set_bus_volume_db(bus_ids[kind],linear_to_db(maxf(.001,value)))

func play_door(opened: bool) -> void:
	door.stream = DOOR_OPEN if opened else DOOR_CLOSE
	door.play()

func play_footstep() -> void:
	footstep.stream = FOOTSTEP_01 if next_footstep == 0 else FOOTSTEP_02
	next_footstep = 1-next_footstep
	footstep.play()

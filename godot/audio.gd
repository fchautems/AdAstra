extends Node

const AMBIENCE := preload("res://audio/ship_ambience.ogg")
const MUSIC := preload("res://audio/space_music.ogg")
const DOOR_OPEN := preload("res://audio/door_open.ogg")
const DOOR_CLOSE := preload("res://audio/door_close.ogg")

var ambience: AudioStreamPlayer
var music: AudioStreamPlayer
var door: AudioStreamPlayer
var bus_ids := {}

func setup(_explorer: CharacterBody3D) -> void:
	name = "ShipAudio"
	bus_ids["music"] = make_bus("Music")
	bus_ids["ambience"] = make_bus("Ambience")
	bus_ids["effects"] = make_bus("Effects")
	ambience = make_player(AMBIENCE,"Ambience")
	music = make_player(MUSIC,"Music")
	door = make_player(null,"Effects")
	ambience.play()
	music.play()
	set_volume("music",.16)
	set_volume("ambience",.28)
	set_volume("effects",.62)

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

func set_volume(kind: String, value: float) -> void:
	if not bus_ids.has(kind):
		return
	AudioServer.set_bus_volume_db(bus_ids[kind],linear_to_db(maxf(.001,value)))

func play_door(opened: bool) -> void:
	door.stream = DOOR_OPEN if opened else DOOR_CLOSE
	door.play()

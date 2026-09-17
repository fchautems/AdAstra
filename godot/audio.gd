extends Node

var ambience: AudioStreamPlayer
var effects: AudioStreamPlayer
var ambience_playback: AudioStreamGeneratorPlayback
var effects_playback: AudioStreamGeneratorPlayback
var elapsed := 0.0
var effects_queue: Array = []

func setup(explorer: CharacterBody3D) -> void:
	name = "AudioAtmosphere"
	ambience = make_player(-19.0)
	effects = make_player(-12.0)
	explorer.footstep_requested.connect(play_footstep)

func make_player(volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.35
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.play()
	if ambience == null:
		ambience_playback = player.get_stream_playback()
	else:
		effects_playback = player.get_stream_playback()
	return player

func play_footstep() -> void:
	effects_queue.append({"age":0.0,"duration":0.115,"kind":"step"})

func play_door(opened: bool) -> void:
	effects_queue.append({"age":0.0,"duration":0.42,"kind":"open" if opened else "close"})

func _process(delta: float) -> void:
	elapsed += delta
	fill_ambience()
	fill_effects()

func fill_ambience() -> void:
	if ambience_playback == null:
		return
	var available := ambience_playback.get_frames_available()
	for frame in available:
		var t := elapsed + float(frame) / 22050.0
		# Ventilation basse, souffle d'air, puis deux nappes très discrètes.
		var hum := sin(t * TAU * 48.0) * 0.070
		var air := sin(t * TAU * 117.0 + sin(t * .31) * 2.0) * 0.018
		var music := sin(t * TAU * 109.0 + sin(t * .07) * .45) * .018
		music += sin(t * TAU * 163.5 + sin(t * .05)) * .010
		var sample := hum + air + music
		ambience_playback.push_frame(Vector2(sample,sample))

func fill_effects() -> void:
	if effects_playback == null:
		return
	var available := effects_playback.get_frames_available()
	for frame in available:
		var sample := 0.0
		for event in effects_queue:
			var progress: float = event.age / event.duration
			var fade := maxf(0.0,1.0-progress)
			if event.kind == "step":
				sample += sin(event.age * TAU * 155.0) * fade * fade * .26
				sample += sin(event.age * TAU * 73.0) * fade * .11
			else:
				var sweep := lerpf(330.0,95.0,progress) if event.kind == "open" else lerpf(110.0,270.0,progress)
				sample += sin(event.age * TAU * sweep) * fade * .13
				sample += sin(event.age * TAU * sweep * .49) * fade * .08
		for event in effects_queue:
			event.age += 1.0 / 22050.0
		effects_playback.push_frame(Vector2(sample,sample))
	effects_queue = effects_queue.filter(func(event): return event.age < event.duration)

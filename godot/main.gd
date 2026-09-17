extends Node3D

const PlayerScript = preload("res://player.gd")
var player: CharacterBody3D
var overview: Camera3D
var info: Label
var params: Dictionary
var inspecting := false
var collision_count := 0
var ship_root: Node3D
var stars: MultiMeshInstance3D
var perf: Array = []
var dressing: Node3D
var ui: CanvasLayer
var paused := false
var identity: Node3D
var audio: Node

func _ready() -> void:
	params = JSON.parse_string(FileAccess.get_file_as_string("res://assets/parameters.json"))
	configure_input()
	var ship = load("res://assets/adastra.glb").instantiate()
	add_child(ship)
	ship_root = ship
	add_collisions(ship)
	dressing = preload("res://interior.gd").new()
	add_child(dressing)
	dressing.setup(params,ship)
	add_space()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("03060d")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("f2f1ee")
	env.ambient_light_energy = 0.72
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45,-35,0)
	sun.light_energy = 0.12
	sun.light_cull_mask = 1
	sun.shadow_enabled = true
	add_child(sun)
	for p in params.lights:
		# The corridor kit owns its lighting layer; retaining these legacy omni
		# lights there exceeded the practical overlap budget in Compatibility.
		if p[0] >= 10.0 and p[0] <= 47.0 and absf(p[2]) <= 10.0:
			continue
		var light := OmniLight3D.new()
		light.position = Vector3(p[0],p[1],p[2])
		light.omni_range = 5.4
		light.light_energy = 0.32
		light.light_cull_mask = 1
		light.light_color = Color("fff8ef")
		light.omni_attenuation = 0.8
		light.shadow_enabled = true
		add_child(light)
	var pilot = preload("res://pilot.gd").new()
	add_child(pilot)
	pilot.setup(dressing,ship,params)
	# Legacy U/L labels were blockout guides; the exploration view stays unlabelled.
	player = PlayerScript.new()
	add_child(player)
	var s: Array = params.spawn
	player.setup(params.config,Vector3(s[0],s[1],s[2]))
	audio = preload("res://audio.gd").new()
	add_child(audio)
	audio.setup(player)
	identity = preload("res://identity.gd").new()
	add_child(identity)
	identity.setup(params,pilot,player,ship)
	identity.door_state_changed.connect(audio.play_door)
	player.camera.current = true
	overview = Camera3D.new()
	add_child(overview)
	overview.position = Vector3(-5,35,55)
	overview.projection = Camera3D.PROJECTION_ORTHOGONAL
	overview.size = 65
	overview.look_at(Vector3(params.length/2,0,0))
	overview.far = 300
	ui = preload("res://ui.gd").new()
	add_child(ui)
	ui.explore_requested.connect(begin_exploration)
	ui.resume_requested.connect(resume_exploration)
	ui.quit_requested.connect(func(): get_tree().quit())
	ui.fullscreen_requested.connect(toggle_fullscreen)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("SCENE_READY meshes_with_collision=",collision_count)
	if "--identity-check" in OS.get_cmdline_user_args():
		ui.hide()
		player.automated = true
		call_deferred("identity_check")
	elif "--test" in OS.get_cmdline_user_args():
		ui.hide()
		player.automated = true
		call_deferred("run_tests")
	elif "--pilot" in OS.get_cmdline_user_args():
		ui.hide()
		call_deferred("pilot_capture")
	elif "--screenshots" in OS.get_cmdline_user_args():
		ui.hide()
		call_deferred("capture_views")
	elif "--exterior" in OS.get_cmdline_user_args():
		ui.hide()
		call_deferred("capture_exterior")
	elif "--ui-captures" in OS.get_cmdline_user_args():
		call_deferred("capture_ui")

func configure_input() -> void:
	# Logical letters support both layouts; physical WASD also maps to AZERTY ZQSD.
	var keys := {"forward":[KEY_W,KEY_Z,KEY_UP],"back":[KEY_S,KEY_DOWN],"left":[KEY_A,KEY_Q,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"run":[KEY_SHIFT]}
	for action in keys:
		InputMap.add_action(action)
		for key in keys[action]:
			var event := InputEventKey.new()
			event.keycode = key
			InputMap.action_add_event(action,event)

func add_collisions(node: Node) -> void:
	if node is MeshInstance3D and str(node.name).begins_with("Glass_"):
		var glass := StandardMaterial3D.new()
		glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		glass.albedo_color = Color(.46,.64,.70,.24)
		glass.cull_mode = BaseMaterial3D.CULL_DISABLED
		glass.roughness = .15
		node.material_override = glass
	if node is MeshInstance3D and not str(node.name).begins_with("Guide_"):
		var body := StaticBody3D.new()
		var collider := CollisionShape3D.new()
		var shape: ConcavePolygonShape3D = node.mesh.create_trimesh_shape()
		shape.backface_collision = true
		collider.shape = shape
		body.add_child(collider)
		node.add_child(body)
		collision_count += 1
	for child in node.get_children():
		add_collisions(child)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not inspecting and ui.started and not paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				if ui.started:
					if ui.toggle_pause():
						pause_exploration()
					else:
						resume_exploration()
			KEY_F11:
				toggle_fullscreen()
			KEY_F2:
				toggle_view()
			KEY_F3:
				player.position = Vector3(18.3,params.floor+.02,9)
				player.camera.look_at(Vector3(23,.5,9))
			KEY_R:
				player.reset()
			KEY_F10:
				get_tree().quit()

func toggle_view() -> void:
	inspecting = not inspecting
	player.frozen = inspecting
	overview.current = inspecting
	player.camera.current = not inspecting
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if inspecting else Input.MOUSE_MODE_CAPTURED

func begin_exploration() -> void:
	ui.begin()
	paused = false
	player.frozen = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func pause_exploration() -> void:
	paused = true
	player.frozen = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume_exploration() -> void:
	ui.hide_pause()
	paused = false
	player.frozen = inspecting
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if inspecting else Input.MOUSE_MODE_CAPTURED

func toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	var zone := "COCKPIT" if player.position.x < 10 else ("HANGAR" if player.position.x > params.cylinder_end else "COULOIR")
	ui.set_zone("VUE EXTÉRIEURE" if inspecting else zone)

func frame_wait(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func identity_check() -> void:
	await frame_wait(30)
	player.frozen = true
	for view in [
		["identity_bridge",Vector3(9.3,params.floor,4.8),Vector3(6.15,.5,0)],
		["identity_corridor",Vector3(14.5,params.floor,9),Vector3(28,.55,9)],
		["identity_door",Vector3(19,params.floor,8.4),Vector3(20.5,.45,10.1)]]:
		player.position = view[1]
		player.camera.look_at(view[2])
		await frame_wait(12)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://../"+view[0]+".png")
	player.position = Vector3(7,params.floor+.02,0)
	player.velocity = Vector3.ZERO
	player.frozen = false
	var success := true
	for waypoint in [Vector3(9.6,params.floor,0),Vector3(9.6,params.floor,8.65),Vector3(14,params.floor,9),Vector3(20.5,params.floor,9),Vector3(20.5,params.floor,11.5),Vector3(20.5,params.floor,9),Vector3(16,params.floor,9)]:
		var passed := await walk_to(waypoint,400)
		print("IDENTITY_WALK ",waypoint," ",passed," actual=",player.position)
		success = success and passed
		if not passed: break
	await frame_wait(60)
	var first_door = identity.doors[0]
	var closed: bool = first_door.slide < .01
	success = success and closed
	print("IDENTITY_DOOR_RECLOSED=",closed)
	print("IDENTITY_CHECK=", "PASS" if success else "FAIL")
	get_tree().quit(0 if success else 1)

func walk_to(target: Vector3, max_frames := 2200) -> bool:
	for i in max_frames:
		var offset := target-player.position
		offset.y = 0
		if offset.length() < 0.13:
			player.test_direction = Vector3.ZERO
			return absf(player.position.y-params.floor)<0.06
		player.test_direction = offset.normalized()
		await get_tree().physics_frame
	player.test_direction = Vector3.ZERO
	return false

func run_tests() -> void:
	var results: Array = []
	await frame_wait(40)
	results.append({"test":"spawn_on_floor","pass":player.is_on_floor()})
	var origin := Vector3(25,params.floor+1.4,0)
	var l := ray_hit(origin,origin+Vector3(0,0,-4))
	var r := ray_hit(origin,origin+Vector3(0,0,4))
	results.append({"test":"plan_width_2m","pass":not l.is_empty() and not r.is_empty() and absf(l.position.distance_to(r.position)-2)<.01})
	origin = Vector3(px(28.5),params.floor+1.4,10.175)
	l = ray_hit(origin,origin+Vector3(-2,0,0))
	r = ray_hit(origin,origin+Vector3(2,0,0))
	results.append({"test":"svg_opening_1_2m","pass":not l.is_empty() and not r.is_empty() and absf(l.position.distance_to(r.position)-1.2*params.longitudinal_scale)<.01})
	results.append({"test":"six_cabins","pass":params.cabins.size()==6})
	for cabin in params.cabins:
		results.append({"test":"studio_area_"+cabin.id,"pass":cabin.usable_area_m2>=49.0})
	for z in [-9.0,9.0]:
		var closure := ray_hit(Vector3(params.cylinder_end+3,3.2,z),Vector3(params.cylinder_end-2,3.2,z))
		results.append({"test":"hangar_upper_seal_"+str(z),"pass":not closure.is_empty()})
	var underside := ray_hit(Vector3(params.length-5,-2,0),Vector3(params.length-5,-6,0))
	results.append({"test":"no_detached_lower_slab","pass":underside.is_empty()})
	for item in dressing.objects:
		if item.get("collision",false):
			var pos := Vector3(item.position[0],item.position[1],item.position[2])
			var height: float = item.size[1]
			var hit := ray_hit(pos+Vector3(0,height+.1,0),pos+Vector3(0,.1,0))
			results.append({"test":"furniture_collision_"+item.asset+"_"+str(pos),"pass":not hit.is_empty() and hit.position.y>params.floor+.1})
	for coordinates in params.routes:
		var point := Vector3(coordinates[0],coordinates[1],coordinates[2])
		var passed := await walk_to(point)
		results.append({"test":"walk_"+str(point),"pass":passed,"position":str(player.position)})
		if not passed:
			break
	player.position = Vector3(25,params.floor+.02,0)
	await frame_wait(15)
	Input.action_press("run")
	player.test_direction = Vector3.BACK
	await frame_wait(100)
	Input.action_release("run")
	player.test_direction = Vector3.ZERO
	results.append({"test":"wall_blocks_running","pass":player.position.z<.74 and player.position.z>.65})
	var glass_hit := ray_hit(Vector3(4,.6,0),Vector3(-3,.6,0))
	results.append({"test":"view_through_actual_glass","pass":not glass_hit.is_empty() and str(glass_hit.collider.get_parent().name).begins_with("Glass_")})
	player.position = Vector3(25,params.floor+.02,0)
	player.velocity = Vector3(0,8,0)
	var highest := player.position.y
	for i in 100:
		await get_tree().physics_frame
		highest = maxf(highest,player.position.y)
	results.append({"test":"ceiling_blocks","pass":highest+params.config.player_height_m<params.roof+.03})
	# Exercise the real event/input path, not just the automated route direction.
	player.automated = false
	ui.begin()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for key in [KEY_W,KEY_Z,KEY_A,KEY_Q,KEY_S,KEY_D]:
		player.position = Vector3(25,params.floor+.02,0)
		player.rotation.y = -PI/2
		await frame_wait(10)
		var before := player.position
		var event := InputEventKey.new()
		event.keycode = key
		event.pressed = true
		Input.parse_input_event(event)
		await frame_wait(30)
		event = InputEventKey.new()
		event.keycode = key
		event.pressed = false
		Input.parse_input_event(event)
		results.append({"test":"key_moves_"+OS.get_keycode_string(key),"pass":player.position.distance_to(before)>0.65})
	var yaw_before: float = player.rotation.y
	var mouse := InputEventMouseMotion.new()
	mouse.relative = Vector2(40,20)
	Input.parse_input_event(mouse)
	await frame_wait(2)
	results.append({"test":"mouse_look","pass":absf(player.rotation.y-yaw_before)>0.01 and absf(player.camera.rotation.x)>0.01})
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	Input.parse_input_event(escape)
	await frame_wait(2)
	results.append({"test":"escape_opens_pause_menu","pass":Input.mouse_mode==Input.MOUSE_MODE_VISIBLE and ui.showing_pause and player.frozen})
	resume_exploration()
	results.append({"test":"resume_recaptures_mouse","pass":Input.mouse_mode==Input.MOUSE_MODE_CAPTURED and not player.frozen})
	toggle_view()
	results.append({"test":"exterior_camera","pass":overview.current and player.frozen})
	toggle_view()
	results.append({"test":"return_to_walk","pass":player.camera.current and not player.frozen})
	var success := true
	for result in results:
		if not result.pass:
			success = false
	var file := FileAccess.open("res://../test-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed":success,"engine":Engine.get_version_info().string,"collision_meshes":collision_count,"checks":results},"  "))
	print("WALK_TESTS_", "PASS" if success else "FAIL", " ",JSON.stringify(results))
	get_tree().quit(0 if success else 1)


func capture_views() -> void:
	await frame_wait(40)
	player.frozen = true
	for data in [
		["01_couloir_acces",Vector3(17,params.floor,9),Vector3(32,params.floor+1.45,9.2)],
		["02_cockpit_baie",Vector3(8,params.floor,0),Vector3(1.5,.4,0)],
		["04_cabine_studio",Vector3(px(33.3),params.floor,11.4),Vector3(px(37.5),params.floor+1.4,15)],
		["08_cuisine",Vector3(px(37.8),params.floor,13),Vector3(px(32.8),params.floor+.9,15.3)],
		["07_grande_cabine",Vector3(17,params.floor,11.2),Vector3(23,params.floor+1.2,14)],
		["05_hangar_raccord",Vector3(params.cylinder_end+8,params.floor,0),Vector3(params.cylinder_end,3.4,0)]]:
		player.position = data[1]
		player.camera.look_at(data[2])
		await frame_wait(12)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://../"+data[0]+".png")
		await measure_view(data[0])
	overview.current = true
	await frame_wait(12)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://../06_exterieur.png")
	hide_roofs(ship_root)
	stars.visible = false
	overview.position = Vector3(params.length/2,80,0)
	overview.look_at(Vector3(params.length/2,0,0),Vector3(0,0,-1))
	overview.size = 41
	overview.current = true
	add_plan_overlay()
	await frame_wait(15)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://../03_conformite_plan.png")
	FileAccess.open("res://../performance.json",FileAccess.WRITE).store_string(JSON.stringify(perf,"  "))
	get_tree().quit()

func measure_view(title: String) -> void:
	var times: Array = []
	for i in 90:
		var start := Time.get_ticks_usec()
		await RenderingServer.frame_post_draw
		times.append((Time.get_ticks_usec()-start)/1000.0)
	times.sort()
	perf.append({"view":title,"median_frame_ms":times[45],"p95_frame_ms":times[85],"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)})

func hide_roofs(node: Node) -> void:
	if node is MeshInstance3D:
		var title := str(node.name)
		if title.contains("roof") or title == "Cylinder_upper" or title == "Cockpit_skin_2" or title == "Glass_2" or title.begins_with("Guide_Light"):
			node.visible = false
	for child in node.get_children():
		hide_roofs(child)

func add_plan_overlay() -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color("#43e5ea")
	mat.no_depth_test = true
	var lines := ImmediateMesh.new()
	lines.surface_begin(Mesh.PRIMITIVE_LINES,mat)
	for segment in params.reference_lines:
		for point in segment:
			lines.surface_add_vertex(Vector3(point[0],params.roof+.4,-point[1]))
	lines.surface_end()
	var overlay := MeshInstance3D.new()
	overlay.mesh = lines
	add_child(overlay)
	for cabin in params.cabins:
		var center := Vector2.ZERO
		for p in cabin.polygon:
			center += Vector2(p[0],p[1])
		center /= cabin.polygon.size()
		var label := Label3D.new()
		label.text = cabin.id+"\n"+str(cabin.usable_area_m2)+" m²"
		label.position = Vector3(center.x,params.roof+.5,-center.y)
		label.rotation_degrees.x = -90
		label.font_size = 64
		label.pixel_size = .018
		add_child(label)
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var legend := Label.new()
	legend.position = Vector2(20,16)
	legend.text = "ÉTUDE ALLONGÉE À 62 m · SURFACES UTILES DES CABINES"
	legend.add_theme_font_size_override("font_size",20)
	canvas.add_child(legend)

func add_space() -> void:
	stars = MultiMeshInstance3D.new()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(.65,.8,1)
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	var quad := QuadMesh.new()
	quad.size = Vector2(.18,.18)
	quad.material = mat
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = quad
	mm.instance_count = 1600
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in 1600:
		var dir := Vector3(rng.randf_range(-1,1),rng.randf_range(-1,1),rng.randf_range(-1,1)).normalized()
		mm.set_instance_transform(i,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*rng.randf_range(.6,1.8)),Vector3(29,0,0)+dir*110))
	stars.multimesh = mm
	add_child(stars)

func ray_hit(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from,to)
	query.exclude = [player.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query)

func px(x: float) -> float:
	var ext: Dictionary = params.config.cabin_extension
	if x <= ext.start_x_m:
		return x
	if x >= ext.end_x_m:
		return x+ext.added_length_m
	return ext.start_x_m+(x-ext.start_x_m)*params.longitudinal_scale


func pilot_capture() -> void:
	await frame_wait(100)
	player.frozen = true
	for data in [
		["corridor_01_generalise",Vector3(12.5,params.floor,9.0),Vector3(40.0,params.floor+1.35,9.0)],
		["corridor_02_acces",Vector3(31.2,params.floor,8.25),Vector3(29.5,.40,9.97)]]:
		player.position = data[1]
		player.camera.look_at(data[2])
		await frame_wait(30)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://../"+data[0]+".png")
	get_tree().quit()

func capture_exterior() -> void:
	await frame_wait(40)
	player.frozen = true
	overview.current = true
	overview.position = Vector3(-5,35,55)
	overview.look_at(Vector3(params.length/2,0,0))
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://../exterior_metal.png")
	player.camera.current = true
	for data in [["cockpit",Vector3(8,params.floor,0),Vector3(2,.5,1.5)],["hangar",Vector3(params.cylinder_end+3,params.floor,0),Vector3(params.length-1,1.8,5)]]:
		player.position = data[1]
		player.camera.look_at(data[2])
		await frame_wait(15)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://../"+data[0]+".png")
	# Small migration-free geometry check: original cabin openings remain clear.
	var blocked := 0
	for cabin in params.cabins:
		var z := 1.0 if str(cabin.id).begins_with("U") else -1.0
		var x: float = (cabin.opening[0]+cabin.opening[1])/2.0
		var query := PhysicsRayQueryParameters3D.create(Vector3(x,.5,z*9.5),Vector3(x,.5,z*10.6))
		if not get_world_3d().direct_space_state.intersect_ray(query).is_empty(): blocked += 1
	print("CABIN_OPENINGS_BLOCKED=",blocked)
	get_tree().quit()

func capture_ui() -> void:
	await frame_wait(40)
	player.frozen = true
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://../ui_01_accueil.png")
	begin_exploration()
	await frame_wait(800)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://../ui_02_exploration.png")
	ui.toggle_pause()
	pause_exploration()
	await frame_wait(8)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://../ui_03_pause.png")
	get_tree().quit()

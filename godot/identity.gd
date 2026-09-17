extends Node3D

var library: Node3D
var doors: Array = []
var player: CharacterBody3D
var data: Dictionary

func setup(params: Dictionary, pilot: Node3D, explorer: CharacterBody3D, ship: Node3D) -> void:
	name = "VisualIdentity"
	data = params
	player = explorer
	library = load("res://assets/identity_kit.glb").instantiate()
	# Replace just the old floor/ceiling meshes, keeping their existing lights.
	for child in pilot.get_children():
		var title := str(child.name)
		if title.ends_with("Floor") or title.ends_with("CeilingBays") or title.ends_with("CeilingLuminaires"):
			child.hide()
	for z in [-9.0,0.0,9.0]:
		var x := 10.0
		while x < params.cylinder_end:
			var length: float = minf(2.5,params.cylinder_end-x)
			var tile := put("FloorTile",Vector3(x+length/2,params.floor+.006,z))
			lighting_layer(tile,2)
			tile.scale.x = length/2.5
			var bay := put("CeilingBay",Vector3(x+length/2,params.roof-.035,z))
			lighting_layer(bay,2)
			bay.scale.x = length/2.5
			x += length
		for station in range(12,int(params.cylinder_end),5):
			var near_door := false
			for cabin in params.cabins:
				if absf(station-(cabin.opening[0]+cabin.opening[1])/2)<1.0:
					near_door = true
			if not near_door:
				var arch := put("CorridorArch",Vector3(station,params.floor,z),PI/2)
				lighting_layer(arch,2)
				collide_meshes(arch)
	for cabin in params.cabins:
		var width: float = cabin.opening[1]-cabin.opening[0]
		var center: float = (cabin.opening[0]+cabin.opening[1])/2
		var sign_z := 1.0 if str(cabin.id).begins_with("U") else -1.0
		var at := Vector3(center,params.floor,sign_z*10.10)
		var leaves: Array = []
		for side in [-1.0,1.0]:
			var body := AnimatableBody3D.new()
			body.name = "Door_"+str(cabin.id)
			body.sync_to_physics = false
			add_child(body)
			body.position = at+Vector3(side*width*.25,0,0)
			var leaf := model("DoorLeaf")
			leaf.scale.x = (width-.015)*(-side)
			lighting_layer(leaf,2)
			body.add_child(leaf)
			var shape := CollisionShape3D.new()
			var box := BoxShape3D.new()
			box.size = Vector3(width*.5-.01,2.42,.10)
			shape.shape = box
			shape.position.y = 1.21
			body.add_child(shape)
			leaves.append({"body":body,"side":side,"shape":shape})
			lighting_layer(put("DoorLight",Vector3(center+side*(width/2+.075),params.floor,sign_z*9.94),0 if sign_z>0 else PI),2)
		doors.append({"at":at,"width":width,"leaves":leaves,"slide":0.0,"open":false})
	bridge(params)
	var foot := library.find_child("ArchFoot*",true,false) as MeshInstance3D
	bridge_lining(ship,foot.mesh.surface_get_material(0))
	library.free()

func lighting_layer(node: Node, layer: int) -> void:
	if node is MeshInstance3D: node.layers = layer
	for child in node.get_children(): lighting_layer(child,layer)

func bridge_lining(node: Node, material: Material) -> void:
	if node is MeshInstance3D and str(node.name).begins_with("Cockpit_"):
		for i in node.mesh.get_surface_count():
			var original = node.mesh.surface_get_material(i)
			if original != null and original.resource_name == "Interior_Ivory":
				node.set_surface_override_material(i,material)
	for child in node.get_children(): bridge_lining(child,material)

func model(title: String) -> Node3D:
	var source := library.find_child(title,true,false)
	assert(source != null,"Missing Blender kit module: "+title)
	return source.duplicate() as Node3D

func put(title: String, at: Vector3, yaw: float = 0) -> Node3D:
	var node := model(title)
	add_child(node)
	node.position = at
	node.rotation.y = yaw
	return node

func collide_meshes(node: Node) -> void:
	if node is MeshInstance3D and not str(node.name).contains("Light"):
		node.create_trimesh_collision()
	for child in node.get_children():
		if child is MeshInstance3D or (child is Node3D and not child is PhysicsBody3D):
			collide_meshes(child)

func bridge(params: Dictionary) -> void:
	# The central aisle and the aft cross-route to both lateral corridors stay clear.
	for side in [-1.0,1.0]:
		var base := put("CommandPlatform",Vector3(6.25,params.floor+.008,side*2.7))
		collide_meshes(base)
		var console := put("Console",Vector3(6.25,params.floor+.14,side*2.7),0 if side>0 else PI)
		collide_meshes(console)
	put("BridgeRing",Vector3(7.1,1.55,0))
	var deck := MeshInstance3D.new()
	var mesh := ImmediateMesh.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("222b32")
	mat.roughness = .36
	mat.metallic = .2
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES,mat)
	var corners := [Vector3(2.65,params.floor+.005,-2.2),Vector3(9.96,params.floor+.005,-9.6),Vector3(9.96,params.floor+.005,9.6),Vector3(2.65,params.floor+.005,2.2)]
	for i in [0,1,2,0,2,3]:
		mesh.surface_set_normal(Vector3.UP)
		mesh.surface_add_vertex(corners[i])
	mesh.surface_end()
	deck.mesh = mesh
	add_child(deck)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(7.1,1.25,0)
	lamp.omni_range = 4.0
	lamp.light_energy = .32
	lamp.light_color = Color("dfeaf4")
	lamp.shadow_enabled = true
	add_child(lamp)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or player.frozen:
		return
	for door in doors:
		var difference: Vector3 = player.global_position-door.at
		difference.y = 0
		var distance := difference.length()
		if distance<2.5: door.open = true
		elif distance>3.2: door.open = false
		var travel: float = door.width*.5+.07
		door.slide = move_toward(door.slide,travel if door.open else 0.0,delta*2.4)
		for leaf in door.leaves:
			leaf.body.position = door.at+Vector3(leaf.side*(door.width*.25+door.slide),0,0)

extends Node3D

var params: Dictionary
var objects: Array = []
var surface_material: ShaderMaterial
var metal: StandardMaterial3D
var ivory: StandardMaterial3D
var warm: StandardMaterial3D
var dark: StandardMaterial3D
var accent: StandardMaterial3D

func simple(color: String, roughness: float = .7, metallic: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(color)
	m.roughness = roughness
	m.metallic = metallic
	return m

func setup(data: Dictionary, ship: Node3D) -> void:
	params = data
	name = "InteriorDressing"
	metal = simple("b4bab9",.48,.25)
	metal.roughness_texture = load("res://assets/textures/Metal032/Metal032_1K-JPG_Roughness.jpg")
	ivory = simple("e8e4da")
	dark = simple("45494b",.8)
	accent = simple("a65e4d",.9)
	warm = simple("fff1dc")
	warm.emission_enabled = true
	warm.emission = Color("fff1dc")
	warm.emission_energy_multiplier = 1.1
	surface_material = ShaderMaterial.new()
	surface_material.shader = load("res://interior.gdshader")
	surface_material.set_shader_parameter("plastic_color",load("res://assets/textures/Plastic010/Plastic010_1K-JPG_Color.jpg"))
	surface_material.set_shader_parameter("plastic_rough",load("res://assets/textures/Plastic010/Plastic010_1K-JPG_Roughness.jpg"))
	surface_material.set_shader_parameter("rubber_color",load("res://assets/textures/Rubber004/Rubber004_1K-JPG_Color.jpg"))
	surface_material.set_shader_parameter("rubber_rough",load("res://assets/textures/Rubber004/Rubber004_1K-JPG_Roughness.jpg"))
	surface_material.set_shader_parameter("rubber_normal",load("res://assets/textures/Rubber004/Rubber004_1K-JPG_NormalGL.jpg"))
	surface_material.set_shader_parameter("hangar_x",params.cylinder_end)
	coat(ship)
	for p in params.lights:
		# Corridor lighting is now supplied exclusively by the validated pilot kit.
		# Keep the original sources in the cockpit and hangar unchanged.
		if p[0] >= 10.0 and p[0] <= 47.0 and absf(p[2]) <= 10.0:
			continue
		var at := Vector3(p[0],p[1]+.23,p[2])
		# Actual imported luminaire; flattened body and elongated diffuser.
		asset("furniture/lampSquareCeiling",at-Vector3(0,.08,0),Vector3(1.8,.12,.3),0,false)
		box("Diffuser",at-Vector3(0,.085,0),Vector3(1.6,.025,.18),warm)
	for cabin in params.cabins:
		dress_cabin(cabin)
	# Small repeating seam covers, all against existing surfaces.
	for sign_z in [-1.0,1.0]:
		for x in range(12,int(params.cylinder_end),3):
			box("WallTrim",Vector3(x,.45,sign_z*8.014),Vector3(.025,2.9,.024),metal)
		box("Skirting",Vector3((10+params.cylinder_end)/2,-.80,sign_z*8.025),Vector3(params.cylinder_end-10,.24,.04),metal)
		box("Cove",Vector3((10+params.cylinder_end)/2,1.82,sign_z*8.04),Vector3(params.cylinder_end-10,.08,.08),warm)
	FileAccess.open("res://../dressing-manifest.json",FileAccess.WRITE).store_string(JSON.stringify(objects,"  "))

func coat(node: Node) -> void:
	if node is MeshInstance3D:
		var title := str(node.name)
		if title.begins_with("Guide_Light"):
			node.visible = false
		elif title.begins_with("Guide_Exterior"):
			# Legacy collision/lining meshes must not stamp their old silhouette
			# onto the new exterior through the coarse directional shadow map.
			var finish := StandardMaterial3D.new()
			finish.albedo_color = Color(.68,.73,.75)
			finish.metallic = .35
			finish.roughness = .48
			finish.disable_receive_shadows = true
			node.material_override = finish
		elif title.begins_with("Cockpit_transition"):
			node.visible = false
		elif title.begins_with("Hull_") or title.begins_with("Cockpit_") or title == "Cylinder_upper" or title == "Cylinder_lower" or title == "Living_roof" or title == "Hangar_roof" or title == "Continuous_deck" or title.ends_with("_upper_seal"):
			# The generator assigns exterior and interior materials per surface.
			if not title.begins_with("Cockpit_"):
				for i in node.mesh.get_surface_count():
					var source = node.mesh.surface_get_material(i)
					if source != null and source.resource_name == "Exterior_Satin":
						var hidden := StandardMaterial3D.new()
						hidden.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
						hidden.albedo_color = Color(0,0,0,0)
						node.set_surface_override_material(i,hidden)
		elif not title.begins_with("Glass_"):
			var mat = surface_material.duplicate()
			mat.set_shader_parameter("threshold",title.begins_with("Guide_Threshold"))
			node.material_override = mat
	for child in node.get_children():
		coat(child)

func box(title: String, at: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = title
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = mat
	node.position = at
	add_child(node)
	return node

func bounds(node: Node3D, transform: Transform3D = Transform3D.IDENTITY) -> AABB:
	var result := AABB()
	var current := transform * node.transform
	if node is MeshInstance3D:
		result = current * node.get_aabb()
	for child in node.get_children():
		if child is Node3D:
			var b := bounds(child,current)
			if b.size.length()>0:
				result = b if result.size.length()==0 else result.merge(b)
	return result

func recolor(node: Node) -> void:
	if node is MeshInstance3D:
		for i in node.mesh.get_surface_count():
			var source = node.get_active_material(i)
			var title := str(source.resource_name).to_lower()
			var mat: Material = ivory
			if source is StandardMaterial3D and source.albedo_texture != null:
				var detail := ShaderMaterial.new()
				detail.shader = load("res://asset_palette.gdshader")
				detail.set_shader_parameter("atlas",source.albedo_texture)
				node.set_surface_override_material(i,detail)
				continue
			if title.contains("carpet"):
				mat = ivory if title.contains("white") else accent
			elif title.contains("dark") or title.contains("glass"):
				mat = dark
			elif title.contains("metal"):
				mat = ivory if title.contains("light") else metal
			elif title.contains("lamp"):
				mat = warm
			node.set_surface_override_material(i,mat)
	for child in node.get_children():
		recolor(child)

func asset(path: String, at: Vector3, size: Vector3, yaw: float = 0, collide: bool = true) -> Node3D:
	var holder := Node3D.new()
	holder.name = path.get_file()
	add_child(holder)
	var model: Node3D = load("res://assets/"+path+".glb").instantiate()
	holder.add_child(model)
	var b := bounds(model)
	var factor := size / b.size
	model.scale *= factor
	model.position -= Vector3(b.get_center().x,b.position.y,b.get_center().z)*factor
	recolor(model)
	holder.position = at
	holder.rotation.y = yaw
	if collide:
		var body := StaticBody3D.new()
		var shape := CollisionShape3D.new()
		var cuboid := BoxShape3D.new()
		cuboid.size = size
		shape.shape = cuboid
		shape.position.y = size.y/2
		body.add_child(shape)
		holder.add_child(body)
	objects.append({"asset":path,"position":[at.x,at.y,at.z],"size":[size.x,size.y,size.z],"yaw":yaw,"collision":collide})
	return holder

func dress_cabin(cabin: Dictionary) -> void:
	var sign_z := 1.0 if str(cabin.id).begins_with("U") else -1.0
	var lo := 1000.0
	var hi := -1000.0
	for p in cabin.polygon:
		lo = minf(lo,p[0])
		hi = maxf(hi,p[0])
	# Furniture stays in the rectangular portion even for the tapered cabins.
	lo = maxf(lo,16.0)
	var floor_y: float = params.floor
	var opening: Array = cabin.opening
	var center: float = (opening[0]+opening[1])/2
	var width: float = opening[1]-opening[0]
	# Access frames and switches were legacy corridor-facing props.  The pilot
	# kit now supplies the only frame around each existing opening.
	asset("station/display-wall",Vector3(hi-.8,.4,sign_z*15.91),Vector3(.65,.48,.10),PI if sign_z>0 else 0,false)
	# Keep the existing entry-to-centre test path and a generous central aisle clear.
	asset("furniture/bedDouble",Vector3(hi-1.4,floor_y,sign_z*14.55),Vector3(1.65,.75,2.15),0)
	asset("furniture/bookcaseClosedDoors",Vector3(lo+.65,floor_y,sign_z*11.75),Vector3(.9,2.05,.48),PI/2)
	asset("furniture/kitchenSink",Vector3(lo+1.0,floor_y,sign_z*15.5),Vector3(.75,1.0,.65),PI if sign_z>0 else 0)
	asset("furniture/kitchenStoveElectric",Vector3(lo+1.78,floor_y,sign_z*15.5),Vector3(.75,.9,.65),PI if sign_z>0 else 0)
	asset("furniture/kitchenFridgeSmall",Vector3(lo+2.56,floor_y,sign_z*15.5),Vector3(.65,.9,.65),PI if sign_z>0 else 0)
	asset("furniture/tableRound",Vector3(hi-1.5,floor_y,sign_z*11.6),Vector3(1.05,.75,1.05),0)
	asset("furniture/chairModernCushion",Vector3(hi-2.6,floor_y,sign_z*11.6),Vector3(.52,.9,.55),PI/2)

func frame(x: float, z: float, width: float) -> void:
	var model: Node3D = load("res://assets/station/"+("frame_standard" if width<1.3 else "frame_stretched")+".glb").instantiate()
	add_child(model)
	model.position = Vector3(x,params.floor,z)
	frame_material(model)
	objects.append({"asset":"station/door-single","adapted":"crossbar removed, soft edges, clear opening preserved","position":[x,params.floor,z],"clear_width":width,"collision":false})

func frame_material(node: Node) -> void:
	if node is MeshInstance3D:
		node.material_override = metal
	for child in node.get_children():
		frame_material(child)

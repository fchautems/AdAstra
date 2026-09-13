extends Node3D

# Original, parametric corridor finish.  It remains an overlay on the GLB.
const CORRIDOR_START := 10.0
const CORRIDOR_END := 47.0
var installed: Array[String] = []
var module_parent: Node3D
var params: Dictionary

func module(title: String) -> void:
	module_parent = Node3D.new()
	module_parent.name = title
	add_child(module_parent)

func finish(color: String, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color)
	material.roughness = roughness
	material.metallic = metallic
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return material

func setup(old: Node3D, ship: Node3D, data: Dictionary) -> void:
	params = data
	get_viewport().msaa_3d = Viewport.MSAA_4X
	name = "Pilot5m"
	remove_previous_dressing(old)
	remove_guide_threshold(ship)
	var ivory := surface("e9e7df", .55)
	var ceiling := finish("eae8e0", .75)
	# Soft graphite keeps the dark language without reading as black cut-outs.
	var graphite := finish("606b6e", .50)
	var floor_finish := surface("d9d8d1", .32, true)
	var aluminium := finish("a2a5a3", .36, 1.0)
	var glow := finish("fff8ef", .86)
	glow.emission_enabled = true
	glow.emission = Color("fff3df")
	glow.emission_energy_multiplier = 1.3

	# The same validated kit is repeated only in the three existing corridors.
	# Cockpit, hangar and cabin interiors are deliberately outside these bounds.
	var upper_doors := cabin_doors(1.0)
	var lower_doors := cabin_doors(-1.0)
	corridor_module("Upper", 9.0, 8.036, 9.964, -1.0, 1.0, upper_doors, floor_finish, ceiling, ivory, graphite, aluminium, glow)
	corridor_module("Lower", -9.0, -8.036, -9.964, 1.0, -1.0, lower_doors, floor_finish, ceiling, ivory, graphite, aluminium, glow)
	corridor_module("Central", 0.0, -.964, .964, 1.0, -1.0, [], floor_finish, ceiling, ivory, graphite, aluminium, glow)
	installed = [
		"Original ivory composite wall panels",
		"Original graphite satin floor finish",
		"Original integrated cove light",
		"Original full wall panel and inset wall panel",
		"Original rounded access frames, flush floor transitions, base trim and ceiling bays"
	]
	FileAccess.open("res://../pilot-assets.json", FileAccess.WRITE).store_string(JSON.stringify(installed, "  "))

func remove_previous_dressing(old: Node3D) -> void:
	for node in old.get_children():
		if not node is Node3D:
			continue
		var p: Vector3 = node.position
		# Remove the old corridor-only dressing, never cabin furniture or end areas.
		var in_living_corridor := p.x >= CORRIDOR_START and p.x <= CORRIDOR_END and absf(p.z) <= 10.2
		if in_living_corridor and (str(node.name).begins_with("WallTrim") or str(node.name).begins_with("Skirting") or str(node.name).begins_with("Cove") or str(node.name).begins_with("Diffuser") or str(node.name).begins_with("lampSquareCeiling") or str(node.name).begins_with("frame_")):
			node.hide()

func cabin_doors(sign_z: float) -> Array:
	var doors: Array = []
	for cabin in params.cabins:
		var is_upper := str(cabin.id).begins_with("U")
		if (sign_z > 0.0) != is_upper:
			continue
		var opening: Array = cabin.opening
		doors.append({"center":(float(opening[0])+float(opening[1]))/2.0,"width":float(opening[1])-float(opening[0])})
	return doors

func corridor_module(title: String, center_z: float, inner_face: float, outer_face: float, inner_side: float, outer_side: float, doors: Array, floor_finish: Material, ceiling: Material, ivory: Material, graphite: Material, aluminium: Material, glow: Material) -> void:
	module(title+"Floor")
	box("CorridorFloor",Vector3((CORRIDOR_START+CORRIDOR_END)/2.0,-.977,center_z),Vector3(CORRIDOR_END-CORRIDOR_START,.018,2),floor_finish)
	module(title+"Ceiling")
	box("CorridorCeiling",Vector3((CORRIDOR_START+CORRIDOR_END)/2.0,2.014,center_z),Vector3(CORRIDOR_END-CORRIDOR_START,.035,2),ceiling)
	wall_panels(Vector2(CORRIDOR_START,CORRIDOR_END),inner_face,inner_side,ivory,graphite,glow,title+"Inner")
	for span in wall_spans(doors):
		wall_panels(span,outer_face,outer_side,ivory,graphite,glow,title+"Outer")
	ceiling_modules(center_z,ceiling,ivory,graphite,glow,title)
	for door in doors:
		door_module(float(door.center),float(door.width),outer_face,aluminium,ivory,graphite)
	add_lighting(center_z,title)

func wall_spans(doors: Array) -> Array:
	var spans: Array = []
	var start := CORRIDOR_START
	for door in doors:
		var edge := float(door.center)-(float(door.width)/2.0+.14)
		if edge-start > .05:
			spans.append(Vector2(start,edge))
		start = float(door.center)+(float(door.width)/2.0+.14)
	if CORRIDOR_END-start > .05:
		spans.append(Vector2(start,CORRIDOR_END))
	return spans

func wall_panels(span: Vector2, z: float, side: float, ivory: Material, graphite: Material, glow: Material, title: String) -> void:
	module(title+"Wall_"+str(snapped(span.x,.01)))
	var face_z := z
	var x := span.x
	while x < span.y:
		var width: float = minf(.997, span.y - x - .003)
		if width < .05:
			break
		var center := x + width / 2.0
		plate("UpperPanel",Vector3(center,.91,face_z),Vector2(width,1.60),.055,.012,ivory,side)
		plate("LowerPanel",Vector3(center,-.45,face_z),Vector2(width,.60),.055,.010,ivory,side)
		plate("Inset",Vector3(center,-.025,face_z-side*.004),Vector2(width-.13,.19),.045,.006,graphite,side)
		x += 1.0
	wall_box("BaseTrim",Vector3((span.x+span.y)/2,-.87,face_z),Vector2(span.y-span.x,.20),.014,side,graphite)
	wall_box("WaistDiffuser",Vector3((span.x+span.y)/2,.105,face_z),Vector2(span.y-span.x-.025,.018),.006,side,glow)
	# Solid wall proxy casts stable shadows; thin decorative faces do not self-shadow.
	box("WallOccluder",Vector3((span.x+span.y)/2,.5,face_z+side*.075),Vector3(span.y-span.x,3,.08),ivory)
	var occluder := module_parent.get_child(module_parent.get_child_count()-1) as MeshInstance3D
	occluder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY

func ceiling_modules(center_z: float, ceiling: Material, ivory: Material, graphite: Material, glow: Material, title: String) -> void:
	module(title+"CeilingBays")
	var bay := 1.25
	var count := int(ceil((CORRIDOR_END-CORRIDOR_START)/bay))
	for i in range(count):
		var left := CORRIDOR_START+float(i)*bay
		var width := minf(bay,CORRIDOR_END-left)
		box("CeilingPanel",Vector3(left+width/2.0,1.981,center_z),Vector3(width-.004,.035,1.80),ceiling)
		if i>0:
			box("CeilingJoint",Vector3(left,1.965,center_z),Vector3(.003,.008,1.80),graphite)
	module(title+"JunctionAndLight")
	for side in [-1.0,1.0]:
		var z: float = center_z+float(side)*.93
		box("CeilingFascia",Vector3((CORRIDOR_START+CORRIDOR_END)/2.0,1.875,z),Vector3(CORRIDOR_END-CORRIDOR_START,.245,.10),ivory)
		box("LightRecess",Vector3((CORRIDOR_START+CORRIDOR_END)/2.0,1.84,z-side*.058),Vector3(CORRIDOR_END-CORRIDOR_START,.052,.012),graphite)
		box("ContinuousDiffuser",Vector3((CORRIDOR_START+CORRIDOR_END)/2.0,1.84,z-side*.065),Vector3(CORRIDOR_END-CORRIDOR_START-.03,.026,.012),glow)
	module(title+"CeilingLuminaires")
	for x in range(12,47,5):
		box("RecessedHousing",Vector3(x,1.948,center_z),Vector3(.80,.038,.25),graphite)
		box("Diffuser",Vector3(x,1.925,center_z),Vector3(.74,.012,.19),glow)

func door_module(center_x: float, opening_width: float, z: float, aluminium: Material, ivory: Material, graphite: Material) -> void:
	module("OpeningFrame_"+str(snapped(center_x,.01)))
	# Leave the original wall exposed between the curved trim and ceiling fascia.
	# Its vertical inner edge remains outside X=19.9..21.1.
	var outer_half := opening_width/2.0+.14
	var curve_x := outer_half-.25
	var path := PackedVector2Array([Vector2(-outer_half,-.98),Vector2(-outer_half,1.35)])
	for i in range(17):
		var angle := PI - float(i)*PI/32.0
		path.append(Vector2(-curve_x,1.35)+Vector2(cos(angle),sin(angle))*.25)
	path.append(Vector2(curve_x,1.60))
	for i in range(17):
		var angle := PI/2.0-float(i)*PI/32.0
		path.append(Vector2(curve_x,1.35)+Vector2(cos(angle),sin(angle))*.25)
	path.append(Vector2(outer_half,-.98))
	# Every layer references the same wall face; only 14–25 mm of intentional relief remains.
	var direction := 1.0 if z > 0.0 else -1.0
	strip(path,center_x,.20,z-direction*.014,graphite,z)
	strip(path,center_x,.170,z-direction*.018,ivory,z-direction*.014)
	strip(path,center_x,.115,z-direction*.022,ivory,z-direction*.018)
	strip(path,center_x,.006,z-direction*.025,aluminium,z-direction*.022)
	assert(outer_half-.10 >= opening_width/2.0, "Frame reduces opening")

func add_lighting(center_z: float, title: String) -> void:
	module(title+"Lighting")
	for x in range(12,47,5):
		var light := SpotLight3D.new()
		light.name = "PilotCoveLight"
		light.position = Vector3(x, 1.89, center_z)
		light.rotation_degrees.x = -90
		light.spot_range = 3.5
		light.spot_angle = 72
		light.spot_attenuation = .45
		light.light_cull_mask = 2
		light.light_color = Color("fff8ef")
		light.light_energy = .32
		light.shadow_enabled = true
		light.shadow_bias = .08
		light.shadow_normal_bias = .02
		module_parent.add_child(light)
	var probe := ReflectionProbe.new()
	probe.position = Vector3((CORRIDOR_START+CORRIDOR_END)/2.0, .45, center_z)
	probe.size = Vector3(CORRIDOR_END-CORRIDOR_START, 3, 2)
	probe.interior = true
	probe.box_projection = true
	probe.ambient_mode = ReflectionProbe.AMBIENT_COLOR
	probe.ambient_color = Color("e9e6df")
	probe.ambient_color_energy = .45
	probe.intensity = .45
	module_parent.add_child(probe)

func box(title: String, at: Vector3, size: Vector3, material: Material, rotation: Vector3 = Vector3.ZERO) -> void:
	var node := MeshInstance3D.new()
	node.name = title
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = material
	node.position = at
	node.rotation = rotation
	node.layers = 2
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	module_parent.add_child(node)

func wall_box(title: String, at: Vector3, size: Vector2, relief: float, side: float, material: Material) -> void:
	# at.z is the structural interior face; the box grows only into the corridor.
	at.z -= side * relief / 2.0
	box(title,at,Vector3(size.x,size.y,relief),material)

func surface(color: String, roughness: float, is_floor: bool = false) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://pilot_surface.gdshader")
	mat.set_shader_parameter("tint",Color(color))
	mat.set_shader_parameter("roughness_value",roughness)
	mat.set_shader_parameter("floor_surface",is_floor)
	return mat

# Rounded face with a sloping perimeter bevel; side controls which wall faces inward.
func plate(title: String, at: Vector3, size: Vector2, radius: float, bevel: float, mat: Material, side: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	var outer := PackedVector3Array()
	var inner := PackedVector3Array()
	for c in range(4):
		var angle0 := float(c)*PI/2.0
		var center := Vector2((size.x/2-radius)*(1.0 if c==0 or c==3 else -1.0),(size.y/2-radius)*(1.0 if c<2 else -1.0))
		for j in range(9):
			var a := angle0+float(j)*PI/16.0
			var d := Vector2(cos(a),sin(a))
			outer.append(Vector3(center.x+d.x*radius,center.y+d.y*radius,side*bevel))
			inner.append(Vector3(center.x+d.x*(radius-bevel),center.y+d.y*(radius-bevel),0))
	for i in outer.size():
		var n := (i+1)%outer.size()
		for v in [Vector3.ZERO,inner[i],inner[n],inner[i],outer[i],outer[n],inner[i],outer[n],inner[n]]:
			st.add_vertex(v)
	st.generate_normals()
	var node := MeshInstance3D.new()
	node.name = title
	node.mesh = st.commit()
	node.position = at
	node.material_override = mat
	# Both walls share this mesh; use double sided material, normals corrected by renderer.
	if mat is StandardMaterial3D:
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	node.layers = 2
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	module_parent.add_child(node)

func strip(points: PackedVector2Array, center_x: float, width: float, z: float, mat: Material, support_z: float) -> void:
	# Shared tangent at arc endpoints prevents cracks between straight and curved trims.
	var path := PackedVector2Array()
	for point in points:
		if path.is_empty() or path[path.size()-1].distance_to(point)>.0001:
			path.append(point)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	var offsets := PackedVector2Array()
	for i in path.size():
		var before := (path[i]-path[maxi(0,i-1)]).normalized()
		var after := (path[mini(path.size()-1,i+1)]-path[i]).normalized()
		var tangent := (before+after).normalized()
		offsets.append(Vector2(-tangent.y,tangent.x)*width/2)
	for i in range(path.size()-1):
		if path[i].distance_to(path[i+1]) < .0001:
			continue
		var a := path[i]+offsets[i]
		var b := path[i]-offsets[i]
		var c := path[i+1]+offsets[i+1]
		var d := path[i+1]-offsets[i+1]
		for p in [a,b,c,b,d,c]:
			st.add_vertex(Vector3(p.x+center_x,p.y,z))
		# Close both edges back to the supporting wall, including the curved head.
		var rear := support_z
		for edge in [[a,c],[d,b]]:
			var u: Vector2 = edge[0]
			var v: Vector2 = edge[1]
			for vertex in [Vector3(u.x+center_x,u.y,z),Vector3(v.x+center_x,v.y,z),Vector3(u.x+center_x,u.y,rear),Vector3(v.x+center_x,v.y,z),Vector3(v.x+center_x,v.y,rear),Vector3(u.x+center_x,u.y,rear)]:
				st.add_vertex(vertex)
	st.generate_normals()
	var node := MeshInstance3D.new()
	node.name = "RoundedAccessFrame"
	node.mesh = st.commit()
	node.material_override = mat
	node.layers = 2
	if mat is StandardMaterial3D:
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	module_parent.add_child(node)

func remove_guide_threshold(node: Node) -> void:
	if node is MeshInstance3D and str(node.name).begins_with("Guide_Threshold"):
		var bounds: AABB = node.global_transform * node.get_aabb()
		if bounds.get_center().x>CORRIDOR_START and bounds.get_center().x<CORRIDOR_END:
			node.hide()
	for child in node.get_children():
		remove_guide_threshold(child)

extends CharacterBody3D

signal footstep_requested

var camera: Camera3D
var cfg: Dictionary
var spawn_point: Vector3
var frozen := false
var automated := false
var test_direction := Vector3.ZERO
var step_distance := 0.0

func setup(config: Dictionary, spawn: Vector3) -> void:
	cfg = config
	spawn_point = spawn
	var shape := CapsuleShape3D.new()
	shape.radius = cfg.player_radius_m
	shape.height = cfg.player_height_m
	var collider := CollisionShape3D.new()
	collider.shape = shape
	collider.position.y = shape.height / 2.0
	add_child(collider)
	camera = Camera3D.new()
	camera.position.y = cfg.eye_height_m
	camera.near = 0.04
	camera.far = 300.0
	camera.fov = 72.0
	add_child(camera)
	floor_snap_length = 0.2
	safe_margin = 0.005
	reset()

func reset() -> void:
	position = spawn_point
	rotation.y = -PI/2
	camera.rotation.x = 0
	velocity = Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not frozen:
		rotate_y(-event.relative.x * cfg.mouse_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x-event.relative.y*cfg.mouse_sensitivity,-1.48,1.48)

func _physics_process(delta: float) -> void:
	if frozen:
		return
	var direction := test_direction if automated else Vector3.ZERO
	if not automated and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var axis := Input.get_vector("left","right","forward","back")
		direction = (basis * Vector3(axis.x,0,axis.y)).normalized()
	var speed: float = cfg.run_speed_m_s if Input.is_action_pressed("run") else cfg.walk_speed_m_s
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0
	move_and_slide()
	var planar_speed := Vector2(velocity.x,velocity.z).length()
	if is_on_floor() and planar_speed > .15:
		step_distance += planar_speed * delta
		var interval := 1.05 if Input.is_action_pressed("run") else 1.42
		if step_distance >= interval:
			step_distance = 0.0
			footstep_requested.emit()
	else:
		step_distance = minf(step_distance,.5)
	if position.y < spawn_point.y - 20:
		reset()

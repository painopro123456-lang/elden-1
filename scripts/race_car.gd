extends CharacterBody3D
class_name RaceCar

signal telemetry_changed(speed_kph: float)

const ACCELERATION := 34.0
const BRAKING := 58.0
const MAX_SPEED := 92.0
const REVERSE_SPEED := 12.0
const DRAG := 8.0
const STEER_RATE := 1.65

var speed := 0.0
var steering := 0.0

func _ready() -> void:
	floor_snap_length = 0.5
	floor_max_angle = deg_to_rad(55)
	_build_temporary_car_visual()

func _physics_process(delta: float) -> void:
	var throttle := Input.get_action_strength("accelerate") - Input.get_action_strength("brake")
	var steer_input := Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	if throttle > 0.0:
		speed = move_toward(speed, MAX_SPEED, ACCELERATION * throttle * delta)
	elif throttle < 0.0:
		if speed > 1.0:
			speed = move_toward(speed, 0.0, BRAKING * -throttle * delta)
		else:
			speed = move_toward(speed, -REVERSE_SPEED, ACCELERATION * -throttle * delta)
	else:
		speed = move_toward(speed, 0.0, DRAG * delta)
	var steer_limit := clampf(absf(speed) / 18.0, 0.0, 1.0)
	steering = move_toward(steering, steer_input, 4.0 * delta)
	rotation.y -= steering * STEER_RATE * steer_limit * signf(speed) * delta
	var forward := -global_transform.basis.z
	velocity.x = forward.x * speed
	velocity.z = forward.z * speed
	velocity.y -= 24.0 * delta
	move_and_slide()
	telemetry_changed.emit(absf(speed) * 3.6)

func _build_temporary_car_visual() -> void:
	var red := _material(Color("#d91f2b"), 0.35, 0.25)
	var carbon := _material(Color("#11151b"), 0.2, 0.65)
	var rubber := _material(Color("#090a0c"), 0.0, 0.92)
	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(1.75, 0.38, 3.5)
	body.mesh = body_mesh
	body.position.y = 0.48
	body.material_override = red
	add_child(body)
	var nose := MeshInstance3D.new()
	var nose_mesh := BoxMesh.new()
	nose_mesh.size = Vector3(0.72, 0.22, 2.0)
	nose.mesh = nose_mesh
	nose.position = Vector3(0, 0.5, -2.15)
	nose.material_override = red
	add_child(nose)
	var cockpit := MeshInstance3D.new()
	var cockpit_mesh := BoxMesh.new()
	cockpit_mesh.size = Vector3(0.72, 0.42, 0.9)
	cockpit.mesh = cockpit_mesh
	cockpit.position = Vector3(0, 0.83, -0.15)
	cockpit.material_override = carbon
	add_child(cockpit)
	var front_wing := MeshInstance3D.new()
	var wing_mesh := BoxMesh.new()
	wing_mesh.size = Vector3(3.0, 0.12, 0.55)
	front_wing.mesh = wing_mesh
	front_wing.position = Vector3(0, 0.28, -3.05)
	front_wing.material_override = carbon
	add_child(front_wing)
	var rear_wing := MeshInstance3D.new()
	var rear_mesh := BoxMesh.new()
	rear_mesh.size = Vector3(2.35, 0.14, 0.48)
	rear_wing.mesh = rear_mesh
	rear_wing.position = Vector3(0, 1.02, 1.48)
	rear_wing.material_override = carbon
	add_child(rear_wing)
	for x in [-1.02, 1.02]:
		for z in [-2.0, 1.45]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.48
			wheel_mesh.bottom_radius = 0.48
			wheel_mesh.height = 0.34
			wheel_mesh.radial_segments = 20
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(x, 0.42, z)
			wheel.rotation.z = PI * 0.5
			wheel.material_override = rubber
			add_child(wheel)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.9, 0.8, 3.8)
	collision.shape = shape
	collision.position.y = 0.48
	add_child(collision)

func _material(color: Color, metallic_value: float, roughness_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic_value
	material.roughness = roughness_value
	return material

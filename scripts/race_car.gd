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
var team_name := "Ferrari"
var team_color := Color("#dc0000")

func _ready() -> void:
	floor_snap_length = 0.5
	floor_max_angle = deg_to_rad(55)
	team_name = str(get_tree().root.get_meta("selected_team", "Ferrari"))
	team_color = _team_color(team_name)
	_build_race_car_visual()

func _physics_process(delta: float) -> void:
	var throttle := float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)) - float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))
	var steer_input := float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
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

func _team_color(name: String) -> Color:
	var colors := {
		"Ferrari": "#dc0000",
		"McLaren": "#ff8700",
		"Mercedes": "#00d2be",
		"Red Bull Racing": "#2447a8",
		"Aston Martin": "#006f62",
		"Williams": "#005aff",
		"Alpine": "#0090ff",
		"Haas": "#e6e9ed",
		"Racing Bulls": "#6692ff",
		"Audi": "#ed1c24",
		"Cadillac": "#c7a96b"
	}
	return Color(colors.get(name, "#dc0000"))

func _material(color: Color, metallic_value: float = 0.0, roughness_value: float = 0.45) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic_value
	material.roughness = roughness_value
	return material

func _box(name: String, dimensions: Vector3, position: Vector3, material: Material, bevel: float = 0.0) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	mesh.subdivide_width = 1
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	add_child(instance)
	return instance

func _build_race_car_visual() -> void:
	var paint := _material(team_color, 0.58, 0.28)
	var paint_light := _material(team_color.lightened(0.22), 0.48, 0.3)
	var carbon := _material(Color("#111820"), 0.32, 0.52)
	var carbon_dark := _material(Color("#080c11"), 0.18, 0.72)
	var rubber := _material(Color("#090b0e"), 0.0, 0.96)
	var rim := _material(Color("#aab4bf"), 0.82, 0.25)
	var glass := _material(Color("#172a3b"), 0.65, 0.16)
	var accent := _material(Color("#f1f3f5"), 0.35, 0.34)

	# Low, tapered central chassis and long nose.
	_box("FloorAndPlank", Vector3(1.62, 0.16, 4.2), Vector3(0, 0.22, -0.05), carbon_dark)
	_box("MainBody", Vector3(1.35, 0.36, 2.55), Vector3(0, 0.49, 0.12), paint)
	_box("TaperedNose", Vector3(0.62, 0.20, 2.15), Vector3(0, 0.50, -2.08), paint_light)
	_box("NoseTip", Vector3(0.28, 0.13, 0.75), Vector3(0, 0.52, -3.34), paint)
	_box("CockpitSurround", Vector3(0.82, 0.19, 0.95), Vector3(0, 0.70, -0.42), carbon)
	_box("CockpitGlass", Vector3(0.54, 0.29, 0.55), Vector3(0, 0.83, -0.52), glass)
	_box("EngineCover", Vector3(0.68, 0.43, 1.42), Vector3(0, 0.72, 0.82), paint)

	# Sculpted sidepods, inlets and floor edge details.
	for side in [-1.0, 1.0]:
		_box("Sidepod", Vector3(0.58, 0.42, 1.52), Vector3(side * 0.84, 0.46, 0.35), paint)
		_box("SidepodInlet", Vector3(0.09, 0.23, 0.52), Vector3(side * 1.14, 0.60, -0.08), carbon_dark)
		_box("FloorEdge", Vector3(0.12, 0.10, 3.2), Vector3(side * 0.82, 0.25, -0.1), carbon)
		_box("Mirror", Vector3(0.20, 0.10, 0.16), Vector3(side * 0.73, 0.91, -0.85), paint_light)

	# Front and rear wings with endplates and supports.
	_box("FrontWingMainPlane", Vector3(3.35, 0.13, 0.48), Vector3(0, 0.27, -3.48), carbon)
	_box("FrontWingFlap", Vector3(3.12, 0.07, 0.22), Vector3(0, 0.42, -3.40), paint)
	_box("RearWingMainPlane", Vector3(2.45, 0.13, 0.42), Vector3(0, 1.10, 1.72), carbon)
	_box("RearWingUpperPlane", Vector3(2.28, 0.10, 0.34), Vector3(0, 1.55, 1.78), paint)
	for side in [-1.0, 1.0]:
		_box("FrontWingEndplate", Vector3(0.10, 0.36, 0.62), Vector3(side * 1.62, 0.43, -3.42), paint)
		_box("RearWingEndplate", Vector3(0.12, 0.72, 0.52), Vector3(side * 1.18, 1.26, 1.74), paint)
		_box("RearWingSupport", Vector3(0.10, 0.72, 0.10), Vector3(side * 0.30, 0.88, 1.56), carbon)

	# Four wide slicks with metallic hubs and subtle sidewall rings.
	for x in [-1.12, 1.12]:
		for z in [-2.10, 1.42]:
			var wheel := MeshInstance3D.new()
			wheel.name = "SlickTyre"
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.49
			wheel_mesh.bottom_radius = 0.49
			wheel_mesh.height = 0.38
			wheel_mesh.radial_segments = 32
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(x, 0.44, z)
			wheel.rotation.z = PI * 0.5
			wheel.material_override = rubber
			add_child(wheel)
			var hub := MeshInstance3D.new()
			var hub_mesh := CylinderMesh.new()
			hub_mesh.top_radius = 0.22
			hub_mesh.bottom_radius = 0.22
			hub_mesh.height = 0.395
			hub_mesh.radial_segments = 24
			hub.mesh = hub_mesh
			hub.position = Vector3(x, 0.44, z)
			hub.rotation.z = PI * 0.5
			hub.material_override = rim
			add_child(hub)

	# Halo hoop and central support.
	var halo := MeshInstance3D.new()
	var halo_mesh := TorusMesh.new()
	halo_mesh.inner_radius = 0.28
	halo_mesh.outer_radius = 0.34
	halo_mesh.rings = 12
	halo_mesh.ring_segments = 24
	halo.mesh = halo_mesh
	halo.position = Vector3(0, 1.12, -0.34)
	halo.rotation.x = PI * 0.5
	halo.material_override = carbon
	add_child(halo)
	_box("HaloFrontLeg", Vector3(0.08, 0.40, 0.08), Vector3(0, 1.00, -0.62), carbon)
	_box("Airbox", Vector3(0.38, 0.34, 0.42), Vector3(0, 1.14, 0.56), carbon)

	# Team stripe and number plate add definition at T-cam distance.
	_box("NoseStripe", Vector3(0.10, 0.025, 2.15), Vector3(0, 0.615, -2.12), accent)
	_box("EngineCoverStripe", Vector3(0.10, 0.025, 1.18), Vector3(0, 0.95, 0.82), accent)
	_box("RearDiffuser", Vector3(1.32, 0.16, 0.54), Vector3(0, 0.18, 1.95), carbon)
	_box("FrontSuspensionLeft", Vector3(0.08, 0.08, 1.12), Vector3(-0.78, 0.47, -1.80), carbon)
	_box("FrontSuspensionRight", Vector3(0.08, 0.08, 1.12), Vector3(0.78, 0.47, -1.80), carbon)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.05, 0.92, 4.05)
	collision.shape = shape
	collision.position.y = 0.48
	add_child(collision)

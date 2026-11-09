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
var rolling_wheels: Array[Node3D] = []

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
	var wheel_rotation := speed * delta / 0.49
	for wheel_part in rolling_wheels:
		if is_instance_valid(wheel_part):
			wheel_part.rotate_object_local(Vector3.UP, wheel_rotation)
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

func _add_tapered_mesh(mesh_name: String, sections: Array, material: Material, side: float = 0.0) -> void:
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	for section in sections:
		var z := float(section[0])
		var y := float(section[1])
		var half_width := float(section[2])
		var half_height := float(section[3])
		var x_offset := side * 0.84
		vertices.append(Vector3(x_offset - half_width, y - half_height * 0.72, z))
		vertices.append(Vector3(x_offset + half_width, y - half_height * 0.72, z))
		vertices.append(Vector3(x_offset + half_width * 0.78, y + half_height, z))
		vertices.append(Vector3(x_offset - half_width * 0.78, y + half_height, z))
	for ring in range(sections.size() - 1):
		var a := ring * 4
		var b := (ring + 1) * 4
		for corner in range(4):
			var next_corner := (corner + 1) % 4
			indices.append_array(PackedInt32Array([a + corner, a + next_corner, b + corner, a + next_corner, b + next_corner, b + corner]))
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in indices:
		surface.add_vertex(vertices[index])
	surface.generate_normals()
	var mesh := surface.commit()
	var instance := MeshInstance3D.new()
	instance.name = mesh_name
	instance.mesh = mesh
	instance.material_override = material
	add_child(instance)

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
	_add_tapered_mesh("CarbonFloor", [[-3.72,0.16,0.48,0.30],[-2.85,0.16,0.72,0.42],[-1.75,0.16,0.84,0.48],[0.90,0.16,0.91,0.48],[2.15,0.16,0.73,0.38]], carbon_dark)
	_add_tapered_mesh("SculptedMonocoque", [[-3.72,0.36,0.12,0.16],[-2.85,0.40,0.27,0.24],[-1.70,0.43,0.57,0.31],[-0.65,0.44,0.68,0.35],[0.72,0.43,0.68,0.35],[1.65,0.40,0.47,0.30],[2.15,0.38,0.30,0.24]], paint)
	_add_tapered_mesh("EngineCover", [[-0.10,0.67,0.30,0.27],[0.55,0.72,0.39,0.40],[1.20,0.73,0.34,0.40],[1.80,0.60,0.22,0.30]], paint_light)
	_box("CockpitSurround", Vector3(0.80,0.13,0.88), Vector3(0,0.73,-0.42), carbon)
	_add_tapered_mesh("CockpitGlass", [[-0.98,0.79,0.12,0.12],[-0.65,0.96,0.27,0.18],[-0.22,0.96,0.24,0.18],[0.02,0.79,0.12,0.12]], glass)

	# Sculpted sidepods, inlets and floor edge details.
	for side in [-1.0, 1.0]:
		_add_tapered_mesh("SculptedSidepod", [[-0.62,0.42,0.12,0.15],[-0.20,0.47,0.28,0.25],[0.55,0.47,0.32,0.27],[1.15,0.43,0.22,0.18]], paint, side)
		_box("SidepodInlet", Vector3(0.055,0.20,0.48), Vector3(side*1.105,0.60,-0.12), carbon_dark)
		_box("FloorEdge", Vector3(0.10,0.09,3.35), Vector3(side*0.91,0.24,-0.12), carbon)
		_box("Mirror", Vector3(0.18,0.08,0.14), Vector3(side*0.70,0.91,-0.88), paint_light)
		_box("SidepodLiveryStripe", Vector3(0.025,0.035,1.12), Vector3(side*1.12,0.48,0.28), accent)

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
			rolling_wheels.append(wheel)
			var sidewall := MeshInstance3D.new()
			var sidewall_mesh := TorusMesh.new()
			sidewall_mesh.inner_radius = 0.435
			sidewall_mesh.outer_radius = 0.475
			sidewall_mesh.rings = 12
			sidewall_mesh.ring_segments = 32
			sidewall.mesh = sidewall_mesh
			sidewall.position = Vector3(x + signf(x) * 0.195, 0.44, z)
			sidewall.rotation.z = PI * 0.5
			sidewall.material_override = _material(Color("#30343a"), 0.0, 0.9)
			add_child(sidewall)
			rolling_wheels.append(sidewall)
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
			rolling_wheels.append(hub)
			var hub_cap := MeshInstance3D.new()
			var cap_mesh := CylinderMesh.new()
			cap_mesh.top_radius = 0.105
			cap_mesh.bottom_radius = 0.105
			cap_mesh.height = 0.405
			cap_mesh.radial_segments = 20
			hub_cap.mesh = cap_mesh
			hub_cap.position = Vector3(x, 0.44, z)
			hub_cap.rotation.z = PI * 0.5
			hub_cap.material_override = paint_light
			add_child(hub_cap)
			rolling_wheels.append(hub_cap)

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
	_box("FrontSuspensionRight", Vector3(0.055,0.055,1.22), Vector3(0.78,0.47,-1.80), carbon)
	_box("RearSuspensionLeft", Vector3(0.055,0.055,1.05), Vector3(-0.78,0.54,1.02), carbon)
	_box("RearSuspensionRight", Vector3(0.055,0.055,1.05), Vector3(0.78,0.54,1.02), carbon)
	_box("RearRainLight", Vector3(0.14,0.18,0.12), Vector3(0,0.42,2.12), _material(Color("#ff2438"),0.1,0.2))

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.05, 0.92, 4.05)
	collision.shape = shape
	collision.position.y = 0.48
	add_child(collision)

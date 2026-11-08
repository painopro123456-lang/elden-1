extends Node3D
class_name TrackBuilder

const ROAD_WIDTH := 15.0
const SAMPLE_STEP := 0.035
const TRACKS := {
	"BAHRAIN": [Vector2(-42,-28),Vector2(-20,-42),Vector2(8,-40),Vector2(35,-28),Vector2(44,-7),Vector2(32,12),Vector2(8,18),Vector2(-5,8),Vector2(-24,20),Vector2(-44,10),Vector2(-48,-8)],
	"JEDDAH": [Vector2(-48,-12),Vector2(-28,-34),Vector2(-4,-28),Vector2(16,-42),Vector2(43,-30),Vector2(48,-8),Vector2(25,2),Vector2(43,20),Vector2(20,38),Vector2(-8,30),Vector2(-35,38),Vector2(-48,14)],
	"MELBOURNE": [Vector2(-42,-24),Vector2(-18,-38),Vector2(12,-36),Vector2(42,-20),Vector2(46,4),Vector2(28,24),Vector2(2,32),Vector2(-22,25),Vector2(-44,8),Vector2(-32,-4),Vector2(-10,4),Vector2(5,-8)],
	"SUZUKA": [Vector2(-48,-20),Vector2(-30,-38),Vector2(-10,-35),Vector2(4,-18),Vector2(20,-38),Vector2(43,-26),Vector2(48,-2),Vector2(28,8),Vector2(42,28),Vector2(20,40),Vector2(0,26),Vector2(-24,35),Vector2(-44,18)],
	"MONACO": [Vector2(-40,-25),Vector2(-15,-38),Vector2(10,-35),Vector2(36,-22),Vector2(44,-2),Vector2(28,8),Vector2(42,24),Vector2(20,36),Vector2(-4,30),Vector2(-22,15),Vector2(-44,20),Vector2(-48,-4)],
	"SILVERSTONE": [Vector2(-45,-20),Vector2(-28,-38),Vector2(0,-40),Vector2(30,-30),Vector2(46,-10),Vector2(38,12),Vector2(18,22),Vector2(38,35),Vector2(12,40),Vector2(-12,30),Vector2(-35,38),Vector2(-48,12)],
	"SPA-FRANCORCHAMPS": [Vector2(-45,-30),Vector2(-18,-42),Vector2(8,-35),Vector2(28,-42),Vector2(45,-18),Vector2(32,0),Vector2(45,20),Vector2(25,40),Vector2(-2,35),Vector2(-24,18),Vector2(-44,24),Vector2(-48,-4)],
	"MONZA": [Vector2(-42,-30),Vector2(-12,-38),Vector2(24,-35),Vector2(44,-20),Vector2(45,0),Vector2(25,8),Vector2(42,25),Vector2(20,35),Vector2(-12,32),Vector2(-44,18),Vector2(-46,-2)],
	"SINGAPORE": [Vector2(-44,-28),Vector2(-20,-38),Vector2(5,-35),Vector2(34,-28),Vector2(46,-8),Vector2(30,4),Vector2(44,22),Vector2(20,35),Vector2(-5,28),Vector2(-30,38),Vector2(-46,14),Vector2(-30,-2)],
	"AUSTIN": [Vector2(-45,-28),Vector2(-25,-40),Vector2(-5,-30),Vector2(8,-42),Vector2(35,-32),Vector2(46,-8),Vector2(32,8),Vector2(44,28),Vector2(18,38),Vector2(-8,25),Vector2(-30,35),Vector2(-46,10)],
	"MEXICO CITY": [Vector2(-44,-24),Vector2(-18,-40),Vector2(12,-38),Vector2(42,-20),Vector2(45,2),Vector2(25,16),Vector2(42,30),Vector2(14,38),Vector2(-12,28),Vector2(-38,35),Vector2(-46,8)],
	"ABU DHABI": [Vector2(-44,-24),Vector2(-18,-38),Vector2(12,-35),Vector2(42,-18),Vector2(46,4),Vector2(26,12),Vector2(42,32),Vector2(15,38),Vector2(-10,28),Vector2(-38,36),Vector2(-48,10)]
}

var centerline: PackedVector3Array

func build(track_name: String) -> void:
	var points: Array = TRACKS.get(track_name, TRACKS["BAHRAIN"])
	centerline = _smooth_loop(points, 10)
	_add_environment()
	_add_road()
	_add_curbs()
	_add_barriers()
	_add_start_line()

func _smooth_loop(points: Array, subdivisions: int) -> PackedVector3Array:
	var result := PackedVector3Array()
	for i in range(points.size()):
		var p0: Vector2 = points[(i - 1 + points.size()) % points.size()]
		var p1: Vector2 = points[i]
		var p2: Vector2 = points[(i + 1) % points.size()]
		var p3: Vector2 = points[(i + 2) % points.size()]
		for step in range(subdivisions):
			var t := float(step) / float(subdivisions)
			var t2 := t * t
			var t3 := t2 * t
			var x := 0.5 * ((2.0*p1.x) + (-p0.x+p2.x)*t + (2.0*p0.x-5.0*p1.x+4.0*p2.x-p3.x)*t2 + (-p0.x+3.0*p1.x-3.0*p2.x+p3.x)*t3)
			var z := 0.5 * ((2.0*p1.y) + (-p0.y+p2.y)*t + (2.0*p0.y-5.0*p1.y+4.0*p2.y-p3.y)*t2 + (-p0.y+3.0*p1.y-3.0*p2.y+p3.y)*t3)
			result.append(Vector3(x, 0.05, z))
	return result

func _add_environment() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(260, 260)
	ground.mesh = plane
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color("#26382e")
	grass.roughness = 1.0
	ground.material_override = grass
	ground.position.y = -0.22
	add_child(ground)
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("#17283e")
	sky_mat.sky_horizon_color = Color("#8b9aaa")
	sky_mat.ground_bottom_color = Color("#202a32")
	sky_mat.ground_horizon_color = Color("#65717b")
	env.sky.sky_material = sky_mat
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#a9b7c8")
	env.ambient_light_energy = 0.65
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -28, 0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

func _add_road() -> void:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for i in range(centerline.size()):
		var tangent := (centerline[(i + 1) % centerline.size()] - centerline[(i - 1 + centerline.size()) % centerline.size()]).normalized()
		var side := Vector3(-tangent.z, 0, tangent.x)
		vertices.append(centerline[i] - side * ROAD_WIDTH * 0.5)
		vertices.append(centerline[i] + side * ROAD_WIDTH * 0.5)
		uvs.append(Vector2(0, float(i) * 0.12))
		uvs.append(Vector2(1, float(i) * 0.12))
	for i in range(centerline.size()):
		var j := (i + 1) % centerline.size()
		var a := i * 2
		var b := j * 2
		indices.append_array(PackedInt32Array([a, b, a+1, a+1, b, b+1]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var road := MeshInstance3D.new()
	road.mesh = mesh
	var asphalt := StandardMaterial3D.new()
	asphalt.albedo_color = Color("#30343a")
	asphalt.roughness = 0.92
	asphalt.uv1_scale = Vector3(1, 1, 1)
	road.material_override = asphalt
	add_child(road)
	var body := StaticBody3D.new()
	body.name = "RoadCollision"
	add_child(body)
	var collision := CollisionShape3D.new()
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(mesh.get_faces())
	collision.shape = shape
	body.add_child(collision)

func _add_curbs() -> void:
	for side_sign in [-1.0, 1.0]:
		for i in range(0, centerline.size(), 4):
			var j := (i + 1) % centerline.size()
			var tangent := (centerline[j] - centerline[i]).normalized()
			var side := Vector3(-tangent.z, 0, tangent.x) * side_sign
			var curb := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(1.8, 0.16, 1.2)
			curb.mesh = box
			curb.position = (centerline[i] + centerline[j]) * 0.5 + side * (ROAD_WIDTH * 0.5 + 0.35)
			curb.rotation.y = atan2(tangent.x, tangent.z)
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color("#e1262f") if (i / 4) % 2 == 0 else Color("#f0f0ed")
			curb.material_override = mat
			add_child(curb)

func _add_barriers() -> void:
	for side_sign in [-1.0, 1.0]:
		for i in range(0, centerline.size(), 3):
			var j := (i + 1) % centerline.size()
			var tangent := (centerline[j] - centerline[i]).normalized()
			var side := Vector3(-tangent.z, 0, tangent.x) * side_sign
			var midpoint := (centerline[i] + centerline[j]) * 0.5 + side * (ROAD_WIDTH * 0.5 + 4.2)
			var barrier := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(2.8, 1.0, 0.55)
			barrier.mesh = box
			barrier.position = midpoint + Vector3.UP * 0.55
			barrier.rotation.y = atan2(tangent.x, tangent.z)
			var metal := StandardMaterial3D.new()
			metal.albedo_color = Color("#aeb5bd")
			metal.metallic = 0.55
			metal.roughness = 0.48
			barrier.material_override = metal
			add_child(barrier)
			var body := StaticBody3D.new()
			body.position = barrier.position
			body.rotation = barrier.rotation
			var shape := CollisionShape3D.new()
			var box_shape := BoxShape3D.new()
			box_shape.size = box.size
			shape.shape = box_shape
			body.add_child(shape)
			add_child(body)

func _add_start_line() -> void:
	var line := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(ROAD_WIDTH, 0.025, 0.7)
	line.mesh = mesh
	line.position = centerline[0] + Vector3(0, 0.09, 0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	line.material_override = material
	add_child(line)

func get_start_position() -> Vector3:
	return centerline[0] + Vector3(0, 0.6, 0)

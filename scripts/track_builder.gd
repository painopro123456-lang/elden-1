extends Node3D
class_name TrackBuilder

const DEFAULT_HALF_WIDTH := 7.0
var centerline := PackedVector3Array()
var left_widths: PackedFloat32Array = PackedFloat32Array()
var right_widths: PackedFloat32Array = PackedFloat32Array()

const TRACK_FILES := {
	"BAHRAIN": "res://data/tracks/Sakhir.csv",
	"JEDDAH": "res://data/tracks/Jeddah.geojson",
	"MELBOURNE": "res://data/tracks/Melbourne.csv",
	"SUZUKA": "res://data/tracks/Suzuka.csv",
	"MONACO": "res://data/tracks/Monaco.geojson",
	"SILVERSTONE": "res://data/tracks/Silverstone.csv",
	"SPA-FRANCORCHAMPS": "res://data/tracks/Spa.csv",
	"MONZA": "res://data/tracks/Monza.csv",
	"SINGAPORE": "res://data/tracks/Singapore.geojson",
	"AUSTIN": "res://data/tracks/Austin.csv",
	"MEXICO CITY": "res://data/tracks/MexicoCity.csv",
	"ABU DHABI": "res://data/tracks/YasMarina.csv"
}

func build(track_name: String) -> bool:
	centerline.clear()
	left_widths.clear()
	right_widths.clear()
	var path: String = TRACK_FILES.get(track_name, TRACK_FILES["BAHRAIN"])
	var loaded := false
	if path.ends_with(".csv"):
		loaded = _load_csv(path)
	else:
		loaded = _load_geojson(path)
	if not loaded or centerline.size() < 20:
		push_error("Could not load real circuit geometry: " + track_name)
		return false
	_add_environment()
	_add_road()
	_add_start_line()
	return true

func _load_csv(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		var fields := line.split(",")
		if fields.size() < 4:
			continue
		if not fields[0].is_valid_float():
			continue
		var x := float(fields[0])
		var z := float(fields[1])
		centerline.append(Vector3(x, 0.05, z))
		right_widths.append(maxf(2.5, float(fields[2])))
		left_widths.append(maxf(2.5, float(fields[3])))
	file.close()
	return centerline.size() > 20

func _load_geojson(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return false
	var features: Array = parsed.get("features", [])
	if features.is_empty():
		return false
	var geometry: Dictionary = features[0].get("geometry", {})
	var coordinates: Array = geometry.get("coordinates", [])
	if coordinates.size() < 20:
		return false
	var origin_lon := float(coordinates[0][0])
	var origin_lat := float(coordinates[0][1])
	var lat_scale := cos(deg_to_rad(origin_lat)) * 111320.0
	for coordinate in coordinates:
		var lon := float(coordinate[0])
		var lat := float(coordinate[1])
		var x := (lon - origin_lon) * lat_scale
		var z := -(lat - origin_lat) * 111320.0
		centerline.append(Vector3(x, 0.05, z))
		left_widths.append(DEFAULT_HALF_WIDTH)
		right_widths.append(DEFAULT_HALF_WIDTH)
	# GeoJSON rings often repeat their first point at the end; avoid a zero-length closing segment.
	if centerline.size() > 2 and centerline[0].distance_to(centerline[-1]) < 0.2:
		centerline.remove_at(centerline.size() - 1)
		left_widths.remove_at(left_widths.size() - 1)
		right_widths.remove_at(right_widths.size() - 1)
	return centerline.size() > 20

func _side_at(index: int) -> Vector3:
	var tangent := (centerline[(index + 1) % centerline.size()] - centerline[(index - 1 + centerline.size()) % centerline.size()]).normalized()
	return Vector3(-tangent.z, 0.0, tangent.x)

func _add_environment() -> void:
	var min_x := INF
	var max_x := -INF
	var min_z := INF
	var max_z := -INF
	for point in centerline:
		min_x = minf(min_x, point.x)
		max_x = maxf(max_x, point.x)
		min_z = minf(min_z, point.z)
		max_z = maxf(max_z, point.z)
	var span_x := max_x - min_x
	var span_z := max_z - min_z
	var ground_size := Vector2(maxf(span_x + 320.0, 400.0), maxf(span_z + 320.0, 400.0))
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = ground_size
	ground.mesh = plane
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color("#26382e")
	grass.roughness = 1.0
	ground.material_override = grass
	ground.position = Vector3((min_x + max_x) * 0.5, -0.22, (min_z + max_z) * 0.5)
	add_child(ground)
	# A single broad floor collider avoids hundreds of tiny barrier bodies and
	# an expensive concave collision mesh during scene startup.
	var floor_body := StaticBody3D.new()
	floor_body.name = "GroundCollision"
	floor_body.position = Vector3(ground.position.x, -0.20, ground.position.z)
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(ground_size.x, 0.5, ground_size.y)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	add_child(floor_body)
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
		var side := _side_at(i)
		var left_edge := centerline[i] - side * left_widths[i]
		var right_edge := centerline[i] + side * right_widths[i]
		vertices.append(left_edge)
		vertices.append(right_edge)
		uvs.append(Vector2(0.0, float(i) * 0.12))
		uvs.append(Vector2(1.0, float(i) * 0.12))
	for i in range(centerline.size()):
		var j := (i + 1) % centerline.size()
		var a := i * 2
		var b := j * 2
		indices.append_array(PackedInt32Array([a, b, a + 1, a + 1, b, b + 1]))
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
	road.material_override = asphalt
	add_child(road)
	# The drivable surface sits just above the broad ground collider. Keeping
	# collision simple makes loading large GPS circuits reliable on Windows.

func _add_curbs() -> void:
	for side_sign in [-1.0, 1.0]:
		for i in range(0, centerline.size(), 5):
			var j := (i + 1) % centerline.size()
			var tangent := (centerline[j] - centerline[i]).normalized()
			var side := Vector3(-tangent.z, 0.0, tangent.x) * side_sign
			var width := left_widths[i] if side_sign < 0.0 else right_widths[i]
			var curb := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(2.2, 0.16, 1.1)
			curb.mesh = box
			curb.position = (centerline[i] + centerline[j]) * 0.5 + side * (width + 0.45)
			curb.rotation.y = atan2(-tangent.z, tangent.x)
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color("#e1262f") if (i / 5) % 2 == 0 else Color("#f0f0ed")
			curb.material_override = mat
			add_child(curb)

func _add_barriers() -> void:
	for side_sign in [-1.0, 1.0]:
		for i in range(0, centerline.size(), 12):
			var j := (i + 1) % centerline.size()
			var tangent := (centerline[j] - centerline[i]).normalized()
			var side := Vector3(-tangent.z, 0.0, tangent.x) * side_sign
			var width := left_widths[i] if side_sign < 0.0 else right_widths[i]
			var midpoint := (centerline[i] + centerline[j]) * 0.5 + side * (width + 5.0)
			var barrier := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(5.0, 1.0, 0.55)
			barrier.mesh = box
			barrier.position = midpoint + Vector3.UP * 0.55
			barrier.rotation.y = atan2(-tangent.z, tangent.x)
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
	mesh.size = Vector3(left_widths[0] + right_widths[0], 0.025, 0.7)
	line.mesh = mesh
	line.position = centerline[0] + Vector3(0, 0.09, 0)
	var tangent := (centerline[1] - centerline[0]).normalized()
	line.rotation.y = atan2(tangent.x, tangent.z)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	line.material_override = material
	add_child(line)

func get_start_position() -> Vector3:
	return centerline[0] + Vector3(0, 0.6, 0)

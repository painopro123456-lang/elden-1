extends Node3D
class_name TrackBuilder

const DEFAULT_HALF_WIDTH := 7.0
const KERB_WIDTH := 1.15
const BARRIER_OFFSET := 15.0
const TRACK_FILES := {
	"BAHRAIN": "res://data/tracks/Sakhir.txt",
	"JEDDAH": "res://data/tracks/Jeddah.geojson",
	"MELBOURNE": "res://data/tracks/Melbourne.txt",
	"SUZUKA": "res://data/tracks/Suzuka.txt",
	"MONACO": "res://data/tracks/Monaco.geojson",
	"SILVERSTONE": "res://data/tracks/Silverstone.txt",
	"SPA-FRANCORCHAMPS": "res://data/tracks/Spa.txt",
	"MONZA": "res://data/tracks/Monza.txt",
	"SINGAPORE": "res://data/tracks/Singapore.geojson",
	"AUSTIN": "res://data/tracks/Austin.txt",
	"MEXICO CITY": "res://data/tracks/MexicoCity.txt",
	"ABU DHABI": "res://data/tracks/YasMarina.txt"
}

var centerline := PackedVector3Array()
var left_widths := PackedFloat32Array()
var right_widths := PackedFloat32Array()
var load_error := ""

func build(track_name: String) -> bool:
	centerline.clear()
	left_widths.clear()
	right_widths.clear()
	load_error = ""
	var path: String = TRACK_FILES.get(track_name, "")
	if path.is_empty():
		load_error = "Unknown circuit: " + track_name
		push_error(load_error)
		return false
	if not FileAccess.file_exists(path):
		load_error = "Circuit data is missing from the game package: " + path
		push_error(load_error)
		return false
	var loaded := _load_csv(path) if path.ends_with(".txt") or path.ends_with(".csv") else _load_geojson(path)
	if not loaded or centerline.size() < 20:
		if load_error.is_empty():
			load_error = "Circuit file contains fewer than 20 valid centre-line points: " + path
		push_error(load_error)
		centerline.clear()
		left_widths.clear()
		right_widths.clear()
		return false
	_close_and_sanitize_loop()
	if centerline.size() < 20:
		load_error = "Circuit geometry is not a usable closed loop: " + path
		push_error(load_error)
		return false
	_add_environment()
	_add_road()
	_add_kerbs()
	_add_barriers()
	_add_trackside_details()
	_add_start_line()
	return true

func _load_csv(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		load_error = "Cannot open circuit file (%s): %s" % [FileAccess.get_open_error(), path]
		return false
	var line_number := 0
	while not file.eof_reached():
		line_number += 1
		var line := file.get_line().strip_edges().trim_prefix("\uFEFF")
		if line.is_empty() or line.begins_with("#"):
			continue
		var fields := line.split(",", false)
		if fields.size() < 4:
			continue
		var valid := true
		for i in range(4):
			if not fields[i].strip_edges().is_valid_float():
				valid = false
				break
		if not valid:
			continue
		var x := float(fields[0].strip_edges())
		var z := float(fields[1].strip_edges())
		var right_width := float(fields[2].strip_edges())
		var left_width := float(fields[3].strip_edges())
		if not is_finite(x) or not is_finite(z) or not is_finite(right_width) or not is_finite(left_width):
			continue
		centerline.append(Vector3(x, 0.05, z))
		right_widths.append(clampf(right_width, 3.0, 24.0))
		left_widths.append(clampf(left_width, 3.0, 24.0))
	file.close()
	if centerline.size() < 20:
		load_error = "Only %d valid points were read from %s" % [centerline.size(), path]
		return false
	return true

func _load_geojson(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		load_error = "Cannot open circuit file (%s): %s" % [FileAccess.get_open_error(), path]
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		load_error = "Circuit GeoJSON is invalid: " + path
		return false
	var features: Array = parsed.get("features", [])
	if features.is_empty():
		load_error = "Circuit GeoJSON has no features: " + path
		return false
	var geometry: Dictionary = features[0].get("geometry", {})
	var coordinates: Array = geometry.get("coordinates", [])
	if geometry.get("type", "") == "MultiLineString" and not coordinates.is_empty():
		coordinates = coordinates[0]
	if coordinates.size() < 20:
		load_error = "Circuit GeoJSON has too few coordinates: " + path
		return false
	var origin_lon := float(coordinates[0][0])
	var origin_lat := float(coordinates[0][1])
	var lat_scale := cos(deg_to_rad(origin_lat)) * 111320.0
	for coordinate in coordinates:
		if not coordinate is Array or coordinate.size() < 2:
			continue
		var lon := float(coordinate[0])
		var lat := float(coordinate[1])
		if not is_finite(lon) or not is_finite(lat):
			continue
		var x := (lon - origin_lon) * lat_scale
		var z := -(lat - origin_lat) * 111320.0
		centerline.append(Vector3(x, 0.05, z))
		left_widths.append(DEFAULT_HALF_WIDTH)
		right_widths.append(DEFAULT_HALF_WIDTH)
	if centerline.size() < 20:
		load_error = "Circuit GeoJSON did not contain enough valid coordinate pairs: " + path
		return false
	return true

func _close_and_sanitize_loop() -> void:
	if centerline.size() > 2 and centerline[0].distance_to(centerline[-1]) < 0.2:
		centerline.remove_at(centerline.size() - 1)
		left_widths.remove_at(left_widths.size() - 1)
		right_widths.remove_at(right_widths.size() - 1)
	var clean_points := PackedVector3Array()
	var clean_left := PackedFloat32Array()
	var clean_right := PackedFloat32Array()
	for i in range(centerline.size()):
		if not clean_points.is_empty() and clean_points[-1].distance_to(centerline[i]) < 0.05:
			continue
		clean_points.append(centerline[i])
		clean_left.append(left_widths[i])
		clean_right.append(right_widths[i])
	centerline = clean_points
	left_widths = clean_left
	right_widths = clean_right

func _side_at(index: int) -> Vector3:
	var count := centerline.size()
	var tangent := (centerline[(index + 1) % count] - centerline[(index - 1 + count) % count]).normalized()
	return Vector3(-tangent.z, 0.0, tangent.x)

func _make_material(color: Color, roughness: float = 0.85, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material

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
	var ground_size := Vector2(maxf(max_x - min_x + 420.0, 500.0), maxf(max_z - min_z + 420.0, 500.0))
	var ground := MeshInstance3D.new()
	ground.name = "InfieldAndRunoff"
	var plane := PlaneMesh.new()
	plane.size = ground_size
	ground.mesh = plane
	ground.material_override = _make_material(Color("#263a30"), 1.0)
	ground.position = Vector3((min_x + max_x) * 0.5, -0.24, (min_z + max_z) * 0.5)
	add_child(ground)
	var floor_body := StaticBody3D.new()
	floor_body.name = "GroundCollision"
	floor_body.position = Vector3(ground.position.x, -0.25, ground.position.z)
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
	sky_mat.sky_top_color = Color("#10243d")
	sky_mat.sky_horizon_color = Color("#a8b7c7")
	sky_mat.ground_bottom_color = Color("#17221f")
	sky_mat.ground_horizon_color = Color("#6b777e")
	sky_mat.sun_angle_max = 18.0
	env.sky.sky_material = sky_mat
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#c0cbd8")
	env.ambient_light_energy = 0.72
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.18
	env.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 450.0
	add_child(sun)

func _build_strip(name: String, outer_offset: float, inner_offset: float, y: float, material: Material) -> MeshInstance3D:
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	for i in range(centerline.size()):
		var side := _side_at(i)
		var outer_width := left_widths[i] if outer_offset < 0.0 else right_widths[i]
		var sign := -1.0 if outer_offset < 0.0 else 1.0
		var inner := centerline[i] + side * sign * inner_offset
		var outer := centerline[i] + side * sign * outer_offset
		vertices.append(Vector3(inner.x, y, inner.z))
		vertices.append(Vector3(outer.x, y, outer.z))
	for i in range(centerline.size()):
		var j := (i + 1) % centerline.size()
		var a := i * 2
		var b := j * 2
		indices.append_array(PackedInt32Array([a, a + 1, b, a + 1, b + 1, b]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.name = name
	instance.mesh = mesh
	instance.material_override = material
	add_child(instance)
	return instance

func _add_road() -> void:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for i in range(centerline.size()):
		var side := _side_at(i)
		var left_edge := centerline[i] - side * left_widths[i]
		var right_edge := centerline[i] + side * right_widths[i]
		vertices.append(Vector3(left_edge.x, 0.08, left_edge.z))
		vertices.append(Vector3(right_edge.x, 0.08, right_edge.z))
		uvs.append(Vector2(0.0, float(i) * 0.12))
		uvs.append(Vector2(1.0, float(i) * 0.12))
	for i in range(centerline.size()):
		var j := (i + 1) % centerline.size()
		var a := i * 2
		var b := j * 2
		indices.append_array(PackedInt32Array([a, a + 1, b, a + 1, b + 1, b]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var road := MeshInstance3D.new()
	road.name = "AsphaltCircuit"
	road.mesh = mesh
	var asphalt := _make_material(Color("#34383e"), 0.96)
	asphalt.uv1_scale = Vector3(1.0, 1.0, 1.0)
	road.material_override = asphalt
	add_child(road)
	road.create_trimesh_collision()

func _add_kerbs() -> void:
	var red := _make_material(Color("#d51e2b"), 0.78)
	var white := _make_material(Color("#e8e8e4"), 0.78)
	var left_vertices := PackedVector3Array()
	var right_vertices := PackedVector3Array()
	var left_indices := PackedInt32Array()
	var right_indices := PackedInt32Array()
	for i in range(centerline.size()):
		var side := _side_at(i)
		var left_edge := centerline[i] - side * left_widths[i]
		var right_edge := centerline[i] + side * right_widths[i]
		var l_outer := left_edge - side * KERB_WIDTH
		var r_outer := right_edge + side * KERB_WIDTH
		left_vertices.append(Vector3(left_edge.x, 0.105, left_edge.z))
		left_vertices.append(Vector3(l_outer.x, 0.105, l_outer.z))
		right_vertices.append(Vector3(right_edge.x, 0.105, right_edge.z))
		right_vertices.append(Vector3(r_outer.x, 0.105, r_outer.z))
	for i in range(centerline.size()):
		var j := (i + 1) % centerline.size()
		var a := i * 2
		var b := j * 2
		left_indices.append_array(PackedInt32Array([a, a + 1, b, a + 1, b + 1, b]))
		right_indices.append_array(PackedInt32Array([a, a + 1, b, a + 1, b + 1, b]))
	_add_segmented_strip("LeftKerbs", left_vertices, left_indices, red, white)
	_add_segmented_strip("RightKerbs", right_vertices, right_indices, red, white)

func _add_segmented_strip(name: String, vertices: PackedVector3Array, indices: PackedInt32Array, red: Material, white: Material) -> void:
	for segment in range(2):
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		var selected_vertices := PackedVector3Array()
		var selected_indices := PackedInt32Array()
		for i in range(centerline.size()):
			if (i / 5) % 2 != segment:
				continue
			selected_vertices.append(vertices[i * 2])
			selected_vertices.append(vertices[i * 2 + 1])
		var vertex_count := selected_vertices.size()
		for i in range(0, vertex_count, 2):
			var next_pair := (i + 2) % vertex_count
			selected_indices.append_array(PackedInt32Array([i, i + 1, next_pair, i + 1, next_pair + 1, next_pair]))
		arrays[Mesh.ARRAY_VERTEX] = selected_vertices
		arrays[Mesh.ARRAY_INDEX] = selected_indices
		var mesh := ArrayMesh.new()
		if selected_vertices.size() >= 4:
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			var instance := MeshInstance3D.new()
			instance.name = name + ("Red" if segment == 0 else "White")
			instance.mesh = mesh
			instance.material_override = red if segment == 0 else white
			add_child(instance)

func _add_barriers() -> void:
	var rail_material := _make_material(Color("#68727b"), 0.42, 0.72)
	var post_material := _make_material(Color("#303a45"), 0.7, 0.45)
	for i in range(0, centerline.size(), 5):
		var side := _side_at(i)
		for direction in [-1.0, 1.0]:
			var width := left_widths[i] if direction < 0.0 else right_widths[i]
			var position := centerline[i] + side * direction * (width + BARRIER_OFFSET)
			var post := MeshInstance3D.new()
			var post_mesh := BoxMesh.new()
			post_mesh.size = Vector3(0.22, 1.45, 0.22)
			post.mesh = post_mesh
			post.position = Vector3(position.x, 0.72, position.z)
			post.material_override = post_material
			add_child(post)
			if i + 5 < centerline.size():
				var next_side := _side_at(i + 5)
				var next_width := left_widths[i + 5] if direction < 0.0 else right_widths[i + 5]
				var next_position := centerline[i + 5] + next_side * direction * (next_width + BARRIER_OFFSET)
				var midpoint := (position + next_position) * 0.5
				var rail := MeshInstance3D.new()
				var rail_mesh := BoxMesh.new()
				rail_mesh.size = Vector3(0.28, 0.22, position.distance_to(next_position) + 0.3)
				rail.mesh = rail_mesh
				rail.position = Vector3(midpoint.x, 1.18, midpoint.z)
				rail.look_at(Vector3(next_position.x, 1.18, next_position.z), Vector3.UP)
				rail.material_override = rail_material
				add_child(rail)

func _add_trackside_details() -> void:
	var board_material := _make_material(Color("#101923"), 0.55, 0.18)
	var accent_material := _make_material(Color("#d51e2b"), 0.5, 0.15)
	for i in range(12, centerline.size(), 42):
		var side := _side_at(i)
		for direction in [-1.0, 1.0]:
			var width := left_widths[i] if direction < 0.0 else right_widths[i]
			var p := centerline[i] + side * direction * (width + 10.0)
			var board := MeshInstance3D.new()
			var board_mesh := BoxMesh.new()
			board_mesh.size = Vector3(5.8, 1.35, 0.18)
			board.mesh = board_mesh
			board.position = Vector3(p.x, 1.0, p.z)
			board.material_override = board_material
			add_child(board)
			var stripe := MeshInstance3D.new()
			var stripe_mesh := BoxMesh.new()
			stripe_mesh.size = Vector3(5.8, 0.12, 0.22)
			stripe.mesh = stripe_mesh
			stripe.position = Vector3(p.x, 1.67, p.z)
			stripe.material_override = accent_material
			add_child(stripe)

func _add_start_line() -> void:
	var line := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(left_widths[0] + right_widths[0], 0.035, 0.85)
	line.mesh = mesh
	line.position = centerline[0] + Vector3(0, 0.13, 0)
	var tangent := (centerline[1] - centerline[0]).normalized()
	line.rotation.y = atan2(tangent.x, tangent.z)
	line.material_override = _make_material(Color("#f4f5f6"), 0.65)
	add_child(line)

func get_start_position() -> Vector3:
	if centerline.is_empty():
		return Vector3.ZERO
	return centerline[0] + Vector3(0, 0.62, 0)

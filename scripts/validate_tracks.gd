extends SceneTree

func _initialize() -> void:
	call_deferred("_run_track_checks")

func _has_collision_shape(node: Node) -> bool:
	if node is CollisionShape3D:
		return true
	for child in node.get_children():
		if _has_collision_shape(child):
			return true
	return false

func _run_track_checks() -> void:
	var track_names := [
		"BAHRAIN", "JEDDAH", "MELBOURNE", "SUZUKA", "MONACO", "SILVERSTONE",
		"SPA-FRANCORCHAMPS", "MONZA", "SINGAPORE", "AUSTIN", "MEXICO CITY", "ABU DHABI"
	]
	for track_name in track_names:
		var builder := TrackBuilder.new()
		root.add_child(builder)
		if not builder.build(track_name, false):
			push_error("TRACK VALIDATION FAILED: " + track_name + " / " + builder.load_error)
			quit(1)
			return
		if builder.centerline.size() < 20:
			push_error("TRACK VALIDATION FAILED: too few centre-line points: " + track_name)
			quit(1)
			return
		for point in builder.centerline:
			if not is_finite(point.x) or not is_finite(point.y) or not is_finite(point.z):
				push_error("TRACK VALIDATION FAILED: non-finite point: " + track_name)
				quit(1)
				return
		print("TRACK VALIDATION PASSED: ", track_name, " (", builder.centerline.size(), " points)")
		builder.free()
	var car := RaceCar.new()
	root.add_child(car)
	if not _has_collision_shape(car):
		push_error("CAR VALIDATION FAILED: player collision shape missing")
		quit(1)
		return
	if car.rolling_wheels.size() != 16:
		push_error("CAR VALIDATION FAILED: expected 4 rolling wheel assemblies")
		quit(1)
		return
	print("CAR VALIDATION PASSED: collision and four animated wheel assemblies")
	print("ALL 12 TRACKS LOADED SUCCESSFULLY")
	quit(0)

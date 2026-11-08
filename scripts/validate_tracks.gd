extends SceneTree

func _initialize() -> void:
	call_deferred("_run_track_checks")

func _run_track_checks() -> void:
	var track_names := [
		"BAHRAIN", "JEDDAH", "MELBOURNE", "SUZUKA", "MONACO", "SILVERSTONE",
		"SPA-FRANCORCHAMPS", "MONZA", "SINGAPORE", "AUSTIN", "MEXICO CITY", "ABU DHABI"
	]
	for track_name in track_names:
		var builder := TrackBuilder.new()
		root.add_child(builder)
		if not builder.build(track_name):
			push_error("TRACK VALIDATION FAILED: " + track_name)
			quit(1)
			return
		print("TRACK VALIDATION PASSED: ", track_name, " (", builder.centerline.size(), " points)")
		builder.free()
	print("ALL 12 TRACKS LOADED SUCCESSFULLY")
	quit(0)

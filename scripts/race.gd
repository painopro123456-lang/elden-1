extends Node3D

var selected_track := "BAHRAIN"
var speed_label: Label
var track_label: Label
var car: RaceCar

func _ready() -> void:
	selected_track = str(get_tree().root.get_meta("selected_track", "BAHRAIN"))
	_build_race()

func _build_race() -> void:
	var track := TrackBuilder.new()
	track.name = "Circuit"
	add_child(track)
	if not track.build(selected_track) or track.centerline.size() < 2:
		_show_load_error("The selected circuit could not be loaded. Return to the menu and choose another track.")
		return
	car = RaceCar.new()
	car.name = "PlayerCar"
	add_child(car)
	car.global_position = track.get_start_position() + Vector3(0, 0.4, 0)
	var points: PackedVector3Array = track.centerline
	var tangent := (points[1] - points[0]).normalized()
	if tangent.length_squared() < 0.001:
		tangent = Vector3.FORWARD
	car.rotation.y = atan2(-tangent.x, -tangent.z)
	_add_camera()
	_add_hud()
	car.telemetry_changed.connect(_on_telemetry_changed)

func _show_load_error(message: String) -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-340, -110)
	panel.size = Vector2(680, 220)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	panel.add_child(column)
	var title := Label.new()
	title.text = "RACE COULD NOT START"
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)
	var detail := Label.new()
	detail.text = message
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(detail)
	var back := Button.new()
	back.text = "BACK TO MENU"
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	column.add_child(back)

func _add_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "TCam"
	camera.position = Vector3(0, 1.72, 0.22)
	camera.rotation_degrees.x = -4.0
	camera.fov = 88.0
	camera.current = true
	car.add_child(camera)

func _add_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.color = Color(0.025, 0.035, 0.05, 0.84)
	panel.position = Vector2(28, 24)
	panel.size = Vector2(380, 94)
	layer.add_child(panel)
	track_label = Label.new()
	track_label.text = selected_track + "  /  GRAND PRIX"
	track_label.position = Vector2(48, 36)
	track_label.add_theme_font_size_override("font_size", 15)
	track_label.add_theme_color_override("font_color", Color("#f3f4f6"))
	layer.add_child(track_label)
	speed_label = Label.new()
	speed_label.text = "000 KM/H"
	speed_label.position = Vector2(48, 62)
	speed_label.add_theme_font_size_override("font_size", 27)
	speed_label.add_theme_color_override("font_color", Color("#e1262f"))
	layer.add_child(speed_label)
	var help := Label.new()
	help.text = "W / UP  THROTTLE     S / DOWN  BRAKE     A D / LEFT RIGHT  STEER     ESC  MENU"
	help.position = Vector2(28, 1030)
	help.add_theme_font_size_override("font_size", 12)
	help.add_theme_color_override("font_color", Color("#d6dbe2"))
	layer.add_child(help)

func _on_telemetry_changed(speed_kph: float) -> void:
	if is_instance_valid(speed_label):
		speed_label.text = "%03d KM/H" % int(speed_kph)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

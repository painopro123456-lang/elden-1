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
	if not track.build(selected_track) or track.centerline.size() < 20:
		var reason := track.load_error if not track.load_error.is_empty() else "The circuit geometry did not produce a drivable road."
		_show_load_error("CIRCUIT LOAD FAILED", reason)
		return
	car = RaceCar.new()
	car.name = "PlayerCar"
	add_child(car)
	car.global_position = track.get_start_position()
	var points: PackedVector3Array = track.centerline
	var tangent := (points[1] - points[0]).normalized()
	if tangent.length_squared() < 0.001:
		tangent = Vector3.FORWARD
	car.rotation.y = atan2(-tangent.x, -tangent.z)
	_add_camera()
	_add_hud()
	car.telemetry_changed.connect(_on_telemetry_changed)

func _show_load_error(title_text: String, message: String) -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0.015, 0.02, 0.03, 0.88)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-390, -155)
	panel.size = Vector2(780, 310)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#111923")
	style.border_color = Color("#d51e2b")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 25
	style.content_margin_bottom = 25
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	panel.add_child(column)
	var eyebrow := Label.new()
	eyebrow.text = "ELDEN 1   /   RACE CONTROL"
	eyebrow.add_theme_font_size_override("font_size", 11)
	eyebrow.add_theme_color_override("font_color", Color("#e32636"))
	column.add_child(eyebrow)
	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color("#f4f6f8"))
	column.add_child(title)
	var detail := Label.new()
	detail.text = message
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", 14)
	detail.add_theme_color_override("font_color", Color("#aab4c0"))
	column.add_child(detail)
	var back := Button.new()
	back.text = "RETURN TO MAIN MENU"
	back.custom_minimum_size = Vector2(230, 48)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	column.add_child(back)

func _add_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "TCam"
	camera.position = Vector3(0, 1.72, 0.22)
	camera.rotation_degrees.x = -4.0
	camera.fov = 88.0
	camera.current = true
	camera.attributes = CameraAttributesPractical.new()
	camera.attributes.exposure_multiplier = 1.0
	car.add_child(camera)

func _add_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var top_panel := PanelContainer.new()
	top_panel.position = Vector2(28, 24)
	top_panel.size = Vector2(390, 112)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.035, 0.05, 0.88)
	panel_style.border_color = Color("#354352")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(7)
	top_panel.add_theme_stylebox_override("panel", panel_style)
	layer.add_child(top_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	top_panel.add_child(column)
	var series := Label.new()
	series.text = "ELDEN 1     /     GRAND PRIX"
	series.add_theme_font_size_override("font_size", 10)
	series.add_theme_color_override("font_color", Color("#e32636"))
	column.add_child(series)
	track_label = Label.new()
	track_label.text = selected_track + "  ·  RACE SESSION"
	track_label.add_theme_font_size_override("font_size", 16)
	track_label.add_theme_color_override("font_color", Color("#f3f4f6"))
	column.add_child(track_label)
	speed_label = Label.new()
	speed_label.text = "000 KM/H"
	speed_label.add_theme_font_size_override("font_size", 29)
	speed_label.add_theme_color_override("font_color", Color("#ffffff"))
	column.add_child(speed_label)
	var help := Label.new()
	help.text = "W / ↑  THROTTLE     S / ↓  BRAKE     A D / ← →  STEER     ESC  MENU"
	help.position = Vector2(28, 1020)
	help.add_theme_font_size_override("font_size", 12)
	help.add_theme_color_override("font_color", Color("#d6dbe2"))
	layer.add_child(help)
	var live := Label.new()
	live.text = "LIVE  ●"
	live.position = Vector2(1740, 30)
	live.add_theme_font_size_override("font_size", 12)
	live.add_theme_color_override("font_color", Color("#e32636"))
	layer.add_child(live)

func _on_telemetry_changed(speed_kph: float) -> void:
	if is_instance_valid(speed_label):
		speed_label.text = "%03d KM/H" % int(speed_kph)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

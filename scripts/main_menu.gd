extends Control

const BG := Color("#080b10")
const PANEL := Color("#111720")
const PANEL_ALT := Color("#171f2a")
const WHITE := Color("#f4f6f8")
const MUTED := Color("#8d99a8")
const RED := Color("#e32636")
const LINE := Color("#27313d")

const TRACKS := [
	{"name":"BAHRAIN","location":"SAKHIR  /  BAHRAIN"},
	{"name":"JEDDAH","location":"JEDDAH  /  SAUDI ARABIA"},
	{"name":"MELBOURNE","location":"ALBERT PARK  /  AUSTRALIA"},
	{"name":"SUZUKA","location":"SUZUKA  /  JAPAN"},
	{"name":"MONACO","location":"MONTE CARLO  /  MONACO"},
	{"name":"SILVERSTONE","location":"SILVERSTONE  /  UNITED KINGDOM"},
	{"name":"SPA-FRANCORCHAMPS","location":"STAVELOT  /  BELGIUM"},
	{"name":"MONZA","location":"MONZA  /  ITALY"},
	{"name":"SINGAPORE","location":"MARINA BAY  /  SINGAPORE"},
	{"name":"AUSTIN","location":"CIRCUIT OF THE AMERICAS  /  USA"},
	{"name":"MEXICO CITY","location":"HERMANOS RODRIGUEZ  /  MEXICO"},
	{"name":"ABU DHABI","location":"YAS MARINA  /  UAE"}
]

class TrackMap extends Control:
	var points: PackedVector2Array = PackedVector2Array()

	func _draw() -> void:
		var source := points
		if source.size() < 3:
			source = PackedVector2Array([
				Vector2(0.08,0.54),Vector2(0.17,0.22),Vector2(0.36,0.12),
				Vector2(0.54,0.26),Vector2(0.78,0.15),Vector2(0.91,0.40),
				Vector2(0.78,0.72),Vector2(0.54,0.84),Vector2(0.34,0.68),
				Vector2(0.16,0.82),Vector2(0.08,0.54)
			])
		var mapped := PackedVector2Array()
		for p in source:
			mapped.append(Vector2(10.0 + p.x * maxf(size.x - 20.0, 1.0), 8.0 + p.y * maxf(size.y - 16.0, 1.0)))
		draw_polyline(mapped, Color("#e32636"), 3.0, true)
		if mapped.size() > 0:
			draw_circle(mapped[0], 4.0, WHITE)

var selected_track := "BAHRAIN"
var track_screen: Control
var page_root: Control

func _ready() -> void:
	_build_home()

func _style_panel(panel: PanelContainer, color: Color, border: Color = LINE) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)

func _label(value: String, font_size: int, color: Color, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if bold:
		label.add_theme_color_override("font_weight", 800)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(value: String, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size = Vector2(190, 54)
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", WHITE)
	button.add_theme_color_override("font_hover_color", WHITE)
	button.add_theme_color_override("font_pressed_color", WHITE)
	var normal := StyleBoxFlat.new()
	normal.bg_color = RED if primary else PANEL_ALT
	normal.border_color = RED if primary else LINE
	normal.set_border_width_all(1)
	normal.corner_radius_top_left = 5
	normal.corner_radius_top_right = 5
	normal.corner_radius_bottom_left = 5
	normal.corner_radius_bottom_right = 5
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#ff3545") if primary else Color("#222d3b")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", normal)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return button

func _build_home() -> void:
	for child in get_children():
		child.queue_free()
	track_screen = null
	page_root = Control.new()
	page_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(page_root)

	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_root.add_child(bg)

	var top_glow := ColorRect.new()
	top_glow.color = Color("#101925")
	top_glow.anchor_left = 0.52
	top_glow.anchor_right = 1.0
	top_glow.anchor_bottom = 1.0
	top_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_root.add_child(top_glow)

	var header := HBoxContainer.new()
	header.anchor_left = 0.045
	header.anchor_right = 0.955
	header.anchor_top = 0.025
	header.anchor_bottom = 0.12
	header.add_theme_constant_override("separation", 28)
	page_root.add_child(header)

	var brand_box := VBoxContainer.new()
	brand_box.custom_minimum_size = Vector2(230, 0)
	brand_box.add_child(_label("ELDEN 1", 28, WHITE, true))
	brand_box.add_child(_label("MOTORSPORT  /  2026", 10, MUTED, true))
	header.add_child(brand_box)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	for nav in ["HOME", "GRAND PRIX", "GARAGE", "SETTINGS"]:
		var nav_button := Button.new()
		nav_button.text = nav
		nav_button.flat = true
		nav_button.add_theme_font_size_override("font_size", 13)
		nav_button.add_theme_color_override("font_color", RED if nav == "HOME" else MUTED)
		nav_button.add_theme_color_override("font_hover_color", WHITE)
		nav_button.pressed.connect(_on_nav_pressed.bind(nav))
		header.add_child(nav_button)

	var rule := ColorRect.new()
	rule.color = LINE
	rule.anchor_left = 0.045
	rule.anchor_right = 0.955
	rule.anchor_top = 0.125
	rule.anchor_bottom = 0.127
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_root.add_child(rule)

	var left := VBoxContainer.new()
	left.anchor_left = 0.065
	left.anchor_right = 0.52
	left.anchor_top = 0.23
	left.anchor_bottom = 0.80
	left.add_theme_constant_override("separation", 16)
	page_root.add_child(left)
	left.add_child(_label("2026 WORLD CHAMPIONSHIP  /  SEASON 01", 12, RED, true))
	var hero := _label("THE GRID\nIS YOURS.", 66, WHITE, true)
	hero.add_theme_color_override("font_outline_color", Color("#080b10"))
	hero.add_theme_constant_override("line_spacing", -8)
	left.add_child(hero)
	left.add_child(_label("Every corner has a cost. Every lap writes the story.", 17, MUTED))
	var gap := Control.new()
	gap.custom_minimum_size.y = 10
	left.add_child(gap)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 14)
	left.add_child(actions)
	var start := _button("START RACE   →", true)
	start.custom_minimum_size = Vector2(230, 58)
	start.pressed.connect(_show_track_select)
	actions.add_child(start)
	var garage := _button("OPEN GARAGE")
	garage.custom_minimum_size = Vector2(180, 58)
	garage.pressed.connect(func(): _show_info("GARAGE", "Team cars and the vehicle showcase are being built."))
	actions.add_child(garage)

	var stats := HBoxContainer.new()
	stats.anchor_left = 0.065
	stats.anchor_right = 0.55
	stats.anchor_top = 0.83
	stats.anchor_bottom = 0.94
	stats.add_theme_constant_override("separation", 42)
	page_root.add_child(stats)
	for pair in [["11","TEAMS"],["22","DRIVERS"],["12","CIRCUITS"]]:
		var stat := VBoxContainer.new()
		stat.add_child(_label(pair[0], 25, WHITE, true))
		stat.add_child(_label(pair[1], 10, MUTED, true))
		stats.add_child(stat)

	var feature := PanelContainer.new()
	feature.anchor_left = 0.60
	feature.anchor_right = 0.94
	feature.anchor_top = 0.20
	feature.anchor_bottom = 0.83
	_style_panel(feature, PANEL)
	page_root.add_child(feature)
	var feature_box := VBoxContainer.new()
	feature_box.add_theme_constant_override("separation", 12)
	feature_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	feature_box.add_theme_constant_override("margin_left", 26)
	feature_box.add_theme_constant_override("margin_right", 26)
	feature_box.add_theme_constant_override("margin_top", 22)
	feature_box.add_theme_constant_override("margin_bottom", 22)
	feature.add_child(feature_box)
	feature_box.add_child(_label("FEATURED ROUND  /  01", 11, RED, true))
	feature_box.add_child(_label("BAHRAIN GRAND PRIX", 22, WHITE, true))
	var map_frame := PanelContainer.new()
	map_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_style_panel(map_frame, Color("#0b1118"), Color("#202b37"))
	feature_box.add_child(map_frame)
	var map := TrackMap.new()
	map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map.points = _track_preview("BAHRAIN")
	map_frame.add_child(map)
	feature_box.add_child(_label("SAKHIR  /  BAHRAIN", 11, MUTED, true))
	var feature_bottom := HBoxContainer.new()
	feature_box.add_child(feature_bottom)
	feature_bottom.add_child(_label("RACE WEEKEND", 11, WHITE, true))
	var fill := Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feature_bottom.add_child(fill)
	feature_bottom.add_child(_label("LIGHTS OUT  •  2026", 10, RED, true))

	var footer := _label("ELDEN 1  /  PRE-RELEASE BUILD", 10, MUTED, true)
	footer.anchor_left = 0.72
	footer.anchor_right = 0.94
	footer.anchor_top = 0.955
	footer.anchor_bottom = 0.99
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	page_root.add_child(footer)

func _track_preview(track_name: String) -> PackedVector2Array:
	var path: String = TrackBuilder.TRACK_FILES.get(track_name, "")
	if path.is_empty() or not FileAccess.file_exists(path):
		return PackedVector2Array()
	var points := PackedVector2Array()
	if path.ends_with(".csv"):
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			return points
		while not file.eof_reached() and points.size() < 240:
			var fields := file.get_line().split(",")
			if fields.size() >= 2 and fields[0].strip_edges().is_valid_float() and fields[1].strip_edges().is_valid_float():
				points.append(Vector2(float(fields[0]), float(fields[1])))
		file.close()
	else:
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			return points
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		file.close()
		if parsed is Dictionary:
			var features: Array = parsed.get("features", [])
			if not features.is_empty():
				var coords: Array = features[0].get("geometry", {}).get("coordinates", [])
				for p in coords:
					if points.size() >= 240:
						break
					points.append(Vector2(float(p[0]), float(p[1])))
	if points.size() < 3:
		return PackedVector2Array()
	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	for p in points:
		min_x = minf(min_x, p.x)
		max_x = maxf(max_x, p.x)
		min_y = minf(min_y, p.y)
		max_y = maxf(max_y, p.y)
	var span_x := maxf(max_x - min_x, 0.001)
	var span_y := maxf(max_y - min_y, 0.001)
	var normalized := PackedVector2Array()
	for p in points:
		normalized.append(Vector2((p.x-min_x)/span_x, (p.y-min_y)/span_y))
	return normalized

func _on_nav_pressed(destination: String) -> void:
	match destination:
		"HOME":
			_build_home()
		"GRAND PRIX":
			_show_track_select()
		"GARAGE":
			_show_info("THE GARAGE", "The garage showcase is still in development.")
		"SETTINGS":
			_show_info("SETTINGS", "Graphics and control settings are not wired up yet.")

func _show_info(title_text: String, body_text: String) -> void:
	var overlay := AcceptDialog.new()
	overlay.title = title_text
	overlay.dialog_text = body_text
	add_child(overlay)
	overlay.popup_centered()

func _show_track_select() -> void:
	if is_instance_valid(page_root):
		page_root.queue_free()
	track_screen = Control.new()
	track_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(track_screen)
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track_screen.add_child(bg)

	var heading := _label("CHOOSE YOUR BATTLEFIELD", 36, WHITE, true)
	heading.anchor_left = 0.055
	heading.anchor_right = 0.8
	heading.anchor_top = 0.055
	heading.anchor_bottom = 0.12
	track_screen.add_child(heading)
	var kicker := _label("GRAND PRIX  /  2026 SEASON", 11, RED, true)
	kicker.anchor_left = 0.057
	kicker.anchor_right = 0.8
	kicker.anchor_top = 0.025
	kicker.anchor_bottom = 0.055
	track_screen.add_child(kicker)
	var back := _button("←  BACK")
	back.custom_minimum_size = Vector2(130, 44)
	back.anchor_left = 0.86
	back.anchor_right = 0.945
	back.anchor_top = 0.045
	back.anchor_bottom = 0.10
	back.pressed.connect(_build_home)
	track_screen.add_child(back)

	var scroll := ScrollContainer.new()
	scroll.anchor_left = 0.055
	scroll.anchor_right = 0.945
	scroll.anchor_top = 0.16
	scroll.anchor_bottom = 0.80
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	track_screen.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	scroll.add_child(grid)

	for i in range(TRACKS.size()):
		var track: Dictionary = TRACKS[i]
		var card := Button.new()
		card.custom_minimum_size = Vector2(300, 145)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.text = ""
		var normal := StyleBoxFlat.new()
		normal.bg_color = PANEL_ALT if track.name == selected_track else PANEL
		normal.border_color = RED if track.name == selected_track else LINE
		normal.set_border_width_all(1)
		normal.corner_radius_top_left = 7
		normal.corner_radius_top_right = 7
		normal.corner_radius_bottom_left = 7
		normal.corner_radius_bottom_right = 7
		var hover := normal.duplicate() as StyleBoxFlat
		hover.bg_color = Color("#202b38")
		hover.border_color = RED
		card.add_theme_stylebox_override("normal", normal)
		card.add_theme_stylebox_override("hover", hover)
		card.add_theme_stylebox_override("pressed", hover)
		grid.add_child(card)
		var map := TrackMap.new()
		map.position = Vector2(14, 18)
		map.size = Vector2(112, 105)
		map.points = _track_preview(track.name)
		map.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(map)
		var title := _label(track.name, 17, WHITE, true)
		title.position = Vector2(142, 34)
		title.size = Vector2(220, 28)
		card.add_child(title)
		var location := _label(track.location, 9, MUTED, true)
		location.position = Vector2(142, 66)
		location.size = Vector2(220, 32)
		location.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(location)
		var index := _label("%02d  /  12" % (i+1), 10, RED, true)
		index.position = Vector2(142, 108)
		index.size = Vector2(100, 18)
		card.add_child(index)
		card.pressed.connect(_select_track.bind(track.name))

	var bottom_rule := ColorRect.new()
	bottom_rule.color = LINE
	bottom_rule.anchor_left = 0.055
	bottom_rule.anchor_right = 0.945
	bottom_rule.anchor_top = 0.84
	bottom_rule.anchor_bottom = 0.842
	bottom_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track_screen.add_child(bottom_rule)
	var chosen := _label("SELECTED CIRCUIT     /     " + selected_track, 14, WHITE, true)
	chosen.anchor_left = 0.06
	chosen.anchor_right = 0.62
	chosen.anchor_top = 0.875
	chosen.anchor_bottom = 0.93
	track_screen.add_child(chosen)
	var start := _button("START RACE   →", true)
	start.anchor_left = 0.77
	start.anchor_right = 0.945
	start.anchor_top = 0.865
	start.anchor_bottom = 0.94
	start.pressed.connect(_on_start_race_pressed)
	track_screen.add_child(start)

func _select_track(track_name: String) -> void:
	selected_track = track_name
	_show_track_select()

func _on_start_race_pressed() -> void:
	get_tree().root.set_meta("selected_track", selected_track)
	var result := get_tree().change_scene_to_file("res://scenes/race.tscn")
	if result != OK:
		push_error("Failed to open race scene. Error code: %s" % result)

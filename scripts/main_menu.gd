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
			draw_circle(mapped[0], 4.0, Color("#f4f6f8"))

const TEAMS := ["Ferrari", "McLaren", "Mercedes", "Red Bull Racing", "Aston Martin", "Williams", "Alpine", "Haas", "Racing Bulls", "Audi", "Cadillac"]

var selected_track := "BAHRAIN"
var selected_team := "Ferrari"
var team_picker: OptionButton
var team_name_label: Label
var team_status_label: Label
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

class HeroCarArt extends Control:
	func _draw() -> void:
		var c := size
		var cx := c.x * 0.53
		var cy := c.y * 0.54
		var sx := minf(c.x, c.y) * 0.78
		var body := PackedVector2Array([
			Vector2(cx, cy-sx*0.58), Vector2(cx+sx*0.075, cy-sx*0.39),
			Vector2(cx+sx*0.12, cy-sx*0.12), Vector2(cx+sx*0.105, cy+sx*0.28),
			Vector2(cx+sx*0.18, cy+sx*0.49), Vector2(cx-sx*0.18, cy+sx*0.49),
			Vector2(cx-sx*0.105, cy+sx*0.28), Vector2(cx-sx*0.12, cy-sx*0.12),
			Vector2(cx-sx*0.075, cy-sx*0.39)
		])
		draw_colored_polygon(body, Color("#202a36"))
		draw_polyline(PackedVector2Array([body[0],body[1],body[2],body[3],body[4]]), Color("#e32636"), 3.0, true)
		draw_polyline(PackedVector2Array([body[4],body[5],body[6],body[7],body[8],body[0]]), Color("#e32636"), 3.0, true)
		draw_rect(Rect2(cx-sx*0.20,cy-sx*0.32,sx*0.40,sx*0.045), Color("#aeb9c6"))
		draw_rect(Rect2(cx-sx*0.235,cy+sx*0.37,sx*0.47,sx*0.055), Color("#e32636"))
		draw_rect(Rect2(cx-sx*0.16,cy-sx*0.17,sx*0.32,sx*0.16), Color("#0b1118"))
		for side in [-1.0,1.0]:
			for y in [-0.28,0.22]:
				draw_rect(Rect2(cx+side*sx*0.12-sx*0.035,cy+sx*y-sx*0.07,sx*0.07,sx*0.14), Color("#080b10"))
		draw_line(Vector2(cx,cy-sx*0.5), Vector2(cx,cy+sx*0.43), Color("#566272"), 1.0)
		draw_circle(Vector2(cx,cy-sx*0.01), sx*0.025, Color("#e32636"))

func _build_home() -> void:
	for child in get_children():
		child.queue_free()
	track_screen = null
	page_root = Control.new()
	page_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(page_root)

	var bg := ColorRect.new()
	bg.color = Color("#070a0f")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_root.add_child(bg)

	var glow := ColorRect.new()
	glow.color = Color("#101925")
	glow.anchor_left = 0.48
	glow.anchor_right = 1.0
	glow.anchor_top = 0.12
	glow.anchor_bottom = 0.91
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_root.add_child(glow)

	var header := HBoxContainer.new()
	header.anchor_left = 0.055
	header.anchor_right = 0.945
	header.anchor_top = 0.035
	header.anchor_bottom = 0.125
	header.add_theme_constant_override("separation", 24)
	page_root.add_child(header)

	var brand := VBoxContainer.new()
	brand.custom_minimum_size = Vector2(210, 0)
	brand.add_child(_label("ELDEN 1", 27, WHITE, true))
	brand.add_child(_label("MOTORSPORT  /  2026", 9, MUTED, true))
	header.add_child(brand)
	var header_spacer := Control.new()
	header.add_child(header_spacer)
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var season := _label("WORLD CHAMPIONSHIP  ·  SEASON 01", 10, MUTED, true)
	season.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(season)
	for nav in ["HOME", "GRAND PRIX", "GARAGE", "SETTINGS"]:
		var nav_button := Button.new()
		nav_button.text = nav
		nav_button.flat = true
		nav_button.add_theme_font_size_override("font_size", 11)
		nav_button.add_theme_color_override("font_color", RED if nav == "HOME" else MUTED)
		nav_button.add_theme_color_override("font_hover_color", WHITE)
		nav_button.pressed.connect(_on_nav_pressed.bind(nav))
		header.add_child(nav_button)

	var rule := ColorRect.new()
	rule.color = LINE
	rule.anchor_left = 0.055
	rule.anchor_right = 0.945
	rule.anchor_top = 0.135
	rule.anchor_bottom = 0.137
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_root.add_child(rule)

	var eyebrow := _label("01   /   THE 2026 SEASON", 11, RED, true)
	eyebrow.anchor_left = 0.075
	eyebrow.anchor_right = 0.58
	eyebrow.anchor_top = 0.225
	eyebrow.anchor_bottom = 0.265
	page_root.add_child(eyebrow)

	var hero := _label("OWN\nEVERY\nCORNER.", 67, WHITE, true)
	hero.anchor_left = 0.07
	hero.anchor_right = 0.57
	hero.anchor_top = 0.285
	hero.anchor_bottom = 0.59
	hero.add_theme_constant_override("line_spacing", -10)
	page_root.add_child(hero)

	var subtitle := _label("The lights go out. The fight is yours.", 17, MUTED)
	subtitle.anchor_left = 0.075
	subtitle.anchor_right = 0.57
	subtitle.anchor_top = 0.625
	subtitle.anchor_bottom = 0.67
	page_root.add_child(subtitle)

	var actions := HBoxContainer.new()
	actions.anchor_left = 0.075
	actions.anchor_right = 0.60
	actions.anchor_top = 0.715
	actions.anchor_bottom = 0.81
	actions.add_theme_constant_override("separation", 12)
	page_root.add_child(actions)
	var start := _button("START RACE     →", true)
	start.custom_minimum_size = Vector2(220, 58)
	start.pressed.connect(_show_track_select)
	actions.add_child(start)
	var garage := _button("GARAGE")
	garage.custom_minimum_size = Vector2(150, 58)
	garage.pressed.connect(_show_garage)
	actions.add_child(garage)

	var art_panel := PanelContainer.new()
	art_panel.anchor_left = 0.615
	art_panel.anchor_right = 0.925
	art_panel.anchor_top = 0.19
	art_panel.anchor_bottom = 0.815
	_style_panel(art_panel, Color("#0c121a"), Color("#283544"))
	page_root.add_child(art_panel)
	var art := HeroCarArt.new()
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_panel.add_child(art)
	var art_tag := _label("ELDEN 1  /  RACE SPEC", 10, MUTED, true)
	art_tag.anchor_left = 0.65
	art_tag.anchor_right = 0.90
	art_tag.anchor_top = 0.22
	art_tag.anchor_bottom = 0.26
	art_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	page_root.add_child(art_tag)
	var art_number := _label("01", 74, Color("#26313e"), true)
	art_number.anchor_left = 0.80
	art_number.anchor_right = 0.91
	art_number.anchor_top = 0.67
	art_number.anchor_bottom = 0.79
	art_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	page_root.add_child(art_number)

	var event_card := PanelContainer.new()
	event_card.anchor_left = 0.075
	event_card.anchor_right = 0.925
	event_card.anchor_top = 0.865
	event_card.anchor_bottom = 0.955
	_style_panel(event_card, Color("#111923"), Color("#26313e"))
	page_root.add_child(event_card)
	var event_row := HBoxContainer.new()
	event_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	event_row.add_theme_constant_override("separation", 22)
	event_card.add_child(event_row)
	var round_box := VBoxContainer.new()
	round_box.custom_minimum_size = Vector2(190, 0)
	round_box.add_child(_label("NEXT EVENT", 9, RED, true))
	round_box.add_child(_label("BAHRAIN GRAND PRIX", 15, WHITE, true))
	event_row.add_child(round_box)
	var event_map := TrackMap.new()
	event_map.custom_minimum_size = Vector2(160, 0)
	event_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	event_map.points = _track_preview("BAHRAIN")
	event_row.add_child(event_map)
	var circuit_info := VBoxContainer.new()
	circuit_info.custom_minimum_size = Vector2(190, 0)
	circuit_info.add_child(_label("SAKHIR  /  BAHRAIN", 11, WHITE, true))
	circuit_info.add_child(_label("ROUND 01     ·     2026", 9, MUTED, true))
	event_row.add_child(circuit_info)
	var stats := VBoxContainer.new()
	stats.custom_minimum_size = Vector2(120, 0)
	stats.add_child(_label("11 TEAMS", 11, WHITE, true))
	stats.add_child(_label("12 CIRCUITS", 9, MUTED, true))
	event_row.add_child(stats)

	var footer := _label("PRE-RELEASE  /  WINDOWS", 9, MUTED, true)
	footer.anchor_left = 0.72
	footer.anchor_right = 0.925
	footer.anchor_top = 0.965
	footer.anchor_bottom = 0.99
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	page_root.add_child(footer)

func _track_preview(track_name: String) -> PackedVector2Array:
	var path: String = TrackBuilder.TRACK_FILES.get(track_name, "")
	if path.is_empty() or not FileAccess.file_exists(path):
		return PackedVector2Array()
	var points := PackedVector2Array()
	if path.ends_with(".txt"):
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
			_show_garage()
		"SETTINGS":
			_show_info("SETTINGS", "Graphics and control settings are not wired up yet.")

func _show_garage() -> void:
	if is_instance_valid(page_root):
		page_root.queue_free()
	if is_instance_valid(track_screen):
		track_screen.queue_free()
	track_screen = null
	var garage_root := Control.new()
	garage_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(garage_root)

	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	garage_root.add_child(bg)

	var kicker := _label("TEAM MANAGEMENT  /  2026 SEASON", 11, RED, true)
	kicker.anchor_left = 0.07
	kicker.anchor_right = 0.8
	kicker.anchor_top = 0.07
	kicker.anchor_bottom = 0.11
	garage_root.add_child(kicker)
	var heading := _label("THE GARAGE", 42, WHITE, true)
	heading.anchor_left = 0.07
	heading.anchor_right = 0.8
	heading.anchor_top = 0.12
	heading.anchor_bottom = 0.20
	garage_root.add_child(heading)
	var back := _button("←  BACK")
	back.custom_minimum_size = Vector2(130, 44)
	back.anchor_left = 0.84
	back.anchor_right = 0.93
	back.anchor_top = 0.075
	back.anchor_bottom = 0.13
	back.pressed.connect(_build_home)
	garage_root.add_child(back)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.07
	panel.anchor_right = 0.93
	panel.anchor_top = 0.27
	panel.anchor_bottom = 0.82
	_style_panel(panel, PANEL, LINE)
	garage_root.add_child(panel)
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 34)
	panel.add_child(layout)

	var preview := HeroCarArt.new()
	preview.custom_minimum_size = Vector2(340, 0)
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(preview)

	var details := VBoxContainer.new()
	details.custom_minimum_size = Vector2(390, 0)
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 13)
	layout.add_child(details)
	details.add_child(_label("CHOOSE YOUR CONSTRUCTOR", 11, RED, true))
	team_name_label = _label(selected_team.to_upper(), 30, WHITE, true)
	details.add_child(team_name_label)
	details.add_child(_label("Select a team for your race entry.", 13, MUTED))
	team_picker = OptionButton.new()
	team_picker.custom_minimum_size = Vector2(320, 52)
	team_picker.add_theme_font_size_override("font_size", 16)
	team_picker.add_theme_color_override("font_color", WHITE)
	team_picker.add_theme_color_override("font_hover_color", WHITE)
	for team in TEAMS:
		team_picker.add_item(team)
	team_picker.select(TEAMS.find(selected_team))
	team_picker.item_selected.connect(_on_team_selected)
	details.add_child(team_picker)
	team_status_label = _label("CURRENT ENTRY  /  " + selected_team.to_upper(), 10, MUTED, true)
	details.add_child(team_status_label)
	var note := _label("Team selection is saved for this game session. Car liveries and team-specific 3D models are not yet implemented.", 11, MUTED)
	note.custom_minimum_size = Vector2(330, 55)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_child(note)

	var footer := _label("ELDEN 1  /  TEAM SELECTION", 9, MUTED, true)
	footer.anchor_left = 0.07
	footer.anchor_right = 0.93
	footer.anchor_top = 0.93
	footer.anchor_bottom = 0.97
	garage_root.add_child(footer)

func _on_team_selected(index: int) -> void:
	if index < 0 or index >= TEAMS.size():
		return
	selected_team = TEAMS[index]
	get_tree().root.set_meta("selected_team", selected_team)
	if is_instance_valid(team_name_label):
		team_name_label.text = selected_team.to_upper()
	if is_instance_valid(team_status_label):
		team_status_label.text = "CURRENT ENTRY  /  " + selected_team.to_upper()

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

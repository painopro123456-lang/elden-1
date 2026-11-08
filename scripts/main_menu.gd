extends Control

const BG := Color("#080a0e")
const PANEL := Color("#10141b")
const PANEL_HOVER := Color("#191f29")
const WHITE := Color("#f4f5f7")
const MUTED := Color("#929aa7")
const RED := Color("#e1262f")
const LINE := Color("#272d37")

const TRACKS := [
	{"name": "BAHRAIN", "location": "SAKHIR  /  BAHRAIN"},
	{"name": "JEDDAH", "location": "JEDDAH  /  SAUDI ARABIA"},
	{"name": "MELBOURNE", "location": "ALBERT PARK  /  AUSTRALIA"},
	{"name": "SUZUKA", "location": "SUZUKA  /  JAPAN"},
	{"name": "MONACO", "location": "MONTE CARLO  /  MONACO"},
	{"name": "SILVERSTONE", "location": "SILVERSTONE  /  UNITED KINGDOM"},
	{"name": "SPA-FRANCORCHAMPS", "location": "STAVELOT  /  BELGIUM"},
	{"name": "MONZA", "location": "MONZA  /  ITALY"},
	{"name": "SINGAPORE", "location": "MARINA BAY  /  SINGAPORE"},
	{"name": "AUSTIN", "location": "CIRCUIT OF THE AMERICAS  /  USA"},
	{"name": "MEXICO CITY", "location": "HERMANOS RODRIGUEZ  /  MEXICO"},
	{"name": "ABU DHABI", "location": "YAS MARINA  /  UAE"}
]

var content_title: Label
var content_body: Label
var active_nav := "HOME"
var selected_track := "BAHRAIN"
var track_screen: Control

func _ready() -> void:
	_build_menu()

func _build_menu() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var edge := ColorRect.new()
	edge.color = RED
	edge.position = Vector2(0, 0)
	edge.size = Vector2(7, 1080)
	edge.anchor_bottom = 1.0
	edge.offset_bottom = 0
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(edge)

	var top_line := ColorRect.new()
	top_line.color = LINE
	top_line.position = Vector2(72, 105)
	top_line.size = Vector2(1776, 1)
	top_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_line)

	var brand := _label("ELDEN 1", 30, WHITE, true)
	brand.position = Vector2(92, 42)
	brand.size = Vector2(260, 48)
	add_child(brand)

	var edition := _label("MOTORSPORT  /  2026", 11, MUTED, true)
	edition.position = Vector2(95, 82)
	edition.size = Vector2(260, 18)
	add_child(edition)

	var top_right := _label("BUILT FOR THE GRID", 12, MUTED, true)
	top_right.position = Vector2(1510, 56)
	top_right.size = Vector2(330, 25)
	top_right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(top_right)

	var nav_caption := _label("MAIN MENU", 11, MUTED, true)
	nav_caption.position = Vector2(96, 184)
	nav_caption.size = Vector2(250, 22)
	add_child(nav_caption)

	var nav_items := [
		{"name": "HOME", "number": "01"},
		{"name": "CAREER", "number": "02"},
		{"name": "GRAND PRIX", "number": "03"},
		{"name": "TIME TRIAL", "number": "04"},
		{"name": "GARAGE", "number": "05"},
		{"name": "SETTINGS", "number": "06"}
	]
	for i in range(nav_items.size()):
		var item: Dictionary = nav_items[i]
		var button := _make_nav_button(item["number"], item["name"], i == 0)
		button.position = Vector2(88, 235 + i * 76)
		button.size = Vector2(390, 58)
		button.pressed.connect(_on_nav_pressed.bind(item["name"]))
		add_child(button)

	var left_footer := _label("2026 SEASON  •  WINDOWS EDITION", 10, MUTED, true)
	left_footer.position = Vector2(96, 1005)
	left_footer.size = Vector2(360, 22)
	add_child(left_footer)

	var hero_frame := Panel.new()
	hero_frame.position = Vector2(540, 160)
	hero_frame.size = Vector2(1280, 760)
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = PANEL
	frame_style.border_color = LINE
	frame_style.set_border_width_all(1)
	frame_style.corner_radius_top_left = 3
	frame_style.corner_radius_top_right = 3
	frame_style.corner_radius_bottom_left = 3
	frame_style.corner_radius_bottom_right = 3
	hero_frame.add_theme_stylebox_override("panel", frame_style)
	add_child(hero_frame)

	var hero_kicker := _label("01   /   THE 2026 WORLD CHAMPIONSHIP", 12, RED, true)
	hero_kicker.position = Vector2(600, 220)
	hero_kicker.size = Vector2(700, 24)
	add_child(hero_kicker)

	var hero_title := _label("THE GRID\nIS YOURS.", 76, WHITE, true)
	hero_title.position = Vector2(590, 310)
	hero_title.size = Vector2(820, 205)
	add_child(hero_title)

	var hero_subtitle := _label("Every lap has a consequence. Every decision matters.", 19, MUTED, false)
	hero_subtitle.position = Vector2(600, 540)
	hero_subtitle.size = Vector2(800, 38)
	add_child(hero_subtitle)

	var red_rule := ColorRect.new()
	red_rule.color = RED
	red_rule.position = Vector2(600, 630)
	red_rule.size = Vector2(72, 4)
	add_child(red_rule)

	var season_label := _label("SEASON 2026", 12, WHITE, true)
	season_label.position = Vector2(600, 660)
	season_label.size = Vector2(200, 24)
	add_child(season_label)

	var season_detail := _label("11 TEAMS     /     22 DRIVERS     /     ONE WORLD TITLE", 12, MUTED, true)
	season_detail.position = Vector2(600, 690)
	season_detail.size = Vector2(700, 24)
	add_child(season_detail)

	content_title = _label("WELCOME TO ELDEN 1", 13, WHITE, true)
	content_title.position = Vector2(600, 805)
	content_title.size = Vector2(650, 24)
	add_child(content_title)

	content_body = _label("Select a destination from the menu. Race modes will activate as they are built.", 12, MUTED, false)
	content_body.position = Vector2(600, 833)
	content_body.size = Vector2(1080, 30)
	add_child(content_body)

	var version := _label("PRE-RELEASE  •  GAMEPLAY IN DEVELOPMENT", 10, MUTED, true)
	version.position = Vector2(1450, 1005)
	version.size = Vector2(370, 22)
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(version)

func _label(value: String, font_size: int, color: Color, bold: bool) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if bold:
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _make_nav_button(number: String, title: String, selected: bool) -> Button:
	var button := Button.new()
	button.text = "   " + number + "       " + title
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.flat = false
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", WHITE if selected else MUTED)
	button.add_theme_color_override("font_hover_color", WHITE)
	button.add_theme_color_override("font_pressed_color", WHITE)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#171b22") if selected else Color(0, 0, 0, 0)
	normal.border_color = RED if selected else Color(0, 0, 0, 0)
	normal.border_width_left = 3 if selected else 0
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.corner_radius_top_left = 2
	normal.corner_radius_top_right = 2
	normal.corner_radius_bottom_left = 2
	normal.corner_radius_bottom_right = 2
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = PANEL_HOVER
	hover.border_color = RED
	hover.border_width_left = 3
	var pressed := hover.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("#222a35")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return button

func _on_nav_pressed(destination: String) -> void:
	active_nav = destination
	if destination == "GRAND PRIX":
		_show_track_select()
		return
	if is_instance_valid(track_screen):
		track_screen.queue_free()
		track_screen = null
	if destination == "HOME":
		content_title.text = "WELCOME TO ELDEN 1"
		content_body.text = "Your 2026 season begins here."
	elif destination == "SETTINGS":
		content_title.text = "SETTINGS"
		content_body.text = "Graphics, audio and controls configuration is planned for the playable build."
	elif destination == "GARAGE":
		content_title.text = "THE GARAGE"
		content_body.text = "The SF-26 base car and 2026 team liveries are the current vehicle plan."
	else:
		content_title.text = destination
		content_body.text = "This mode is planned. It will open when its gameplay systems are ready."

func _show_track_select() -> void:
	if is_instance_valid(track_screen):
		track_screen.queue_free()

	track_screen = Control.new()
	track_screen.position = Vector2(540, 160)
	track_screen.size = Vector2(1280, 760)
	track_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(track_screen)

	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = LINE
	style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", style)
	track_screen.add_child(panel)

	var kicker := _label("GRAND PRIX  /  RACE WEEKEND", 12, RED, true)
	kicker.position = Vector2(54, 38)
	kicker.size = Vector2(500, 24)
	track_screen.add_child(kicker)

	var heading := _label("SELECT YOUR CIRCUIT", 38, WHITE, true)
	heading.position = Vector2(54, 76)
	heading.size = Vector2(800, 54)
	track_screen.add_child(heading)

	var subtitle := _label("Choose where the lights go out.", 15, MUTED, false)
	subtitle.position = Vector2(56, 137)
	subtitle.size = Vector2(700, 28)
	track_screen.add_child(subtitle)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.position = Vector2(54, 190)
	grid.size = Vector2(1170, 420)
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 10)
	track_screen.add_child(grid)

	for track in TRACKS:
		var track_button := Button.new()
		track_button.custom_minimum_size = Vector2(570, 58)
		track_button.text = "   " + track["name"] + "     /     " + track["location"]
		track_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		track_button.add_theme_font_size_override("font_size", 14)
		track_button.add_theme_color_override("font_color", WHITE if track["name"] == selected_track else MUTED)
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color("#202630") if track["name"] == selected_track else Color("#151a22")
		normal.border_color = RED if track["name"] == selected_track else LINE
		normal.set_border_width_all(1)
		normal.content_margin_left = 12
		var hover := normal.duplicate() as StyleBoxFlat
		hover.bg_color = PANEL_HOVER
		hover.border_color = RED
		track_button.add_theme_stylebox_override("normal", normal)
		track_button.add_theme_stylebox_override("hover", hover)
		track_button.add_theme_stylebox_override("pressed", hover)
		track_button.pressed.connect(_select_track.bind(track["name"]))
		grid.add_child(track_button)

	var separator := ColorRect.new()
	separator.color = LINE
	separator.position = Vector2(54, 632)
	separator.size = Vector2(1170, 1)
	track_screen.add_child(separator)

	var chosen := _label("SELECTED CIRCUIT     /     " + selected_track, 13, WHITE, true)
	chosen.name = "SelectedTrackLabel"
	chosen.position = Vector2(56, 656)
	chosen.size = Vector2(620, 28)
	track_screen.add_child(chosen)

	var start_button := Button.new()
	start_button.text = "START RACE"
	start_button.position = Vector2(930, 650)
	start_button.size = Vector2(294, 58)
	start_button.add_theme_font_size_override("font_size", 16)
	start_button.add_theme_color_override("font_color", WHITE)
	var start_style := StyleBoxFlat.new()
	start_style.bg_color = RED
	start_style.set_border_width_all(0)
	var start_hover := start_style.duplicate() as StyleBoxFlat
	start_hover.bg_color = Color("#ff3942")
	start_button.add_theme_stylebox_override("normal", start_style)
	start_button.add_theme_stylebox_override("hover", start_hover)
	start_button.add_theme_stylebox_override("pressed", start_style)
	start_button.pressed.connect(_on_start_race_pressed)
	track_screen.add_child(start_button)

func _select_track(track_name: String) -> void:
	selected_track = track_name
	_show_track_select()

func _on_start_race_pressed() -> void:
	get_tree().root.set_meta("selected_track", selected_track)
	get_tree().change_scene_to_file("res://scenes/race.tscn")

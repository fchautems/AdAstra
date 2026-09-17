extends CanvasLayer

signal explore_requested
signal resume_requested
signal quit_requested
signal fullscreen_requested
signal audio_volume_changed(kind: String, value: float)

var zone_label: Label
var help_card: PanelContainer
var pause_menu: PanelContainer
var start_menu: PanelContainer
var crosshair: Label
var help_time := 0.0
var showing_pause := false
var started := false

const IVORY := Color("f2f0e9")
const GRAPHITE := Color("1c2427", 0.86)
const CYAN := Color("a9dce0")

func _ready() -> void:
	layer = 10
	build_hud()
	build_start_menu()
	build_pause_menu()

func panel_style(color: Color, radius := 10, border := Color("ffffff", 0.12)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = border
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style

func label(text: String, size := 14, color := IVORY) -> Label:
	var item := Label.new()
	item.text = text
	item.add_theme_font_size_override("font_size", size)
	item.add_theme_color_override("font_color", color)
	return item

func button(text: String) -> Button:
	var item := Button.new()
	item.text = text
	item.custom_minimum_size = Vector2(250, 42)
	item.add_theme_font_size_override("font_size", 15)
	item.add_theme_color_override("font_color", IVORY)
	item.add_theme_stylebox_override("normal", panel_style(Color("ffffff", .06), 7, Color("ffffff", .16)))
	item.add_theme_stylebox_override("hover", panel_style(Color("a9dce0", .16), 7, CYAN))
	item.add_theme_stylebox_override("pressed", panel_style(Color("a9dce0", .25), 7, CYAN))
	return item

func build_hud() -> void:
	zone_label = label("COULOIR", 12, Color("e9e8e1", .75))
	zone_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	zone_label.position = Vector2(24, 21)
	add_child(zone_label)
	crosshair = label("·", 22, Color("f3f0e8", .70))
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.position -= Vector2(4, 12)
	add_child(crosshair)
	help_card = PanelContainer.new()
	help_card.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	help_card.position = Vector2(22, -112)
	help_card.add_theme_stylebox_override("panel", panel_style(GRAPHITE, 9))
	var help := label("ZQSD / WASD  Déplacer\nSouris  Regarder · Maj  Accélérer\nÉchap  Menu · F11  Plein écran", 13, Color("f2f0e9", .84))
	help.add_theme_constant_override("line_spacing", 5)
	help_card.add_child(help)
	add_child(help_card)

func build_start_menu() -> void:
	start_menu = PanelContainer.new()
	start_menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	start_menu.position = Vector2(-160, -118)
	start_menu.custom_minimum_size = Vector2(320, 236)
	start_menu.add_theme_stylebox_override("panel", panel_style(Color("172024", .92), 13, Color("a9dce0", .25)))
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 12)
	var title := label("AD ASTRA", 30, IVORY)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var subtitle := label("PREMIER PAS", 11, CYAN)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(subtitle)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 12
	column.add_child(spacer)
	var explore := button("Explorer")
	explore.pressed.connect(func(): explore_requested.emit())
	column.add_child(explore)
	var quit := button("Quitter")
	quit.pressed.connect(func(): quit_requested.emit())
	column.add_child(quit)
	start_menu.add_child(column)
	add_child(start_menu)

func build_pause_menu() -> void:
	pause_menu = PanelContainer.new()
	pause_menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pause_menu.position = Vector2(-160, -225)
	pause_menu.custom_minimum_size = Vector2(320, 450)
	pause_menu.add_theme_stylebox_override("panel", panel_style(Color("172024", .94), 13, Color("a9dce0", .28)))
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 10)
	var title := label("PAUSE", 22, IVORY)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var resume := button("Reprendre")
	resume.pressed.connect(func(): resume_requested.emit())
	column.add_child(resume)
	var help := button("Aide / Commandes")
	help.pressed.connect(show_help)
	column.add_child(help)
	var full := button("Plein écran / Fenêtre")
	full.pressed.connect(func(): fullscreen_requested.emit())
	column.add_child(full)
	column.add_child(HSeparator.new())
	var audio_title := label("AUDIO", 11, CYAN)
	audio_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(audio_title)
	add_volume_control(column,"Musique","music",.16)
	add_volume_control(column,"Ambiance","ambience",.28)
	add_volume_control(column,"Effets","effects",.62)
	var quit := button("Quitter")
	quit.pressed.connect(func(): quit_requested.emit())
	column.add_child(quit)
	pause_menu.add_child(column)
	pause_menu.hide()
	add_child(pause_menu)

func add_volume_control(column: VBoxContainer, title: String, kind: String, initial: float) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",10)
	var caption := label(title,13,Color("f2f0e9",.84))
	caption.custom_minimum_size.x = 82
	row.add_child(caption)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = .01
	slider.value = initial
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var value := label(str(roundi(initial*100))+"%",12,CYAN)
	value.custom_minimum_size.x = 34
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	slider.value_changed.connect(func(level: float):
		value.text = str(roundi(level*100))+"%"
		audio_volume_changed.emit(kind,level)
	)
	row.add_child(slider)
	row.add_child(value)
	column.add_child(row)

func begin() -> void:
	started = true
	start_menu.hide()
	show_help()

func set_zone(title: String) -> void:
	zone_label.text = title

func show_help() -> void:
	help_time = 6.0
	help_card.show()

func toggle_pause() -> bool:
	if not started:
		return false
	showing_pause = not showing_pause
	pause_menu.visible = showing_pause
	if showing_pause:
		help_card.hide()
	return showing_pause

func hide_pause() -> void:
	showing_pause = false
	pause_menu.hide()

func _process(delta: float) -> void:
	if help_time > 0.0 and not showing_pause:
		help_time -= delta
		if help_time <= 0.0:
			help_card.hide()

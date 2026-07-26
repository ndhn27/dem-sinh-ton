extends CanvasLayer

var game = null

var hud_root: Control
var hp_bar: ProgressBar
var xp_bar: ProgressBar
var level_label: Label
var timer_label: Label
var kills_label: Label
var loadout_box: HBoxContainer
var dash_button: Button

var start_panel: Control
var levelup_panel: Control
var card_box: HBoxContainer
var pause_panel: Control
var gameover_panel: Control
var gameover_stage_label: Label
var final_time_label: Label
var final_level_label: Label
var final_kills_label: Label
var modifier_label: Label
var victory_panel: Control
var victory_stage_label: Label
var victory_level_label: Label
var victory_kills_label: Label

var joystick_base: Control
var joystick_nub: Control

var toast_layer: Control

const COL_TEXT = Color("#f1ecf7")
const COL_DIM = Color("#a89bc2")
const COL_GOLD = Color("#e8b84b")
const COL_RED = Color("#d0344c")
const COL_VIOLET = Color("#8b5cf6")

func _label(text: String, size: int, color: Color) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _panel_style(alpha := 0.93) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.024, 0.02, 0.043, alpha)
	return sb

func _card_style() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.059, 0.047, 0.078, 0.95)
	sb.border_color = Color(0.486, 0.227, 0.949, 0.35)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	return sb

func _button_style() -> Button:
	var b = Button.new()
	var normal = StyleBoxFlat.new()
	normal.bg_color = COL_VIOLET
	normal.set_corner_radius_all(999)
	normal.content_margin_left = 34
	normal.content_margin_right = 34
	normal.content_margin_top = 12
	normal.content_margin_bottom = 12
	var hover = normal.duplicate()
	hover.bg_color = COL_VIOLET.lightened(0.18)
	var pressed = normal.duplicate()
	pressed.bg_color = COL_VIOLET.darkened(0.22)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", hover)
	b.add_theme_font_size_override("font_size", 16)
	b.add_theme_color_override("font_color", Color(1, 1, 1))
	return b

func build():
	_build_vignette()
	_build_hud()
	_build_joystick()
	_build_dash_button()
	_build_start_screen()
	_build_levelup_screen()
	_build_pause_screen()
	_build_gameover_screen()
	_build_victory_screen()
	toast_layer = Control.new()
	toast_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	toast_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(toast_layer)

func _build_vignette():
	var rect = TextureRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	var grad = Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 0))
	grad.set_color(1, Color(0, 0, 0, 0.5))
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 512
	tex.height = 512
	rect.texture = tex
	add_child(rect)

# ---------------- HUD ----------------
func _build_hud():
	hud_root = Control.new()
	hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.visible = false
	add_child(hud_root)

	# --- left: HP ---
	var left = VBoxContainer.new()
	left.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	left.position = Vector2(18, 14)
	left.custom_minimum_size = Vector2(150, 0)
	left.add_theme_constant_override("separation", 6)
	hud_root.add_child(left)
	left.add_child(_label("MÁU", 11, COL_DIM))
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(150, 12)
	hp_bar.min_value = 0; hp_bar.max_value = 100; hp_bar.value = 100
	hp_bar.show_percentage = false
	var hp_bg = StyleBoxFlat.new(); hp_bg.bg_color = Color(1,1,1,0.06); hp_bg.set_corner_radius_all(6); hp_bg.border_color = Color(1,1,1,0.15); hp_bg.set_border_width_all(1)
	var hp_fill = StyleBoxFlat.new(); hp_fill.bg_color = COL_RED; hp_fill.set_corner_radius_all(6)
	hp_bar.add_theme_stylebox_override("background", hp_bg)
	hp_bar.add_theme_stylebox_override("fill", hp_fill)
	left.add_child(hp_bar)

	# --- center: level + xp ---
	var center = VBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	center.position.y = 14
	center.custom_minimum_size = Vector2(120, 0)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 4)
	hud_root.add_child(center)
	level_label = _label("1", 14, COL_TEXT)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(level_label)
	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size = Vector2(120, 12)
	xp_bar.min_value = 0; xp_bar.max_value = 100; xp_bar.value = 0
	xp_bar.show_percentage = false
	var xp_bg = StyleBoxFlat.new(); xp_bg.bg_color = Color(1,1,1,0.06); xp_bg.set_corner_radius_all(6); xp_bg.border_color = Color(1,1,1,0.15); xp_bg.set_border_width_all(1)
	var xp_fill = StyleBoxFlat.new(); xp_fill.bg_color = COL_VIOLET; xp_fill.set_corner_radius_all(6)
	xp_bar.add_theme_stylebox_override("background", xp_bg)
	xp_bar.add_theme_stylebox_override("fill", xp_fill)
	center.add_child(xp_bar)

	# --- right: timer + kills ---
	var right = VBoxContainer.new()
	right.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	right.position = Vector2(-160, 14)
	right.custom_minimum_size = Vector2(150, 0)
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	right.add_theme_constant_override("separation", 4)
	hud_root.add_child(right)
	timer_label = _label("00:00", 20, COL_TEXT)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(timer_label)
	kills_label = _label("0 hạ gục", 12, COL_DIM)
	kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(kills_label)
	modifier_label = _label("", 10, COL_VIOLET)
	modifier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(modifier_label)
	var pause_btn = _button_style()
	pause_btn.text = "II"
	pause_btn.custom_minimum_size = Vector2(34, 34)
	pause_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_btn.pressed.connect(func(): game.toggle_pause())
	right.add_child(pause_btn)

	# --- loadout row (bottom-left) ---
	loadout_box = HBoxContainer.new()
	loadout_box.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	loadout_box.position = Vector2(14, -50)
	loadout_box.add_theme_constant_override("separation", 6)
	hud_root.add_child(loadout_box)

func update_hud():
	var p = game.player
	if p == null:
		return
	hp_bar.max_value = p.max_health
	hp_bar.value = p.health
	xp_bar.max_value = p.xp_to_next
	xp_bar.value = p.xp
	level_label.text = str(p.level)
	var remain = max(0.0, game.time_limit - game.elapsed)
	var m = int(remain) / 60
	var s = int(remain) % 60
	timer_label.text = "%02d:%02d" % [m, s]
	kills_label.text = str(game.kills) + " hạ gục"
	modifier_label.text = game.current_modifier.get("name", "")
	if p.relics.has("boots"):
		dash_button.visible = true
		dash_button.modulate.a = 0.4 if p.dash_cooldown > 0 else 1.0
	else:
		dash_button.visible = false

func update_loadout():
	for c in loadout_box.get_children():
		c.queue_free()
	var p = game.player
	if p == null:
		return
	for key in p.weapons.keys():
		var icon = _label(game.weapon_icon(key), 15, COL_TEXT)
		var box = _panel_icon(icon)
		loadout_box.add_child(box)
	for key in p.relics.keys():
		var icon = _label(game.relic_icon(key), 15, COL_TEXT)
		var box = _panel_icon(icon)
		loadout_box.add_child(box)

func _panel_icon(inner: Control) -> PanelContainer:
	var box = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.059, 0.047, 0.078, 0.92)
	sb.border_color = Color(0.486, 0.227, 0.949, 0.28)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 6; sb.content_margin_right = 6
	sb.content_margin_top = 6; sb.content_margin_bottom = 6
	box.add_theme_stylebox_override("panel", sb)
	box.add_child(inner)
	return box

# ---------------- Joystick ----------------
func _build_joystick():
	joystick_base = Control.new()
	joystick_base.custom_minimum_size = Vector2(88, 88)
	joystick_base.size = Vector2(88, 88)
	joystick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	joystick_base.visible = false
	var bg = Panel.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.05)
	sb.border_color = Color(1, 1, 1, 0.18)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(44)
	bg.add_theme_stylebox_override("panel", sb)
	joystick_base.add_child(bg)
	joystick_nub = Panel.new()
	joystick_nub.size = Vector2(38, 38)
	joystick_nub.position = Vector2(25, 25)
	var nsb = StyleBoxFlat.new()
	nsb.bg_color = Color(0.545, 0.361, 0.965, 0.35)
	nsb.border_color = Color(0.545, 0.361, 0.965, 0.6)
	nsb.set_border_width_all(1)
	nsb.set_corner_radius_all(19)
	joystick_nub.add_theme_stylebox_override("panel", nsb)
	joystick_base.add_child(joystick_nub)
	add_child(joystick_base)

func set_joystick(origin: Vector2, offset: Vector2, active: bool):
	joystick_base.visible = active
	if active:
		joystick_base.position = origin - Vector2(44, 44)
		joystick_nub.position = Vector2(25, 25) + offset

# ---------------- Dash button ----------------
func _build_dash_button():
	dash_button = _button_style()
	dash_button.text = "💨"
	dash_button.custom_minimum_size = Vector2(56, 56)
	dash_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	dash_button.position = Vector2(-70, -70)
	dash_button.visible = false
	dash_button.pressed.connect(func(): game.try_dash())
	add_child(dash_button)

# ---------------- Start screen ----------------
func _build_start_screen():
	start_panel = _full_overlay()
	var glow = TextureRect.new()
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	glow.size = Vector2(520, 520)
	glow.position = Vector2(-260, -360)
	var glow_grad = Gradient.new()
	glow_grad.set_color(0, Color(0.784, 0.204, 0.298, 0.4))
	glow_grad.set_color(1, Color(0.784, 0.204, 0.298, 0.0))
	var glow_tex = GradientTexture2D.new()
	glow_tex.gradient = glow_grad
	glow_tex.fill = GradientTexture2D.FILL_RADIAL
	glow_tex.fill_from = Vector2(0.5, 0.5)
	glow_tex.fill_to = Vector2(1.0, 0.5)
	glow_tex.width = 256
	glow_tex.height = 256
	glow.texture = glow_tex
	start_panel.add_child(glow)

	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	_center_in(box, start_panel)

	var title = _label("ĐÊM SINH TỒN", 44, COL_RED)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var subtitle = _label("Chọn một màn chơi. Sống sót đến hết giờ là chiến thắng — mỗi trận có một biến số ngẫu nhiên riêng.", 14, COL_DIM)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.custom_minimum_size = Vector2(440, 0)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD
	box.add_child(subtitle)

	var stage_box = HBoxContainer.new()
	stage_box.add_theme_constant_override("separation", 14)
	stage_box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(stage_box)
	for i in range(game.STAGE_DEFS.size()):
		stage_box.add_child(_stage_card(i, game.STAGE_DEFS[i]))

	var instr = PanelContainer.new()
	instr.add_theme_stylebox_override("panel", _card_style())
	var instr_box = VBoxContainer.new()
	instr_box.add_theme_constant_override("separation", 6)
	instr.add_child(instr_box)
	instr_box.add_child(_label("Máy tính: WASD / phím mũi tên để di chuyển, Shift để Lướt", 13, COL_TEXT))
	instr_box.add_child(_label("Điện thoại: chạm và kéo để di chuyển", 13, COL_TEXT))
	instr_box.add_child(_label("Đánh bại Trùm để nhận Trang Bị đặc biệt", 12, COL_DIM))
	box.add_child(instr)

func _stage_card(idx: int, stage: Dictionary) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(190, 170)
	var normal_sb = _card_style()
	var hover_sb = _card_style()
	hover_sb.border_color = COL_VIOLET
	hover_sb.set_border_width_all(2)
	hover_sb.bg_color = Color(0.075, 0.06, 0.1, 0.97)
	var pressed_sb = _card_style()
	pressed_sb.bg_color = Color(0.04, 0.03, 0.06, 0.97)
	pressed_sb.border_color = COL_GOLD
	btn.add_theme_stylebox_override("normal", normal_sb)
	btn.add_theme_stylebox_override("hover", hover_sb)
	btn.add_theme_stylebox_override("pressed", pressed_sb)
	btn.add_theme_stylebox_override("focus", hover_sb)
	var inner = VBoxContainer.new()
	inner.alignment = BoxContainer.ALIGNMENT_BEGIN
	inner.add_theme_constant_override("separation", 6)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var name_l = _label(stage.name, 15, COL_TEXT)
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD
	var desc_l = _label(stage.desc, 11, COL_DIM)
	desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_l.custom_minimum_size = Vector2(165, 0)
	var minutes = int(stage.time_limit) / 60
	var time_l = _label(str(minutes) + " phút", 12, COL_GOLD)
	inner.add_child(name_l)
	inner.add_child(desc_l)
	inner.add_child(time_l)
	btn.add_child(inner)
	btn.pressed.connect(func(): game.start_game(idx))
	return btn

# ---------------- Level-up screen ----------------
func _build_levelup_screen():
	levelup_panel = _full_overlay()
	levelup_panel.visible = false
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	_center_in(box, levelup_panel)

	var title = _label("Lên cấp!", 24, COL_TEXT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var sub = _label("Chọn một nâng cấp", 13, COL_DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)

	card_box = HBoxContainer.new()
	card_box.add_theme_constant_override("separation", 14)
	card_box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(card_box)

func show_levelup(picks: Array):
	for c in card_box.get_children():
		c.queue_free()
	for item in picks:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(170, 150)
		var normal_sb = _card_style()
		var hover_sb = _card_style()
		hover_sb.border_color = COL_VIOLET
		hover_sb.set_border_width_all(2)
		hover_sb.bg_color = Color(0.075, 0.06, 0.1, 0.97)
		var pressed_sb = _card_style()
		pressed_sb.bg_color = Color(0.04, 0.03, 0.06, 0.97)
		pressed_sb.border_color = COL_GOLD
		btn.add_theme_stylebox_override("normal", normal_sb)
		btn.add_theme_stylebox_override("hover", hover_sb)
		btn.add_theme_stylebox_override("pressed", pressed_sb)
		btn.add_theme_stylebox_override("focus", hover_sb)
		var inner = VBoxContainer.new()
		inner.alignment = BoxContainer.ALIGNMENT_BEGIN
		inner.add_theme_constant_override("separation", 6)
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var icon_l = _label(item.icon, 30, COL_TEXT)
		var name_l = _label(item.name, 14, COL_TEXT)
		name_l.autowrap_mode = TextServer.AUTOWRAP_WORD
		var desc_l = _label(item.desc, 11, COL_DIM)
		desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_l.custom_minimum_size = Vector2(150, 0)
		var lvl_l = _label(item.level_label, 10, COL_GOLD)
		inner.add_child(icon_l)
		inner.add_child(name_l)
		inner.add_child(desc_l)
		inner.add_child(lvl_l)
		btn.add_child(inner)
		btn.pressed.connect(func(): game.apply_upgrade_choice(item))
		card_box.add_child(btn)
	levelup_panel.visible = true

func hide_levelup():
	levelup_panel.visible = false

# ---------------- Pause screen ----------------
func _build_pause_screen():
	pause_panel = _full_overlay()
	pause_panel.visible = false
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	_center_in(box, pause_panel)
	var title = _label("Tạm dừng", 24, COL_TEXT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var resume_btn = _button_style()
	resume_btn.text = "Tiếp tục"
	resume_btn.pressed.connect(func(): game.toggle_pause())
	box.add_child(resume_btn)

# ---------------- Game over screen ----------------
func _build_gameover_screen():
	gameover_panel = _full_overlay()
	gameover_panel.visible = false
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	_center_in(box, gameover_panel)

	var title = _label("Bạn đã ngã xuống", 30, COL_RED)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	gameover_stage_label = _label("", 13, COL_DIM)
	gameover_stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(gameover_stage_label)

	var stats = PanelContainer.new()
	stats.add_theme_stylebox_override("panel", _card_style())
	var stats_box = VBoxContainer.new()
	stats_box.custom_minimum_size = Vector2(240, 0)
	stats_box.add_theme_constant_override("separation", 8)
	stats.add_child(stats_box)

	var row1 = HBoxContainer.new()
	row1.add_child(_label("Thời gian sống sót", 13, COL_TEXT))
	var spacer1 = Control.new(); spacer1.custom_minimum_size = Vector2(20,0)
	row1.add_child(spacer1)
	final_time_label = _label("00:00", 13, COL_GOLD)
	row1.add_child(final_time_label)
	stats_box.add_child(row1)

	var row2 = HBoxContainer.new()
	row2.add_child(_label("Cấp độ đạt được", 13, COL_TEXT))
	var spacer2 = Control.new(); spacer2.custom_minimum_size = Vector2(20,0)
	row2.add_child(spacer2)
	final_level_label = _label("1", 13, COL_GOLD)
	row2.add_child(final_level_label)
	stats_box.add_child(row2)

	var row3 = HBoxContainer.new()
	row3.add_child(_label("Quái đã hạ gục", 13, COL_TEXT))
	var spacer3 = Control.new(); spacer3.custom_minimum_size = Vector2(20,0)
	row3.add_child(spacer3)
	final_kills_label = _label("0", 13, COL_GOLD)
	row3.add_child(final_kills_label)
	stats_box.add_child(row3)

	box.add_child(stats)

	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	box.add_child(btn_row)
	var retry_btn = _button_style()
	retry_btn.text = "Chơi lại"
	retry_btn.pressed.connect(func(): game.start_game())
	btn_row.add_child(retry_btn)
	var menu_btn = _button_style()
	menu_btn.text = "Chọn màn khác"
	menu_btn.pressed.connect(func(): game.return_to_menu())
	btn_row.add_child(menu_btn)

func show_gameover():
	gameover_stage_label.text = game.current_stage.get("name", "") + " — " + game.current_modifier.get("name", "")
	var m = int(game.elapsed) / 60
	var s = int(game.elapsed) % 60
	final_time_label.text = "%02d:%02d" % [m, s]
	final_level_label.text = str(game.player.level)
	final_kills_label.text = str(game.kills)
	gameover_panel.visible = true

# ---------------- Victory screen ----------------
func _build_victory_screen():
	victory_panel = _full_overlay()
	victory_panel.visible = false
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	_center_in(box, victory_panel)

	var title = _label("Sống Sót Thành Công!", 30, COL_GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	victory_stage_label = _label("", 13, COL_DIM)
	victory_stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(victory_stage_label)

	var stats = PanelContainer.new()
	stats.add_theme_stylebox_override("panel", _card_style())
	var stats_box = VBoxContainer.new()
	stats_box.custom_minimum_size = Vector2(240, 0)
	stats_box.add_theme_constant_override("separation", 8)
	stats.add_child(stats_box)

	var row2 = HBoxContainer.new()
	row2.add_child(_label("Cấp độ đạt được", 13, COL_TEXT))
	var spacer2 = Control.new(); spacer2.custom_minimum_size = Vector2(20, 0)
	row2.add_child(spacer2)
	victory_level_label = _label("1", 13, COL_GOLD)
	row2.add_child(victory_level_label)
	stats_box.add_child(row2)

	var row3 = HBoxContainer.new()
	row3.add_child(_label("Quái đã hạ gục", 13, COL_TEXT))
	var spacer3 = Control.new(); spacer3.custom_minimum_size = Vector2(20, 0)
	row3.add_child(spacer3)
	victory_kills_label = _label("0", 13, COL_GOLD)
	row3.add_child(victory_kills_label)
	stats_box.add_child(row3)

	box.add_child(stats)

	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	box.add_child(btn_row)
	var retry_btn = _button_style()
	retry_btn.text = "Chơi lại màn này"
	retry_btn.pressed.connect(func(): game.start_game())
	btn_row.add_child(retry_btn)
	var menu_btn = _button_style()
	menu_btn.text = "Chọn màn khác"
	menu_btn.pressed.connect(func(): game.return_to_menu())
	btn_row.add_child(menu_btn)

func show_victory():
	victory_stage_label.text = game.current_stage.get("name", "") + " — " + game.current_modifier.get("name", "")
	victory_level_label.text = str(game.player.level)
	victory_kills_label.text = str(game.kills)
	victory_panel.visible = true

func return_to_menu():
	hud_root.visible = false
	gameover_panel.visible = false
	victory_panel.visible = false
	pause_panel.visible = false
	start_panel.visible = true

# ---------------- helpers ----------------
func _full_overlay() -> Control:
	var c = Control.new()
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	var bg = Panel.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.add_theme_stylebox_override("panel", _panel_style())
	c.add_child(bg)
	add_child(c)
	return c

func _center_in(box: Control, parent: Control):
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	parent.add_child(box)

func show_toast(text: String):
	var l = _label(text, 13, COL_GOLD)
	var panel = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.059, 0.047, 0.078, 0.95)
	sb.border_color = Color(0.486, 0.227, 0.949, 0.35)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(999)
	sb.content_margin_left = 18; sb.content_margin_right = 18
	sb.content_margin_top = 8; sb.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", sb)
	panel.add_child(l)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel.position.y = 90
	panel.modulate.a = 0.0
	toast_layer.add_child(panel)
	var tw = create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.25)
	tw.tween_interval(1.6)
	tw.tween_property(panel, "modulate:a", 0.0, 0.3)
	tw.tween_callback(panel.queue_free)

func set_playing_visible():
	hud_root.visible = true
	start_panel.visible = false
	gameover_panel.visible = false
	victory_panel.visible = false
	pause_panel.visible = false

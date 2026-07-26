extends Node2D

# ================= constants =================
const DASH_SPEED := 640.0
const DASH_DURATION := 0.16
const DASH_COOLDOWN := 3.2
const MAX_ENEMIES := 220
const JOY_RADIUS := 44.0

var WEAPON_NAMES = {
	"dagger": "Dao Găm", "whip": "Roi Gai", "aura": "Hào Quang Băng",
	"orbit": "Lưỡi Xoáy", "meteor": "Thiên Thạch", "bow": "Cung Ma"
}
var WEAPON_ICONS = {
	"dagger": "🗡️", "whip": "🥀", "aura": "❄️",
	"orbit": "🌀", "meteor": "☄️", "bow": "🏹"
}
var WEAPON_DESC = {
	"dagger": "Bay tới quái gần nhất, có thể xuyên qua nhiều mục tiêu.",
	"whip": "Quét sát thương hình cung về phía quái gần nhất.",
	"aura": "Gây sát thương liên tục cho quái ở gần bạn.",
	"orbit": "Lưỡi kiếm xoay quanh người, chém mọi quái tiếp xúc.",
	"meteor": "Triệu hồi thiên thạch rơi xuống gây sát thương diện rộng.",
	"bow": "Bắn nhiều mũi tên cùng lúc vào các quái khác nhau."
}
var WEAPON_MAX_LEVEL = 5

var PASSIVE_NAMES = {
	"speed": "Đôi Chân Nhanh Nhẹn", "power": "Sức Mạnh Hắc Ám", "haste": "Nhịp Tim Dồn Dập",
	"vitality": "Ý Chí Sinh Tồn", "magnet": "Nam Châm Linh Hồn", "regen": "Máu Bất Tử"
}
var PASSIVE_ICONS = {
	"speed": "🥾", "power": "⚡", "haste": "⏱️", "vitality": "💗", "magnet": "🧲", "regen": "🩸"
}
var PASSIVE_DESC = {
	"speed": "+10% tốc độ di chuyển", "power": "+15% sát thương gây ra",
	"haste": "+10% tốc độ đánh", "vitality": "+20 máu tối đa và hồi đầy",
	"magnet": "+30% phạm vi hút vật phẩm", "regen": "+0.3 hồi máu mỗi giây"
}

var RELIC_NAMES = {
	"boots": "Ủng Thần Tốc", "guardian": "Bùa Hộ Mệnh", "leech": "Nhẫn Hút Máu", "thorns": "Giáp Gai"
}
var RELIC_ICONS = {
	"boots": "👢", "guardian": "🧿", "leech": "💍", "thorns": "🦔"
}
var RELIC_DESC = {
	"boots": "Mở khóa khả năng Lướt né đòn (Shift hoặc nút Lướt).",
	"guardian": "Hồi sinh một lần với 50% máu khi gục ngã.",
	"leech": "Hồi máu nhỏ mỗi khi hạ gục quái.",
	"thorns": "Phản lại sát thương cho quái chạm vào bạn."
}

var ENEMY_DEFS = {
	"zombie": {"hp": 22.0, "speed": 58.0, "damage": 8.0, "radius": 15.0, "xp": 1, "color": Color("#7a8f5c"), "unlock_at": 0.0, "erratic": false},
	"bat": {"hp": 13.0, "speed": 125.0, "damage": 5.0, "radius": 10.0, "xp": 2, "color": Color("#7c5cad"), "unlock_at": 55.0, "erratic": true},
	"brute": {"hp": 95.0, "speed": 34.0, "damage": 18.0, "radius": 23.0, "xp": 5, "color": Color("#8a3d3d"), "unlock_at": 140.0, "erratic": false},
}
var BOSS_DEF = {"hp": 420.0, "speed": 48.0, "damage": 26.0, "radius": 36.0, "xp": 35, "color": Color("#b91c3c"), "erratic": false}

var STAGE_DEFS = [
	{
		"key": "forest", "name": "Bìa Rừng Đêm",
		"desc": "Khởi đầu nhẹ nhàng, quái thưa. Sống sót 6 phút là thắng.",
		"time_limit": 360.0, "first_boss": 90.0, "boss_interval": 120.0,
		"grid_color": Color(1, 1, 1, 0.035),
		"spawn_mult": 1.0, "hp_mult": 1.0, "dmg_mult": 1.0, "speed_mult": 1.0,
	},
	{
		"key": "swamp", "name": "Đầm Lầy Bóng Tối",
		"desc": "Quái đông và dai hơn. Sống sót 10 phút là thắng.",
		"time_limit": 600.0, "first_boss": 120.0, "boss_interval": 130.0,
		"grid_color": Color(0.55, 0.85, 0.55, 0.045),
		"spawn_mult": 1.12, "hp_mult": 1.08, "dmg_mult": 1.0, "speed_mult": 1.0,
	},
	{
		"key": "abyss", "name": "Vực Sâu Vĩnh Hằng",
		"desc": "Thử thách khốc liệt nhất. Sống sót 15 phút là thắng.",
		"time_limit": 900.0, "first_boss": 140.0, "boss_interval": 140.0,
		"grid_color": Color(0.85, 0.35, 0.55, 0.045),
		"spawn_mult": 1.3, "hp_mult": 1.18, "dmg_mult": 1.12, "speed_mult": 1.05,
	},
]

var MODIFIER_DEFS = [
	{
		"key": "none", "name": "Đêm Bình Thường",
		"desc": "Không có biến số đặc biệt nào đêm nay.",
	},
	{
		"key": "frenzy", "name": "Đêm Cuồng Loạn",
		"desc": "Quái di chuyển nhanh hơn hẳn.",
		"speed_mult": 1.3,
	},
	{
		"key": "swarm", "name": "Vạn Quái Tề Tựu",
		"desc": "Quái xuất hiện dày đặc hơn nhưng máu mỏng hơn.",
		"count_mult": 1.6, "hp_mult": 0.8,
	},
	{
		"key": "brutal", "name": "Đêm Bạo Tàn",
		"desc": "Quái xuất hiện dồn dập, máu trâu, đánh đau hơn.",
		"spawn_mult": 1.25, "hp_mult": 1.35, "dmg_mult": 1.25,
	},
	{
		"key": "bloodmoon", "name": "Trăng Máu",
		"desc": "Trùm xuất hiện sớm và dồn dập hơn thường lệ.",
		"boss_interval_mult": 0.65,
	},
]

# ================= state =================
var state := "start"
var current_stage := {}
var current_modifier := {}
var time_limit := 0.0
var selected_stage_idx := 0
var player = null
var enemies: Array = []
var projectiles: Array = []
var gems: Array = []
var particles: Array = []
var pickups: Array = []
var meteors: Array = []
var orb_angle := 0.0
var elapsed := 0.0
var kills := 0
var next_spawn := 0.0
var next_boss_time := 150.0
var boss_active := false
var level_up_queue := 0
var weapon_timers := {}
var shake_mag := 0.0
var next_entity_id := 0

var world_node
var ui_node

# input state
var joy_active := false
var joy_pointer_id := -1
var joy_origin := Vector2.ZERO
var joy_vector := Vector2.ZERO

func _ready():
	randomize()
	world_node = load("res://scripts/world.gd").new()
	world_node.game = self
	add_child(world_node)
	var cam = Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	world_node.add_child(cam)
	world_node.camera = cam

	ui_node = load("res://scripts/hud.gd").new()
	ui_node.game = self
	add_child(ui_node)
	ui_node.build()

func weapon_icon(key: String) -> String: return WEAPON_ICONS.get(key, "?")
func relic_icon(key: String) -> String: return RELIC_ICONS.get(key, "?")

func alloc_id() -> int:
	next_entity_id += 1
	return next_entity_id

# ================= player =================
func new_player() -> Dictionary:
	return {
		"pos": Vector2.ZERO, "radius": 14.0,
		"max_health": 100.0, "health": 100.0, "regen": 0.0,
		"base_speed": 190.0, "move_speed_mult": 1.0,
		"damage_mult": 1.0, "cooldown_mult": 1.0,
		"pickup_radius": 55.0,
		"level": 1, "xp": 0.0, "xp_to_next": 12.0,
		"invuln_until": 0.0,
		"weapons": {}, "relics": {},
		"facing": Vector2(1, 0),
		"dash_cooldown": 0.0, "dash_until": 0.0,
		"guardian_used": false
	}

func keyboard_vector() -> Vector2:
	var v := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): v.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): v.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): v.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): v.y += 1
	return v

func move_vector() -> Vector2:
	var kb = keyboard_vector()
	if kb.length() > 0.01:
		return kb.normalized()
	return joy_vector

func try_dash():
	if player == null or state != "playing": return
	if not player.relics.has("boots"): return
	if player.dash_cooldown > 0: return
	player.dash_until = elapsed + DASH_DURATION
	player.invuln_until = max(player.invuln_until, elapsed + DASH_DURATION + 0.1)
	player.dash_cooldown = DASH_COOLDOWN

func update_player(dt: float):
	var p = player
	if p.dash_cooldown > 0: p.dash_cooldown -= dt
	if elapsed < p.dash_until:
		p.pos += p.facing * DASH_SPEED * dt
	else:
		var mv = move_vector()
		p.pos += mv * p.base_speed * p.move_speed_mult * dt
		if mv.length() > 0.01: p.facing = mv
	if p.regen > 0:
		p.health = min(p.max_health, p.health + p.regen * dt)

# ================= input =================
func _unhandled_input(event):
	if state != "playing":
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			joy_active = true
			joy_pointer_id = event.index
			joy_origin = event.position
			joy_vector = Vector2.ZERO
			ui_node.set_joystick(joy_origin, Vector2.ZERO, true)
		elif event.index == joy_pointer_id:
			_end_joystick()
	elif event is InputEventScreenDrag:
		if event.index == joy_pointer_id:
			_update_joystick(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			joy_active = true
			joy_pointer_id = -99
			joy_origin = event.position
			joy_vector = Vector2.ZERO
			ui_node.set_joystick(joy_origin, Vector2.ZERO, true)
		elif joy_pointer_id == -99:
			_end_joystick()
	elif event is InputEventMouseMotion:
		if joy_active and joy_pointer_id == -99:
			_update_joystick(event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			toggle_pause()
		elif event.keycode == KEY_SHIFT:
			try_dash()

func _update_joystick(pos: Vector2):
	var d = pos - joy_origin
	var len = min(d.length(), JOY_RADIUS)
	var ang = d.angle()
	var offset = Vector2(cos(ang), sin(ang)) * len
	joy_vector = offset / JOY_RADIUS
	ui_node.set_joystick(joy_origin, offset, true)

func _end_joystick():
	joy_active = false
	joy_pointer_id = -1
	joy_vector = Vector2.ZERO
	ui_node.set_joystick(joy_origin, Vector2.ZERO, false)

# ================= spawning =================
func spawn_pos(margin: float) -> Vector2:
	var angle = randf_range(0, TAU)
	var view = get_viewport().get_visible_rect().size
	var r = max(view.x, view.y) / 2.0 + margin
	return player.pos + Vector2(cos(angle), sin(angle)) * r

func available_types() -> Array:
	var t = []
	for k in ENEMY_DEFS.keys():
		if elapsed >= ENEMY_DEFS[k].unlock_at:
			t.append(k)
	return t

func make_enemy(type: String, is_boss: bool) -> Dictionary:
	var def = BOSS_DEF if is_boss else ENEMY_DEFS[type]
	var minutes = elapsed / 60.0
	var stage_hp = current_stage.get("hp_mult", 1.0)
	var stage_dmg = current_stage.get("dmg_mult", 1.0)
	var stage_spd = current_stage.get("speed_mult", 1.0)
	var mod_hp = current_modifier.get("hp_mult", 1.0)
	var mod_dmg = current_modifier.get("dmg_mult", 1.0)
	var mod_spd = current_modifier.get("speed_mult", 1.0)
	var hp_mult = ((1.0 + minutes * 0.35) if is_boss else (1.0 + minutes * 0.22)) * stage_hp * mod_hp
	var dmg_mult = (1.0 + minutes * 0.10) * stage_dmg * mod_dmg
	var spd_mult = stage_spd * mod_spd
	var pos = spawn_pos(60.0)
	return {
		"id": alloc_id(),
		"type": "boss" if is_boss else type,
		"pos": pos,
		"hp": def.hp * hp_mult, "max_hp": def.hp * hp_mult,
		"speed": def.speed * spd_mult, "damage": def.damage * dmg_mult,
		"radius": def.radius, "xp": def.xp,
		"color": def.color, "erratic": def.erratic,
		"is_boss": is_boss,
		"wobble": randf_range(0, TAU),
		"hit_flash": 0.0, "dead": false,
		"orb_hit": {},
		"dash_until": 0.0, "next_dash": (elapsed + randf_range(3, 5)) if is_boss else INF
	}

func update_spawning(dt: float):
	if enemies.size() > MAX_ENEMIES: return
	next_spawn -= dt
	if next_spawn <= 0:
		var minutes = elapsed / 60.0
		var rate_mult = current_stage.get("spawn_mult", 1.0) * current_modifier.get("spawn_mult", 1.0)
		var interval = max(0.32, (1.35 - minutes * 0.16) / rate_mult)
		next_spawn = interval
		var count_mult = current_modifier.get("count_mult", 1.0)
		var count = max(1, int(round((1 + int(minutes / 2.0)) * count_mult)))
		var types = available_types()
		for i in range(count):
			var type = types[randi() % types.size()]
			enemies.append(make_enemy(type, false))
	if not boss_active and elapsed >= next_boss_time:
		boss_active = true
		enemies.append(make_enemy("", true))
		next_boss_time += current_stage.get("boss_interval", 150.0) * current_modifier.get("boss_interval_mult", 1.0)

func update_enemies(dt: float):
	for en in enemies:
		if en.hit_flash > 0: en.hit_flash -= dt
		var to_player = player.pos - en.pos
		var d = to_player.length()
		var dir = to_player.normalized() if d > 0.001 else Vector2.RIGHT
		var spd = en.speed
		if en.is_boss:
			if elapsed >= en.next_dash and d < 400:
				en.dash_until = elapsed + 0.5
				en.next_dash = elapsed + randf_range(3.5, 5.5)
			if elapsed < en.dash_until: spd *= 2.6
		if en.erratic:
			en.wobble += dt * 6
			dir += Vector2(cos(en.wobble), sin(en.wobble)) * 0.5
			dir = dir.normalized()
		en.pos += dir * spd * dt

func nearest_enemy(pos: Vector2):
	var best = null
	var bd = INF
	for en in enemies:
		if en.dead: continue
		var d = pos.distance_to(en.pos)
		if d < bd:
			bd = d
			best = en
	return best

func nearest_enemies(pos: Vector2, n: int) -> Array:
	var list = enemies.filter(func(en): return not en.dead)
	list.sort_custom(func(a, b): return pos.distance_to(a.pos) < pos.distance_to(b.pos))
	return list.slice(0, n)

# ================= damage / death =================
func damage_enemy(en, dmg: float):
	if en.dead: return
	en.hp -= dmg
	en.hit_flash = 0.12
	if en.hp <= 0:
		en.dead = true
		kill_enemy(en)

func spawn_gem(pos: Vector2, value: int):
	gems.append({"pos": pos, "value": value, "radius": 6.0, "collected": false})

func spawn_burst(pos: Vector2, color: Color):
	for i in range(8):
		var a = randf_range(0, TAU)
		var s = randf_range(40, 140)
		particles.append({"type": "spark", "pos": pos, "vel": Vector2(cos(a), sin(a)) * s, "life": 0.4, "max_life": 0.4, "color": color})

func pick_relic_drop():
	var options = []
	for key in RELIC_NAMES.keys():
		if not player.relics.has(key): options.append(key)
	if options.is_empty(): return null
	return options[randi() % options.size()]

func kill_enemy(en):
	kills += 1
	spawn_gem(en.pos, en.xp)
	spawn_burst(en.pos, en.color)
	if player.relics.has("leech"):
		player.health = min(player.max_health, player.health + 3)
	if en.is_boss:
		boss_active = false
		var relic_key = pick_relic_drop()
		if relic_key != null:
			pickups.append({"type": "relic", "relic_key": relic_key, "pos": en.pos, "radius": 12.0, "life": 30.0, "collected": false})
		else:
			pickups.append({"type": "heart", "pos": en.pos, "radius": 10.0, "life": 20.0, "collected": false})
	else:
		var roll = randf()
		if roll < 0.05:
			pickups.append({"type": "heart", "pos": en.pos, "radius": 10.0, "life": 12.0, "collected": false})
		elif roll < 0.065:
			pickups.append({"type": "magnet", "pos": en.pos, "radius": 10.0, "life": 12.0, "collected": false})

# ================= weapons =================
func update_dagger(lv: int, dt: float):
	weapon_timers.dagger = weapon_timers.get("dagger", 0.0) - dt
	if weapon_timers.dagger > 0: return
	var cooldown = max(0.28, 0.85 - lv * 0.09)
	weapon_timers.dagger = cooldown * player.cooldown_mult
	var count = 1 + int(lv / 2)
	var dmg = 8.0 + lv * 4
	var pierce = 1 + int(lv / 3)
	for i in range(count):
		var target = nearest_enemy(player.pos)
		if target == null: break
		var ang = (target.pos - player.pos).angle()
		ang += (i - (count - 1) / 2.0) * 0.18
		projectiles.append({
			"pos": player.pos, "vel": Vector2(cos(ang), sin(ang)) * 420.0,
			"damage": dmg * player.damage_mult, "pierce": pierce, "hit_ids": [],
			"life": 1.4, "radius": 6.0, "color": Color("#e8e0f7"), "type": "dagger"
		})

func update_whip(lv: int, dt: float):
	weapon_timers.whip = weapon_timers.get("whip", 0.0) - dt
	if weapon_timers.whip > 0: return
	var cooldown = max(0.45, 1.05 - lv * 0.09)
	weapon_timers.whip = cooldown * player.cooldown_mult
	var target = nearest_enemy(player.pos)
	var mv = move_vector()
	var base_ang: float
	if target != null: base_ang = (target.pos - player.pos).angle()
	elif mv.length() > 0.01: base_ang = mv.angle()
	else: base_ang = 0.0
	var arc = deg_to_rad(60 + lv * 18)
	var range_ = 95.0 + lv * 14
	var dmg = (10.0 + lv * 5) * player.damage_mult
	for en in enemies:
		if en.dead: continue
		var d = player.pos.distance_to(en.pos)
		if d > range_ + en.radius: continue
		var a = wrapf((en.pos - player.pos).angle() - base_ang, -PI, PI)
		if abs(a) <= arc / 2.0:
			damage_enemy(en, dmg)
	particles.append({"type": "whip", "angle": base_ang, "arc": arc, "range": range_, "life": 0.18, "max_life": 0.18})

func update_orbit(lv: int, dt: float):
	orb_angle += dt * 2.4
	var count = lv
	var dmg = (6.0 + lv * 3) * player.damage_mult
	var radius = 78.0
	for i in range(count):
		var a = orb_angle + i * (TAU / count)
		var opos = player.pos + Vector2(cos(a), sin(a)) * radius
		for en in enemies:
			if en.dead: continue
			var d = opos.distance_to(en.pos)
			if d < en.radius + 10:
				var cd = en.orb_hit.get(i, 0.0)
				if elapsed - cd > 0.35:
					en.orb_hit[i] = elapsed
					damage_enemy(en, dmg)

func update_meteor(lv: int, dt: float):
	weapon_timers.meteor = weapon_timers.get("meteor", 0.0) - dt
	if weapon_timers.meteor > 0: return
	var cooldown = max(1.4, 3.2 - lv * 0.35)
	weapon_timers.meteor = cooldown * player.cooldown_mult
	var target = nearest_enemy(player.pos)
	if target == null: return
	var jitter = 40.0
	meteors.append({
		"pos": target.pos + Vector2(randf_range(-jitter, jitter), randf_range(-jitter, jitter)),
		"radius": 55.0 + lv * 8, "damage": (22.0 + lv * 12) * player.damage_mult,
		"timer": 0.7, "exploded": false, "fade": 0.3
	})

func update_meteors(dt: float):
	for m in meteors:
		if not m.exploded:
			m.timer -= dt
			if m.timer <= 0:
				m.exploded = true
				for en in enemies:
					if en.dead: continue
					if m.pos.distance_to(en.pos) < m.radius + en.radius:
						damage_enemy(en, m.damage)
				shake(4)
		else:
			m.fade -= dt
	meteors = meteors.filter(func(m): return not m.exploded or m.fade > 0)

func update_bow(lv: int, dt: float):
	weapon_timers.bow = weapon_timers.get("bow", 0.0) - dt
	if weapon_timers.bow > 0: return
	var cooldown = max(0.6, 1.3 - lv * 0.1)
	weapon_timers.bow = cooldown * player.cooldown_mult
	var count = 2 + int(lv / 2)
	var dmg = (9.0 + lv * 4) * player.damage_mult
	var targets = nearest_enemies(player.pos, count)
	for t in targets:
		var ang = (t.pos - player.pos).angle()
		projectiles.append({
			"pos": player.pos, "vel": Vector2(cos(ang), sin(ang)) * 480.0,
			"damage": dmg, "pierce": 1, "hit_ids": [],
			"life": 1.2, "radius": 5.0, "color": Color("#e8b84b"), "type": "bow"
		})

func apply_aura(lv: int, dt: float):
	var r = 55.0 + lv * 16
	var dps = (4.0 + lv * 3) * player.damage_mult
	for en in enemies:
		if en.dead: continue
		var d = player.pos.distance_to(en.pos)
		if d < r + en.radius:
			damage_enemy(en, dps * dt)

func update_weapons(dt: float):
	for key in player.weapons.keys():
		var lv = player.weapons[key]
		match key:
			"dagger": update_dagger(lv, dt)
			"whip": update_whip(lv, dt)
			"orbit": update_orbit(lv, dt)
			"meteor": update_meteor(lv, dt)
			"bow": update_bow(lv, dt)
	if player.weapons.has("aura"):
		apply_aura(player.weapons.aura, dt)

func update_projectiles(dt: float):
	for pr in projectiles:
		pr.pos += pr.vel * dt
		pr.life -= dt
		for en in enemies:
			if en.dead or pr.hit_ids.has(en.id): continue
			var d = pr.pos.distance_to(en.pos)
			if d < pr.radius + en.radius:
				damage_enemy(en, pr.damage)
				pr.hit_ids.append(en.id)
				pr.pierce -= 1
				if pr.pierce <= 0:
					pr.life = 0
					break
	projectiles = projectiles.filter(func(pr): return pr.life > 0)

# ================= collisions =================
func shake(m: float):
	shake_mag = max(shake_mag, m)

func update_collisions():
	var p = player
	for en in enemies:
		if en.dead: continue
		var d = p.pos.distance_to(en.pos)
		if d < p.radius + en.radius:
			if elapsed > p.invuln_until:
				p.health -= en.damage
				p.invuln_until = elapsed + 0.6
				shake(6)
				if p.relics.has("thorns"):
					damage_enemy(en, en.damage * 0.5)
				if p.health <= 0:
					if p.relics.has("guardian") and not p.guardian_used:
						p.guardian_used = true
						p.health = p.max_health * 0.5
						p.invuln_until = elapsed + 1.2
						shake(10)
						ui_node.show_toast("Bùa Hộ Mệnh đã cứu bạn!")
					else:
						p.health = 0
						end_game()

func update_gems(dt: float):
	var p = player
	for g in gems:
		var d = p.pos.distance_to(g.pos)
		if d < p.pickup_radius:
			var dir = (p.pos - g.pos).normalized()
			g.pos += dir * 380.0 * dt
		if d < p.radius + 6:
			g.collected = true
			gain_xp(g.value)
	gems = gems.filter(func(g): return not g.collected)

func update_pickups(dt: float):
	var p = player
	for pk in pickups:
		pk.life -= dt
		var d = p.pos.distance_to(pk.pos)
		if d < p.radius + pk.radius:
			pk.collected = true
			if pk.type == "heart":
				p.health = min(p.max_health, p.health + 25)
			elif pk.type == "magnet":
				for g in gems: g.pos = p.pos
			elif pk.type == "relic":
				p.relics[pk.relic_key] = true
				ui_node.show_toast("Nhận trang bị: " + RELIC_NAMES[pk.relic_key])
				ui_node.update_loadout()
	pickups = pickups.filter(func(pk): return not pk.collected and pk.life > 0)

func update_particles(dt: float):
	for pt in particles:
		pt.life -= dt
		if pt.type == "spark":
			pt.pos += pt.vel * dt
			pt.vel *= 0.9
	particles = particles.filter(func(pt): return pt.life > 0)

# ================= leveling =================
func gain_xp(v: int):
	player.xp += v
	while player.xp >= player.xp_to_next:
		player.xp -= player.xp_to_next
		player.level += 1
		player.xp_to_next = 12 + (player.level - 1) * 8
		level_up_queue += 1

func roll_upgrades() -> Array:
	var owned = player.weapons.size()
	var pool = []
	for key in WEAPON_NAMES.keys():
		var lv = player.weapons.get(key, 0)
		if lv > 0 and lv < WEAPON_MAX_LEVEL:
			pool.append({"kind": "weapon", "key": key, "level": lv + 1})
		elif lv == 0 and owned < 6:
			pool.append({"kind": "weapon", "key": key, "level": 1})
	for key in PASSIVE_NAMES.keys():
		pool.append({"kind": "passive", "key": key})
	var picks = []
	var used = {}
	var guard = 0
	while picks.size() < 3 and used.size() < pool.size() and guard < 50:
		guard += 1
		var item = pool[randi() % pool.size()]
		var uid = item.kind + item.key
		if used.has(uid): continue
		used[uid] = true
		picks.append(item)
	return picks

func show_levelup():
	state = "levelup"
	var picks = roll_upgrades()
	var display_items = []
	for item in picks:
		if item.kind == "weapon":
			display_items.append({
				"kind": "weapon", "key": item.key, "level": item.level,
				"icon": WEAPON_ICONS[item.key], "name": WEAPON_NAMES[item.key], "desc": WEAPON_DESC[item.key],
				"level_label": ("Vũ khí mới" if item.level == 1 else ("Cấp " + str(item.level)))
			})
		else:
			display_items.append({
				"kind": "passive", "key": item.key, "level": 0,
				"icon": PASSIVE_ICONS[item.key], "name": PASSIVE_NAMES[item.key], "desc": PASSIVE_DESC[item.key],
				"level_label": "Chỉ số"
			})
	ui_node.show_levelup(display_items)

func apply_upgrade_choice(item: Dictionary):
	if item.kind == "weapon":
		player.weapons[item.key] = item.level
	else:
		match item.key:
			"speed": player.move_speed_mult += 0.10
			"power": player.damage_mult += 0.15
			"haste": player.cooldown_mult *= 0.90
			"vitality": player.max_health += 20; player.health = player.max_health
			"magnet": player.pickup_radius *= 1.30
			"regen": player.regen += 0.3
	ui_node.update_loadout()
	close_levelup()

func close_levelup():
	ui_node.hide_levelup()
	level_up_queue -= 1
	if level_up_queue > 0:
		show_levelup()
	else:
		state = "playing"

# ================= main loop =================
func _process(dt: float):
	if state == "playing":
		_update(dt)
	shake_mag *= 0.85
	if shake_mag < 0.05: shake_mag = 0.0
	var cam = world_node.camera
	if cam and player != null:
		cam.global_position = player.pos + (Vector2(randf_range(-shake_mag, shake_mag), randf_range(-shake_mag, shake_mag)) if shake_mag > 0 else Vector2.ZERO)
	if player != null:
		ui_node.update_hud()

func _update(dt: float):
	elapsed += dt
	if elapsed >= time_limit:
		win_game()
		return
	update_spawning(dt)
	update_player(dt)
	update_enemies(dt)
	update_weapons(dt)
	update_projectiles(dt)
	update_meteors(dt)
	update_collisions()
	update_gems(dt)
	update_pickups(dt)
	update_particles(dt)
	enemies = enemies.filter(func(en): return not en.dead)
	if level_up_queue > 0 and state == "playing":
		show_levelup()

# ================= game state transitions =================
func start_game(stage_idx: int = -1):
	if stage_idx >= 0:
		selected_stage_idx = stage_idx
	current_stage = STAGE_DEFS[selected_stage_idx]
	current_modifier = MODIFIER_DEFS[randi() % MODIFIER_DEFS.size()]
	time_limit = current_stage.time_limit
	player = new_player()
	player.weapons = {"dagger": 1}
	enemies = []; projectiles = []; gems = []; particles = []; pickups = []; meteors = []
	elapsed = 0.0; kills = 0; next_spawn = 0.6; boss_active = false
	next_boss_time = current_stage.first_boss
	level_up_queue = 0; weapon_timers = {}; orb_angle = 0.0
	state = "playing"
	ui_node.set_playing_visible()
	ui_node.update_loadout()
	ui_node.show_toast(current_modifier.name + " — " + current_modifier.desc)

func end_game():
	state = "gameover"
	ui_node.show_gameover()

func win_game():
	state = "victory"
	ui_node.show_victory()

func return_to_menu():
	state = "start"
	ui_node.return_to_menu()

func toggle_pause():
	if state == "playing":
		state = "paused"
		ui_node.pause_panel.visible = true
	elif state == "paused":
		state = "playing"
		ui_node.pause_panel.visible = false

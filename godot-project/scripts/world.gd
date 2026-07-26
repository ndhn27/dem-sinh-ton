extends Node2D

# Reference back to the main game controller (set right after instancing).
var game = null
var camera: Camera2D

# ---------------- sprite textures ----------------
const TEX_PLAYER = preload("res://assets/sprites/player.png")
const TEX_ENEMY_ZOMBIE = preload("res://assets/sprites/enemy_zombie.png")
const TEX_ENEMY_BAT = preload("res://assets/sprites/enemy_bat.png")
const TEX_ENEMY_BRUTE = preload("res://assets/sprites/enemy_brute.png")
const TEX_ENEMY_BOSS = preload("res://assets/sprites/enemy_boss.png")
const TEX_FX_DAGGER = preload("res://assets/sprites/fx_dagger.png")
const TEX_FX_WHIP = preload("res://assets/sprites/fx_whip.png")
const TEX_FX_AURA = preload("res://assets/sprites/fx_aura.png")
const TEX_FX_ORBIT = preload("res://assets/sprites/fx_orbit.png")
const TEX_FX_METEOR = preload("res://assets/sprites/fx_meteor.png")
const TEX_FX_ARROW = preload("res://assets/sprites/fx_arrow.png")
const TEX_PICKUP_GEM = preload("res://assets/sprites/pickup_gem.png")
const TEX_PICKUP_HEART = preload("res://assets/sprites/pickup_heart.png")
const TEX_PICKUP_MAGNET = preload("res://assets/sprites/pickup_magnet.png")
const TEX_RELIC_BOOTS = preload("res://assets/sprites/relic_boots.png")
const TEX_RELIC_GUARDIAN = preload("res://assets/sprites/relic_guardian.png")
const TEX_RELIC_LEECH = preload("res://assets/sprites/relic_leech.png")
const TEX_RELIC_THORNS = preload("res://assets/sprites/relic_thorns.png")
const TEX_BG_FOREST = preload("res://assets/sprites/bg_forest.png")
const TEX_BG_SWAMP = preload("res://assets/sprites/bg_swamp.png")
const TEX_BG_ABYSS = preload("res://assets/sprites/bg_abyss.png")

var RELIC_TEX = {
	"boots": TEX_RELIC_BOOTS, "guardian": TEX_RELIC_GUARDIAN,
	"leech": TEX_RELIC_LEECH, "thorns": TEX_RELIC_THORNS,
}
var STAGE_BG_TEX = {
	"forest": TEX_BG_FOREST, "swamp": TEX_BG_SWAMP, "abyss": TEX_BG_ABYSS,
}

# Each generated image has padding around the actual subject. This records,
# per sprite, where the subject sits within its canvas (as fractions of the
# canvas size) so _draw_sprite can size/center by the subject, not the
# padded canvas.
const SPRITE_META = {
	"player": {"cx": 0.5637, "cy": 0.5076, "sw": 0.7603, "sh": 0.7446},
	"enemy_zombie": {"cx": 0.5698, "cy": 0.5083, "sw": 0.7559, "sh": 0.7393},
	"enemy_bat": {"cx": 0.5037, "cy": 0.5039, "sw": 0.7866, "sh": 0.7005},
	"enemy_brute": {"cx": 0.5046, "cy": 0.5176, "sw": 0.4581, "sh": 0.7760},
	"enemy_boss": {"cx": 0.4833, "cy": 0.5000, "sw": 0.7102, "sh": 0.8516},
	"fx_dagger": {"cx": 0.5938, "cy": 0.5093, "sw": 0.7285, "sh": 0.6631},
	"fx_whip": {"cx": 0.5000, "cy": 0.4956, "sw": 0.8086, "sh": 0.8086},
	"fx_aura": {"cx": 0.5002, "cy": 0.5015, "sw": 0.7856, "sh": 0.7881},
	"fx_orbit": {"cx": 0.5032, "cy": 0.5603, "sw": 0.6733, "sh": 0.7817},
	"fx_meteor": {"cx": 0.5251, "cy": 0.4868, "sw": 0.6880, "sh": 0.7275},
	"fx_arrow": {"cx": 0.5005, "cy": 0.5029, "sw": 0.7676, "sh": 0.7705},
	"pickup_gem": {"cx": 0.4966, "cy": 0.5023, "sw": 0.3668, "sh": 0.6934},
	"pickup_heart": {"cx": 0.4957, "cy": 0.4990, "sw": 0.4240, "sh": 0.7116},
	"pickup_magnet": {"cx": 0.4951, "cy": 0.4861, "sw": 0.7393, "sh": 0.7847},
	"relic_boots": {"cx": 0.5034, "cy": 0.5215, "sw": 0.4748, "sh": 0.6315},
	"relic_guardian": {"cx": 0.4995, "cy": 0.4612, "sw": 0.7529, "sh": 0.8442},
	"relic_leech": {"cx": 0.5487, "cy": 0.5078, "sw": 0.4929, "sh": 0.6745},
	"relic_thorns": {"cx": 0.5009, "cy": 0.4876, "sw": 0.4031, "sh": 0.7865},
}

func _process(_delta):
	queue_redraw()

func _draw():
	if game == null or game.player == null:
		return
	_draw_ground()
	for m in game.meteors:
		_draw_meteor(m)
	for g in game.gems:
		_draw_gem(g)
	for pk in game.pickups:
		_draw_pickup(pk)
	for en in game.enemies:
		_draw_enemy(en)
	_draw_aura()
	_draw_player()
	for pr in game.projectiles:
		_draw_projectile(pr)
	_draw_orbit()
	for pt in game.particles:
		_draw_particle(pt)

# ---------------- shared shading helpers ----------------
func _draw_shadow(pos: Vector2, radius: float):
	draw_set_transform(pos + Vector2(0, radius * 0.65), 0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, radius * 0.95, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _draw_glow(pos: Vector2, radius: float, color: Color):
	var c = color
	c.a = 0.22
	draw_circle(pos, radius * 1.9, c)

# Draws a texture so that the *subject* (not the padded canvas around it)
# is centered at `pos` and spans `diameter` pixels on screen.
func _draw_sprite(tex: Texture2D, meta_key: String, pos: Vector2, diameter: float,
		rot: float = 0.0, flip_x: bool = false, tint: Color = Color(1, 1, 1, 1)):
	var m = SPRITE_META[meta_key]
	var tex_size = tex.get_size()
	var subj_w = m.sw * tex_size.x
	var subj_h = m.sh * tex_size.y
	var s = diameter / max(subj_w, subj_h)
	var center_px = Vector2(m.cx * tex_size.x, m.cy * tex_size.y)
	var sx = -s if flip_x else s
	draw_set_transform(pos, rot, Vector2(sx, s))
	draw_texture_rect(tex, Rect2(-center_px, tex_size), false, tint)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

# ---------------- ground ----------------
func _draw_ground():
	var p = game.player
	var tex = STAGE_BG_TEX.get(game.current_stage.get("key", ""), null)
	var half_w = get_viewport_rect().size.x * 0.7
	var half_h = get_viewport_rect().size.y * 0.7
	if tex == null:
		var col = game.current_stage.get("grid_color", Color(1, 1, 1, 0.035))
		draw_rect(Rect2(p.pos - Vector2(half_w, half_h), Vector2(half_w, half_h) * 2.0), Color(0.03, 0.03, 0.05, 1.0))
		return
	var tile = 480.0
	var start_x = floor((p.pos.x - half_w) / tile) * tile
	var start_y = floor((p.pos.y - half_h) / tile) * tile
	var y = start_y
	while y < p.pos.y + half_h:
		var x = start_x
		while x < p.pos.x + half_w:
			draw_texture_rect(tex, Rect2(Vector2(x, y), Vector2(tile, tile)), false, Color(1, 1, 1, 0.6))
			x += tile
		y += tile
	# faint vignette-ish grid on top keeps a sense of scale/movement
	var grid_col = game.current_stage.get("grid_color", Color(1, 1, 1, 0.035))
	var gx = floor((p.pos.x - half_w) / 60.0) * 60.0
	while gx < p.pos.x + half_w:
		draw_line(Vector2(gx, p.pos.y - half_h), Vector2(gx, p.pos.y + half_h), grid_col, 1.0)
		gx += 60.0
	var gy = floor((p.pos.y - half_h) / 60.0) * 60.0
	while gy < p.pos.y + half_h:
		draw_line(Vector2(p.pos.x - half_w, gy), Vector2(p.pos.x + half_w, gy), grid_col, 1.0)
		gy += 60.0

# ---------------- player ----------------
func _draw_player():
	var p = game.player
	var flashing = game.elapsed < p.invuln_until and int(game.elapsed * 20) % 2 == 0
	_draw_shadow(p.pos, p.radius)
	_draw_glow(p.pos, p.radius, Color("#8b5cf6"))
	var tint = Color(2.6, 2.6, 2.6, 1.0) if flashing else Color(1, 1, 1, 1)
	var flip = p.facing.x < -0.01
	_draw_sprite(TEX_PLAYER, "player", p.pos, p.radius * 4.4, 0.0, flip, tint)

# ---------------- enemies ----------------
func _draw_enemy(en):
	var flash = en.hit_flash > 0
	var tint = Color(2.6, 2.6, 2.6, 1.0) if flash else Color(1, 1, 1, 1)
	match en.type:
		"bat":
			_draw_shadow(en.pos, en.radius * 0.8)
			_draw_sprite(TEX_ENEMY_BAT, "enemy_bat", en.pos, en.radius * 3.6, 0.0, false, tint)
		"brute":
			_draw_shadow(en.pos, en.radius)
			_draw_sprite(TEX_ENEMY_BRUTE, "enemy_brute", en.pos, en.radius * 3.0, 0.0, false, tint)
		"boss":
			_draw_shadow(en.pos, en.radius)
			_draw_glow(en.pos, en.radius, Color("#b91c3c"))
			_draw_sprite(TEX_ENEMY_BOSS, "enemy_boss", en.pos, en.radius * 3.0, 0.0, false, tint)
		_:
			_draw_shadow(en.pos, en.radius)
			_draw_sprite(TEX_ENEMY_ZOMBIE, "enemy_zombie", en.pos, en.radius * 3.2, 0.0, false, tint)
	if en.is_boss:
		var bar_w = 64.0
		var bar_pos = en.pos + Vector2(-bar_w / 2.0, -en.radius - 20)
		draw_rect(Rect2(bar_pos - Vector2(2, 2), Vector2(bar_w + 4, 10)), Color(0, 0, 0, 0.55))
		draw_rect(Rect2(bar_pos, Vector2(bar_w, 6)), Color(0.15, 0.05, 0.08, 1.0))
		draw_rect(Rect2(bar_pos, Vector2(bar_w * clamp(en.hp / en.max_hp, 0.0, 1.0), 6)), Color("#b91c3c"))

# ---------------- pickups / gems / projectiles ----------------
func _draw_gem(g):
	_draw_glow(g.pos, 10.0, Color("#8b5cf6"))
	_draw_sprite(TEX_PICKUP_GEM, "pickup_gem", g.pos, 22.0)

func _draw_pickup(pk):
	match pk.type:
		"heart":
			_draw_glow(pk.pos, 12.0, Color("#d0344c"))
			_draw_sprite(TEX_PICKUP_HEART, "pickup_heart", pk.pos, 32.0)
		"magnet":
			_draw_glow(pk.pos, 12.0, Color("#8b5cf6"))
			_draw_sprite(TEX_PICKUP_MAGNET, "pickup_magnet", pk.pos, 32.0)
		"relic":
			_draw_glow(pk.pos, 14.0, Color("#e8b84b"))
			var tex = RELIC_TEX.get(pk.relic_key, TEX_RELIC_GUARDIAN)
			_draw_sprite(tex, "relic_" + pk.relic_key, pk.pos, 40.0)

func _draw_projectile(pr):
	var col = pr.color if pr.has("color") else Color("#e8e0f7")
	_draw_glow(pr.pos, pr.radius, col)
	var ang = pr.vel.angle() if pr.has("vel") else 0.0
	if pr.get("type", "dagger") == "bow":
		_draw_sprite(TEX_FX_ARROW, "fx_arrow", pr.pos, pr.radius * 4.6, ang + PI / 4.0)
	else:
		_draw_sprite(TEX_FX_DAGGER, "fx_dagger", pr.pos, pr.radius * 4.2, ang + PI / 4.0)

func _draw_orbit():
	var p = game.player
	if not p.weapons.has("orbit"):
		return
	var lv = p.weapons["orbit"]
	var count = lv
	var radius = 78.0
	for i in range(count):
		var a = game.orb_angle + i * (TAU / count)
		var pos = p.pos + Vector2(cos(a), sin(a)) * radius
		_draw_glow(pos, 8.0, Color("#d0344c"))
		_draw_sprite(TEX_FX_ORBIT, "fx_orbit", pos, 30.0, a + PI / 2.0)

func _draw_aura():
	var p = game.player
	if not p.weapons.has("aura"):
		return
	var lv = p.weapons["aura"]
	var r = 55.0 + lv * 16.0
	var pulse = 0.94 + sin(game.elapsed * 3.0) * 0.06
	_draw_sprite(TEX_FX_AURA, "fx_aura", p.pos, r * 2.0 * pulse, game.elapsed * 0.5, false, Color(1, 1, 1, 0.7))

func _draw_particle(pt):
	if pt.type == "spark":
		var a = clamp(pt.life / pt.max_life, 0.0, 1.0)
		var col = pt.color
		col.a = a
		draw_circle(pt.pos, 3.0, col)
	elif pt.type == "whip":
		var a = clamp(pt.life / pt.max_life, 0.0, 1.0)
		var tint = Color(1, 1, 1, a * 0.9)
		_draw_sprite(TEX_FX_WHIP, "fx_whip", game.player.pos, pt.range * 1.5, pt.angle, false, tint)

func _draw_meteor(m):
	if not m.exploded:
		var pct = 1.0 - (m.timer / 0.7)
		var ring_r = m.radius * min(1.0, 0.4 + pct * 0.6)
		draw_arc(m.pos, ring_r, 0, TAU, 24, Color(0.82, 0.2, 0.3, 0.55), 1.5)
		var tint = Color(1, 1, 1, 0.6 + pct * 0.4)
		_draw_sprite(TEX_FX_METEOR, "fx_meteor", m.pos, ring_r * 1.7, game.elapsed * 4.0, false, tint)
	else:
		var a = clamp(m.fade / 0.3, 0.0, 1.0)
		draw_circle(m.pos, m.radius, Color(0.91, 0.72, 0.29, 0.5 * a))

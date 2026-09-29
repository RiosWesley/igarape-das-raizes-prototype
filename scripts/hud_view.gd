extends Control

var hud: CanvasLayer
var font: Font
var font_bold: Font
var atlas: Texture2D
var teodoro_art: Texture2D

const INK := Color("#071011")
const PANEL := Color(0.028, 0.038, 0.039, 0.97)
const PANEL_INNER := Color(0.055, 0.073, 0.071, 0.96)
const BRONZE := Color("#704523")
const GOLD := Color("#d99a32")
const GOLD_LIGHT := Color("#ffe3a0")
const PAPER := Color("#f2eee0")
const MUTED := Color("#b6ad95")
const TEAL := Color("#42c2ad")
const BLUE := Color("#4cb9ec")
const RED := Color("#d64a4a")

func _ready() -> void:
	font = load("res://assets/fonts/Georgia.ttf") as Font
	font_bold = load("res://assets/fonts/Georgia-Bold.ttf") as Font
	if font == null:
		font = ThemeDB.fallback_font
	if font_bold == null:
		font_bold = font
	atlas = load("res://assets/characters/eric/spritesheet.webp")
	teodoro_art = load("res://assets/characters/teodoro/teodoro.webp") as Texture2D
	set_process(true)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if hud == null or hud.game == null:
		return
	var screen := get_viewport_rect().size
	# The HUD is intentionally composed from live Godot draw calls.  Every
	# panel, label, bar and icon below reacts to the current game state; the
	# reference image is never used as a runtime texture.
	_draw_player_panel()
	_draw_companion_panel(screen)
	_draw_objective_panel()
	if not hud.game.dialogue_active:
		_draw_quick_items(screen)
		# The command panel belongs to a future combat state. It must not be
		# permanently visible during this exploration/dialogue prototype.
		if hud.game.action_menu_open:
			_draw_command_menu(screen)
			_draw_context_card(screen)
	_draw_interaction_prompt()
	if hud.game.dialogue_active:
		_draw_dialogue_box(screen)

func _draw_stage_label(screen: Vector2) -> void:
	var rect := Rect2(screen.x * 0.5 - 140.0, 14.0, 280.0, 52.0)
	_draw_panel(rect, GOLD, true)
	draw_string(font, rect.position + Vector2(0, 22), "FASE 1  -  MATA ALAGADA", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 14, GOLD_LIGHT)
	draw_line(rect.position + Vector2(15, 38), rect.position + Vector2(rect.size.x - 15, 38), GOLD, 2.0)
	draw_string(font, rect.position + Vector2(0, 49), "IGARAPE DAS RAIZES", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 11, Color("#a4cdb7"))

func _draw_player_panel() -> void:
	var rect := Rect2(18.0, 14.0, 372.0, 102.0)
	_draw_panel(rect, GOLD, true)
	var portrait := Rect2(rect.position + Vector2(8, 8), Vector2(78, 86))
	draw_rect(portrait, Color("#152421"), true)
	draw_rect(portrait, Color("#9c6b2d"), false, 2.0)
	draw_rect(portrait.grow(-4), GOLD_LIGHT, false, 1.0)
	if atlas:
		# Use the upper body of the live character sheet as a portrait so the
		# panel reads like the close-up portrait in the reference HUD.
		draw_texture_rect_region(atlas, Rect2(portrait.position + Vector2(1, 1), Vector2(76, 84)), Rect2(28, 0, 136, 150))
	draw_string(font_bold, rect.position + Vector2(98, 29), "Eric", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#fff7df"))
	draw_string(font, rect.position + Vector2(98, 50), "Nv. 12", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, GOLD_LIGHT)
	_draw_bar(Rect2(rect.position + Vector2(167, 40), Vector2(187, 15)), RED, 1.0, "284 / 284")
	_draw_bar(Rect2(rect.position + Vector2(167, 70), Vector2(187, 14)), BLUE, 1.0, "120 / 120")
	_draw_ability_badge(Rect2(rect.position + Vector2(98, 72), Vector2(25, 23)), "shield", TEAL)
	_draw_ability_badge(Rect2(rect.position + Vector2(128, 72), Vector2(25, 23)), "leaf", Color("#9cdd62"))
	_draw_ability_badge(Rect2(rect.position + Vector2(158, 72), Vector2(25, 23)), "rune", Color("#d981ed"))

func _draw_companion_panel(screen: Vector2) -> void:
	var rect := Rect2(screen.x - 322.0, 14.0, 304.0, 84.0)
	_draw_panel(rect, Color("#e1a14a"), true)
	draw_string(font_bold, rect.position + Vector2(12, 24), "Boto Cor-de-Rosa", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#fff4d4"))
	draw_string(font, rect.position + Vector2(12, 43), "Espirito Encantado do Rio", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#d7c6a2"))
	draw_rect(Rect2(rect.position + Vector2(12, 61), Vector2(216, 13)), Color("#132824"), true)
	draw_rect(Rect2(rect.position + Vector2(12, 61), Vector2(216, 13)), RED, true)
	draw_rect(Rect2(rect.position + Vector2(12, 61), Vector2(216, 13)), Color("#f2d6a4"), false, 1.0)
	draw_string(font, rect.position + Vector2(12, 71), "612 / 612", HORIZONTAL_ALIGNMENT_CENTER, 216, 10, Color("#fff3d8"))
	_draw_teodoro_badge(rect.position + Vector2(270, 42))

func _draw_objective_panel() -> void:
	var rect := Rect2(18.0, 136.0, 254.0, 160.0)
	_draw_panel(rect, GOLD, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(38, 161), Vector2(50, 149), Vector2(62, 161), Vector2(50, 173)
	]), GOLD)
	draw_colored_polygon(PackedVector2Array([
		Vector2(44, 161), Vector2(50, 155), Vector2(56, 161), Vector2(50, 167)
	]), Color("#1a211d"))
	draw_string(font_bold, Vector2(69, 168), "Objetivo", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, GOLD_LIGHT)
	draw_line(Vector2(30, 181), Vector2(260, 181), BRONZE, 1.0)
	draw_string(font, Vector2(31, 201), "Siga as pistas para", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER)
	draw_string(font, Vector2(31, 217), "resgatar sua amada.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER)
	_draw_check(Vector2(40, 240), hud.game.objective_step >= 1, "Encontre o velho ribeirinho")
	_draw_check(Vector2(40, 261), hud.game.objective_step >= 2, "Descubra o paradeiro dela")
	_draw_check(Vector2(40, 282), hud.game.objective_step >= 3, "Va ate o Encontro das Aguas")

func _draw_check(pos: Vector2, checked: bool, label: String) -> void:
	var box := Rect2(pos - Vector2(8, 8), Vector2(16, 16))
	draw_rect(box, INK, true)
	draw_rect(box, TEAL if checked else Color("#d9d1b8"), false, 1.5)
	if checked:
		draw_line(pos + Vector2(-5, -1), pos + Vector2(-1, 3), TEAL, 1.5)
		draw_line(pos + Vector2(-1, 3), pos + Vector2(5, -4), TEAL, 1.5)
	draw_string(font, pos + Vector2(23, 4), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, PAPER)

func _draw_quick_items(screen: Vector2) -> void:
	var rect := Rect2(screen.x * 0.5 - 360.0, screen.y - 112.0, 320.0, 92.0)
	_draw_panel(rect, GOLD, true)
	draw_string(font_bold, rect.position + Vector2(12, -6), "Itens Rapidos", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GOLD_LIGHT)
	var colors := [RED, Color("#429bd0"), Color("#74bd4c"), Color("#bd8a54")]
	for i in range(4):
		var slot := Rect2(rect.position + Vector2(8 + i * 76, 12), Vector2(68, 60))
		draw_rect(slot, PANEL_INNER, true)
		draw_rect(slot, Color("#80603e"), false, 1.5)
		draw_rect(Rect2(slot.position + Vector2(5, 5), Vector2(18, 18)), INK, true)
		draw_string(font, slot.position + Vector2(10, 18), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, PAPER)
		_draw_item_icon(slot.position + Vector2(36, 31), i, colors[i])
		draw_string(font, slot.position + Vector2(51, 39), str([5, 3, 1, 2][i]), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, PAPER)

func _draw_item_icon(center: Vector2, index: int, color: Color) -> void:
	if index == 0:
		draw_circle(center + Vector2(0, 5), 10.0, color)
		draw_rect(Rect2(center + Vector2(-5, -9), Vector2(10, 6)), Color("#e8c17b"), true)
		draw_rect(Rect2(center + Vector2(-3, -13), Vector2(6, 4)), Color("#9b6637"), true)
	elif index == 1:
		draw_colored_polygon(PackedVector2Array([
		center + Vector2(-7, -10), center + Vector2(7, -10), center + Vector2(10, 9), center + Vector2(-10, 9)
	]), color)
		draw_line(center + Vector2(-4, -13), center + Vector2(4, -13), GOLD_LIGHT, 3.0)
	elif index == 2:
		draw_colored_polygon(PackedVector2Array([
		center + Vector2(0, -13), center + Vector2(9, -1), center + Vector2(2, 12), center + Vector2(-10, 7), center + Vector2(-8, -6)
	]), color)
		draw_line(center + Vector2(0, 10), center + Vector2(0, 16), Color("#5a8d3b"), 2.0)
	else:
		draw_circle(center, 11.0, color)
		draw_line(center + Vector2(-7, -8), center + Vector2(7, -8), GOLD_LIGHT, 2.0)

func _draw_command_menu(screen: Vector2) -> void:
	var rect := Rect2(screen.x - 664.0, screen.y - 203.0, 208.0, 150.0)
	_draw_panel(rect, GOLD, true)
	var labels := ["Atacar", "Habilidade", "Itens", "Defender"]
	for i in range(labels.size()):
		var row := Rect2(rect.position + Vector2(10, 8 + i * 28), Vector2(rect.size.x - 20, 25))
		if i == 0:
			draw_rect(row, Color("#102d3b"), true)
			draw_rect(row, BLUE, false, 2.0)
		_draw_action_icon(row.position + Vector2(16, 12), i, BLUE if i == 0 else GOLD_LIGHT)
		draw_string(font_bold, row.position + Vector2(31, 17), labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f5f0df"))

func _draw_context_card(screen: Vector2) -> void:
	var rect := Rect2(screen.x - 458.0, screen.y - 203.0, 214.0, 150.0)
	_draw_panel(rect, GOLD, true)
	draw_string(font, rect.position + Vector2(14, 68), "Ataque normal.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER)
	draw_string(font, rect.position + Vector2(14, 87), "Causa dano fisico", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER)
	draw_string(font, rect.position + Vector2(14, 106), "ao inimigo.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER)
	draw_line(rect.position + Vector2(15, 135), rect.position + Vector2(44, 135), GOLD, 2.0)
	draw_line(rect.position + Vector2(52, 135), rect.position + Vector2(68, 135), TEAL, 2.0)

func _draw_action_icon(center: Vector2, index: int, color: Color) -> void:
	if index == 0:
		draw_line(center + Vector2(-7, 7), center + Vector2(7, -7), color, 2.0)
		draw_line(center + Vector2(5, -8), center + Vector2(9, -4), color, 2.0)
		draw_line(center + Vector2(-7, 5), center + Vector2(-3, 9), color, 2.0)
	elif index == 1:
		draw_arc(center, 7.0, -1.1, 2.8, 12, color, 2.0)
		draw_circle(center + Vector2(-4, -4), 2.0, color)
	elif index == 2:
		draw_circle(center + Vector2(0, 2), 6.0, color)
		draw_rect(Rect2(center + Vector2(-3, -8), Vector2(6, 4)), color, true)
	else:
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(0, -9), center + Vector2(8, -5), center + Vector2(6, 7), center + Vector2(0, 10),
			center + Vector2(-6, 7), center + Vector2(-8, -5)
		]), color)

func _draw_controls(screen: Vector2) -> void:
	draw_string(font, Vector2(24, screen.y - 13), "WASD / SETAS  mover   |   E  conversar   |   ESC  fechar", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.92, 0.88, 0.76, 0.84))

func _draw_interaction_prompt() -> void:
	if hud.game.dialogue_active or hud.game.player == null or hud.game.npc == null:
		return
	if not hud.game.player.can_interact(hud.game.npc):
		return
	var canvas_position: Vector2 = get_viewport().get_canvas_transform() * hud.game.npc.global_position
	var rect := Rect2(canvas_position + Vector2(-106, -152), Vector2(212, 34))
	_draw_panel(rect, GOLD, false)
	draw_string(font, rect.position + Vector2(0, 23), "[E]  FALAR COM TEODORO", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, GOLD_LIGHT)

func _draw_dialogue_box(screen: Vector2) -> void:
	var rect := Rect2(58.0, screen.y - 188.0, screen.x - 116.0, 150.0)
	_draw_panel(rect, Color("#d3a95b"), true)
	var portrait := Rect2(rect.position + Vector2(14, 14), Vector2(104, 120))
	draw_rect(portrait, Color("#1b302f"), true)
	draw_rect(portrait, Color("#8bca9d"), false, 2.0)
	if teodoro_art:
		draw_texture_rect(teodoro_art, Rect2(portrait.position + Vector2(5, 4), Vector2(94, 112)), false)
	else:
		_draw_teodoro_portrait(portrait)
	var line: Array = hud.game.dialogue_lines[hud.game.dialogue_index]
	draw_string(font_bold, rect.position + Vector2(138, 37), str(line[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, GOLD_LIGHT)
	draw_line(rect.position + Vector2(138, 48), rect.position + Vector2(rect.size.x - 22, 48), BRONZE, 1.0)
	draw_string(font, rect.position + Vector2(138, 80), str(line[1]), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 170, 16, PAPER)
	draw_string(font, rect.position + Vector2(rect.size.x - 176, rect.size.y - 17), "E avancar   ESC fechar", HORIZONTAL_ALIGNMENT_RIGHT, 160, 11, MUTED)

func _draw_teodoro_portrait(rect: Rect2) -> void:
	var center := rect.position + Vector2(rect.size.x * 0.5, 61)
	draw_circle(center + Vector2(0, 7), 27.0, Color("#b8734b"))
	draw_rect(Rect2(center + Vector2(-28, -29), Vector2(56, 10)), Color("#b98644"), true)
	draw_rect(Rect2(center + Vector2(-20, -42), Vector2(40, 14)), Color("#d0a051"), true)
	draw_rect(Rect2(center + Vector2(-18, 28), Vector2(36, 31)), Color("#2d695b"), true)
	draw_circle(center + Vector2(-9, 4), 3.0, INK)
	draw_circle(center + Vector2(9, 4), 3.0, INK)
	draw_line(center + Vector2(-7, 16), center + Vector2(7, 16), Color("#6c3029"), 2.0)

func _draw_panel(rect: Rect2, accent: Color, ornamented: bool) -> void:
	var shadow := _panel_points(rect.grow(5.0), 8.0)
	draw_colored_polygon(shadow, Color("#120b0a"))
	_draw_panel_outline(shadow, Color("#2a1710"), 2.0)
	var outer := _panel_points(rect, 6.0)
	draw_colored_polygon(outer, Color("#8c5a28"))
	_draw_panel_outline(outer, GOLD_LIGHT, 1.5)
	var inner_rect := rect.grow(-5.0)
	var inner := _panel_points(inner_rect, 4.0)
	draw_colored_polygon(inner, PANEL)
	_draw_panel_outline(inner, Color("#4b321e"), 1.0)
	draw_line(inner_rect.position + Vector2(12, 5), inner_rect.position + Vector2(inner_rect.size.x - 12, 5), Color(1, 0.86, 0.55, 0.20), 1.0)
	if ornamented:
		var p := rect.position
		var q := rect.end
		var corner_color := accent if accent != Color("#8aa8bd") else GOLD
		for corner in [p + Vector2(8, 8), Vector2(q.x - 8, p.y + 8), Vector2(p.x + 8, q.y - 8), q - Vector2(8, 8)]:
			draw_colored_polygon(PackedVector2Array([
				corner + Vector2(0, -4), corner + Vector2(4, 0), corner + Vector2(0, 4), corner + Vector2(-4, 0)
			]), corner_color)

func _panel_points(rect: Rect2, cut: float) -> PackedVector2Array:
	var p := rect.position
	var q := rect.end
	return PackedVector2Array([
		p + Vector2(cut, 0), Vector2(q.x - cut, p.y), Vector2(q.x, p.y + cut),
		Vector2(q.x, q.y - cut), Vector2(q.x - cut, q.y), Vector2(p.x + cut, q.y),
		Vector2(p.x, q.y - cut), Vector2(p.x, p.y + cut)
	])

func _draw_panel_outline(points: PackedVector2Array, color: Color, width: float) -> void:
	for i in range(points.size()):
		draw_line(points[i], points[(i + 1) % points.size()], color, width)

func _draw_bar(rect: Rect2, color: Color, fill: float, label: String) -> void:
	draw_rect(rect, Color("#142023"), true)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * clamp(fill, 0.0, 1.0), rect.size.y)), color, true)
	draw_rect(rect, Color("#ddd1b3"), false, 1.0)
	draw_string(font_bold, rect.position + Vector2(0, rect.size.y - 3), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 11, Color("#fff3d8"))

func _draw_ability_badge(rect: Rect2, symbol: String, color: Color) -> void:
	draw_rect(rect, Color("#10201e"), true)
	draw_rect(rect, color, false, 2.0)
	var center := rect.position + rect.size * 0.5
	if symbol == "shield":
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(0, -8), center + Vector2(7, -5), center + Vector2(6, 4),
			center + Vector2(0, 9), center + Vector2(-6, 4), center + Vector2(-7, -5)
		]), color)
		draw_line(center + Vector2(-3, 0), center + Vector2(-1, 3), INK, 1.0)
		draw_line(center + Vector2(-1, 3), center + Vector2(4, -3), INK, 1.0)
	elif symbol == "leaf":
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(0, -9), center + Vector2(7, -2), center + Vector2(2, 8),
			center + Vector2(-7, 5), center + Vector2(-6, -4)
		]), color)
		draw_line(center + Vector2(-5, 7), center + Vector2(5, -6), Color("#20402c"), 1.0)
	else:
		draw_arc(center, 7.0, -2.7, 2.4, 14, color, 2.0)
		draw_arc(center, 3.0, -2.4, 2.2, 10, color, 1.0)

func _draw_teodoro_badge(center: Vector2) -> void:
	var badge := Rect2(center - Vector2(23, 30), Vector2(46, 60))
	draw_rect(badge, Color("#100b15"), true)
	draw_rect(badge, Color("#7d3a65"), false, 2.0)
	draw_rect(badge.grow(-4), Color("#261329"), false, 1.0)
	var pink := Color("#f35bbb")
	var glow := Color("#ffb8eb")
	draw_polyline(PackedVector2Array([
		center + Vector2(-4, 23), center + Vector2(0, 13), center + Vector2(-2, 5),
		center + Vector2(-10, -3), center + Vector2(-7, -13), center + Vector2(0, -20),
		center + Vector2(8, -15), center + Vector2(5, -7), center + Vector2(12, -3),
		center + Vector2(5, 2), center + Vector2(8, 12), center + Vector2(1, 23)
	]), pink, 2.0)
	draw_line(center + Vector2(-4, 23), center + Vector2(-11, 17), pink, 2.0)
	draw_line(center + Vector2(1, 23), center + Vector2(11, 17), pink, 2.0)
	draw_line(center + Vector2(-7, -13), center + Vector2(-13, -19), pink, 2.0)
	draw_circle(center + Vector2(3, -15), 1.5, glow)
	draw_circle(center + Vector2(-13, -7), 1.5, glow)
	draw_circle(center + Vector2(13, 8), 1.0, glow)

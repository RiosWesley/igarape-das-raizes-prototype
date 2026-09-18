extends Node2D

class_name RiverWorld

const WORLD_SIZE := Vector2(2400.0, 1500.0)
const BACKGROUND: Texture2D = preload("res://assets/backgrounds/river_stage.webp")
const WATER := Color("#0b3c59")
const WATER_DEEP := Color("#082d47")
const GRASS := Color("#173b2c")
const GRASS_LIGHT := Color("#2d5b35")
const WOOD := Color("#714129")
const WOOD_LIGHT := Color("#a56535")

var elapsed := 0.0
var font: Font
var background_sprite: Sprite2D
var background_video: VideoStreamPlayer

var fireflies := [
	Vector2(420, 430), Vector2(575, 610), Vector2(1010, 355), Vector2(1210, 510),
	Vector2(1760, 310), Vector2(1980, 470), Vector2(2140, 825), Vector2(1560, 1070),
	Vector2(870, 1260), Vector2(330, 760), Vector2(1450, 260), Vector2(2240, 1120)
]
var ripples := [
	Vector2(1430, 270), Vector2(1710, 380), Vector2(1960, 230), Vector2(2120, 520),
	Vector2(1540, 540), Vector2(1860, 610), Vector2(2250, 340), Vector2(1320, 430)
]
var trees := [
	[Vector2(150, 260), 1.15], [Vector2(430, 230), 0.92], [Vector2(735, 210), 1.05],
	[Vector2(1040, 180), 0.86], [Vector2(2260, 160), 1.30], [Vector2(2220, 760), 1.08],
	[Vector2(2160, 1210), 1.20], [Vector2(170, 1290), 1.15], [Vector2(560, 1320), 0.90],
	[Vector2(1930, 1320), 0.96], [Vector2(1170, 1310), 0.78]
]

func _ready() -> void:
	z_index = -20
	font = ThemeDB.fallback_font
	_add_generated_background()
	_add_animated_background()
	_build_collisions()
	queue_redraw()

func _add_generated_background() -> void:
	background_sprite = Sprite2D.new()
	background_sprite.name = "GeneratedRiverStage"
	background_sprite.texture = BACKGROUND
	background_sprite.position = WORLD_SIZE * 0.5
	background_sprite.centered = true
	background_sprite.scale = Vector2(
		WORLD_SIZE.x / float(BACKGROUND.get_width()),
		WORLD_SIZE.y / float(BACKGROUND.get_height())
	)
	background_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	background_sprite.z_index = -100
	add_child(background_sprite)

func _add_animated_background() -> void:
	var stream := load("res://assets/backgrounds/swamp_12fps_2560_q9.ogv")
	if stream == null:
		return
	background_video = VideoStreamPlayer.new()
	background_video.name = "AnimatedSwampBackdrop"
	background_video.stream = stream
	background_video.position = Vector2.ZERO
	background_video.size = WORLD_SIZE
	background_video.expand = true
	background_video.autoplay = true
	background_video.loop = true
	background_video.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_video.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	background_video.z_index = -90
	add_child(background_video)
	background_video.play()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _build_collisions() -> void:
	_add_solid(Rect2(-80, -80, WORLD_SIZE.x + 160, 80), "border_top")
	_add_solid(Rect2(-80, WORLD_SIZE.y, WORLD_SIZE.x + 160, 80), "border_bottom")
	_add_solid(Rect2(-80, -80, 80, WORLD_SIZE.y + 160), "border_left")
	_add_solid(Rect2(WORLD_SIZE.x, -80, 80, WORLD_SIZE.y + 160), "border_right")
	# A shallow lagoon occupies the right side; the boardwalk stays open below it.
	_add_solid(Rect2(1260, 120, 1100, 500), "lagoon_north")
	_add_solid(Rect2(2040, 600, 320, 480), "lagoon_east")
	# Large roots and trunks that shape the walking route.
	_add_solid(Rect2(102, 214, 115, 155), "tree_root_1")
	_add_solid(Rect2(682, 172, 120, 150), "tree_root_2")
	_add_solid(Rect2(2085, 1110, 155, 165), "tree_root_3")
	_add_solid(Rect2(320, 615, 115, 96), "rock_cluster_1")
	_add_solid(Rect2(720, 1120, 140, 80), "rock_cluster_2")
	_add_solid(Rect2(1520, 930, 105, 80), "rock_cluster_3")
	# Teodoro has a small physical footprint so the player cannot overlap him.
	_add_solid(Rect2(1060, 820, 70, 55), "npc_anchor")

func _add_solid(rect: Rect2, body_name: String) -> void:
	var body := StaticBody2D.new()
	body.name = body_name
	body.collision_layer = 1
	body.collision_mask = 1
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	shape_node.shape = shape
	shape_node.position = rect.position + rect.size * 0.5
	body.add_child(shape_node)
	add_child(body)

func _draw() -> void:
	# The authored pixel-art backdrop carries the large forms and landmarks.
	# These procedural details stay live so the scene never reads as a flat PNG.
	_draw_animated_details()

func _draw_base() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), GRASS)
	draw_rect(Rect2(0, 760, 1240, 740), Color("#1b452f"))
	draw_rect(Rect2(720, 0, 1680, 1500), Color("#153729"))
	# Broad patches keep the ground from reading as a flat colour field.
	for i in range(18):
		var x := 90.0 + float((i * 271) % 2050)
		var y := 140.0 + float((i * 173) % 1240)
		draw_circle(Vector2(x, y), 58.0 + float(i % 3) * 18.0, Color(0.10, 0.25, 0.16, 0.22))
	for i in range(80):
		var x := 30.0 + float((i * 173) % 2320)
		var y := 60.0 + float((i * 97) % 1370)
		var c := GRASS_LIGHT if i % 3 == 0 else Color("#245037")
		draw_line(Vector2(x, y), Vector2(x + 5.0, y - 8.0), c, 2.0)
		draw_line(Vector2(x + 5.0, y - 8.0), Vector2(x + 11.0, y - 3.0), c, 2.0)

func _draw_lagoon() -> void:
	var water_rect := Rect2(1240, 92, 1120, 1010)
	draw_rect(water_rect, WATER_DEEP)
	draw_rect(Rect2(1260, 120, 780, 500), WATER)
	draw_rect(Rect2(1320, 620, 720, 360), Color("#0b3750"))
	# Irregular shore highlights.
	for i in range(23):
		var px := 1250.0 + float((i * 137) % 980)
		var py := 105.0 + float((i * 71) % 840)
		draw_line(Vector2(px, py), Vector2(px + 18.0, py + 4.0), Color(0.18, 0.53, 0.57, 0.22), 3.0)
	for y in range(155, 620, 42):
		var drift := sin(elapsed * 0.6 + float(y) * 0.04) * 13.0
		draw_line(Vector2(1280 + drift, y), Vector2(1580 + drift, y + 3), Color(0.25, 0.70, 0.66, 0.18), 2.0)
		draw_line(Vector2(1750 - drift, y + 14), Vector2(2240 - drift, y + 17), Color(0.17, 0.55, 0.62, 0.16), 2.0)
	# Lily pads and flowers.
	for i in range(12):
		var p := Vector2(1320 + float((i * 181) % 970), 170 + float((i * 113) % 760))
		var sway := sin(elapsed * 0.8 + i) * 2.0
		draw_circle(p + Vector2(sway, 0), 15.0, Color("#4d9d45"))
		draw_line(p + Vector2(0, 0), p + Vector2(8, -10), Color("#2d6d3a"), 2.0)
		if i % 4 == 0:
			draw_circle(p + Vector2(-3, -3), 5.0, Color("#ee88b5"))
			draw_circle(p + Vector2(3, -3), 5.0, Color("#f3a4c7"))
			draw_circle(p + Vector2(0, 2), 3.0, Color("#ffd56b"))

func _draw_paths_and_boardwalk() -> void:
	# Earth path to the first dock.
	draw_line(Vector2(260, 1180), Vector2(515, 1090), Color("#523b2a"), 126.0)
	draw_line(Vector2(515, 1090), Vector2(790, 990), Color("#5e432b"), 118.0)
	draw_line(Vector2(790, 990), Vector2(1050, 900), Color("#69482d"), 112.0)
	draw_line(Vector2(260, 1170), Vector2(1040, 900), Color("#a06a3a"), 4.0)
	for i in range(26):
		var t := float(i) / 25.0
		var p := Vector2(280, 1175).lerp(Vector2(1020, 905), t)
		draw_rect(Rect2(p - Vector2(11, 3), Vector2(22, 6)), Color("#c18a48"))
	# Long boardwalk and its side rails.
	var deck := Rect2(860, 820, 750, 150)
	draw_rect(deck, Color("#4c2d22"))
	draw_rect(Rect2(deck.position + Vector2(8, 8), deck.size - Vector2(16, 16)), WOOD)
	for x in range(875, 1600, 42):
		draw_line(Vector2(x, 828), Vector2(x, 962), Color("#3d241d"), 4.0)
		draw_line(Vector2(x + 2, 832), Vector2(x + 28, 832), WOOD_LIGHT, 3.0)
	for x in [875, 1000, 1125, 1250, 1375, 1500, 1595]:
		draw_rect(Rect2(x - 9, 786, 18, 42), Color("#4b2c20"))
		draw_circle(Vector2(x, 787), 11.0, Color("#b07039"))
		draw_line(Vector2(x - 4, 790), Vector2(x + 4, 790), Color("#d18a43"), 2.0)
	# Short spur into the lagoon.
	draw_rect(Rect2(1160, 640, 360, 110), Color("#4b2d21"))
	for x in range(1175, 1515, 44):
		draw_line(Vector2(x, 646), Vector2(x, 744), Color("#2f211d"), 4.0)
		draw_line(Vector2(x + 4, 650), Vector2(x + 32, 650), WOOD_LIGHT, 3.0)

func _draw_structures() -> void:
	# Fisher hut at the upper-left clearing.
	draw_rect(Rect2(520, 230, 250, 190), Color("#42291f"))
	draw_rect(Rect2(535, 246, 220, 162), Color("#765034"))
	draw_colored_polygon(PackedVector2Array([Vector2(495, 245), Vector2(650, 145), Vector2(800, 245)]), Color("#3a2522"))
	draw_colored_polygon(PackedVector2Array([Vector2(515, 238), Vector2(650, 166), Vector2(780, 238)]), Color("#704132"))
	draw_rect(Rect2(625, 312, 48, 96), Color("#2f201c"))
	draw_rect(Rect2(635, 323, 26, 42), Color("#f1a72f"))
	draw_rect(Rect2(640, 328, 16, 32), Color("#ffe58b"))
	draw_rect(Rect2(566, 292, 34, 34), Color("#33231e"))
	draw_rect(Rect2(570, 296, 26, 26), Color("#ffbf47"))
	# A hand-painted sign is the stage's first visual story beat.
	draw_rect(Rect2(770, 438, 112, 132), Color("#3b241d"))
	draw_rect(Rect2(778, 446, 96, 116), Color("#b97a46"))
	draw_line(Vector2(786, 454), Vector2(865, 458), Color("#e0a765"), 2.0)
	draw_string(font, Vector2(790, 478), "RIO", HORIZONTAL_ALIGNMENT_CENTER, 72, 15, Color("#35231e"))
	draw_string(font, Vector2(790, 499), "É VIDA", HORIZONTAL_ALIGNMENT_CENTER, 72, 15, Color("#35231e"))
	draw_string(font, Vector2(790, 530), "RESPEITE", HORIZONTAL_ALIGNMENT_CENTER, 72, 11, Color("#35231e"))
	draw_string(font, Vector2(790, 545), "A MATA", HORIZONTAL_ALIGNMENT_CENTER, 72, 11, Color("#35231e"))
	# A small canoe frames the water without blocking the playable route.
	draw_colored_polygon(PackedVector2Array([Vector2(1750, 815), Vector2(1900, 815), Vector2(1868, 855), Vector2(1782, 855)]), Color("#3b211a"))
	draw_colored_polygon(PackedVector2Array([Vector2(1760, 816), Vector2(1888, 816), Vector2(1860, 844), Vector2(1790, 844)]), Color("#9b5c31"))
	draw_line(Vector2(1825, 810), Vector2(1855, 748), Color("#4b2c20"), 5.0)
	# Campfire ring at the lower clearing.
	var fire := Vector2(480, 1190)
	draw_circle(fire, 48.0, Color(0.05, 0.05, 0.04, 0.30))
	for i in range(8):
		var a := float(i) * TAU / 8.0
		draw_circle(fire + Vector2(cos(a), sin(a)) * 32.0, 9.0, Color("#6b4630"))
	draw_colored_polygon(PackedVector2Array([fire + Vector2(-12, 12), fire + Vector2(0, -31), fire + Vector2(13, 12)]), Color("#f0832e"))
	draw_colored_polygon(PackedVector2Array([fire + Vector2(-7, 10), fire + Vector2(1, -18), fire + Vector2(9, 10)]), Color("#ffd45e"))

func _draw_foliage() -> void:
	for entry in trees:
		_draw_tree(entry[0], float(entry[1]))
	# Reeds around the wet edge.
	for i in range(28):
		var p := Vector2(1180 + float((i * 83) % 1040), 590 + float((i * 43) % 210))
		var sway := sin(elapsed * 1.8 + i * 0.6) * 7.0
		draw_line(p, p + Vector2(sway - 6, -44), Color("#3d7b45"), 3.0)
		draw_line(p + Vector2(4, 0), p + Vector2(sway + 5, -36), Color("#67964d"), 2.0)
		draw_line(p + Vector2(8, 0), p + Vector2(sway + 12, -27), Color("#4d8c49"), 2.0)

func _draw_tree(base: Vector2, tree_scale: float) -> void:
	var sway := sin(elapsed * 1.15 + base.x * 0.01) * 3.5 * tree_scale
	draw_rect(Rect2(base + Vector2(-18, -150) * tree_scale, Vector2(36, 160) * tree_scale), Color("#3a281f"))
	draw_line(base + Vector2(-7, -35) * tree_scale, base + Vector2(-46, -7) * tree_scale, Color("#5b3927"), 12.0 * tree_scale)
	draw_line(base + Vector2(8, -33) * tree_scale, base + Vector2(48, -2) * tree_scale, Color("#5b3927"), 11.0 * tree_scale)
	var blobs := [Vector2(-54, -160), Vector2(3, -198), Vector2(58, -158), Vector2(-5, -122), Vector2(30, -94)]
	for i in range(blobs.size()):
		var center: Vector2 = base + blobs[i] * tree_scale + Vector2(sway, 0)
		var c := Color("#1f633c") if i % 2 == 0 else Color("#2b7b43")
		draw_circle(center, (54.0 - i * 3.0) * tree_scale, c)
		draw_circle(center + Vector2(-12, -12) * tree_scale, (26.0 - i) * tree_scale, Color("#4b9b4d"))
	# hanging vines add motion over the static silhouette.
	for i in range(3):
		var x := base.x + (-32.0 + float(i) * 30.0) * tree_scale + sway
		var length := 32.0 + float((i * 17) % 26)
		draw_line(Vector2(x, base.y - 184.0 * tree_scale), Vector2(x + sin(elapsed * 1.3 + i) * 5.0, base.y - length), Color("#5a9c4a"), 3.0)

func _draw_animated_details() -> void:
	# Ripples expand and contract so the river is alive even when the player stops.
	for i in range(ripples.size()):
		var p: Vector2 = ripples[i]
		var radius := 12.0 + fmod(elapsed * (10.0 + i), 34.0)
		var alpha := 0.36 - radius * 0.006
		draw_arc(p, radius, 0.15, PI * 0.92, 18, Color(0.43, 0.82, 0.76, alpha), 2.0)
		draw_arc(p + Vector2(6, 3), radius * 0.58, 0.2, PI * 0.78, 14, Color(0.70, 0.92, 0.82, alpha * 0.70), 1.0)
	# Fireflies drift over paths and water.
	for i in range(fireflies.size()):
		var start: Vector2 = fireflies[i]
		var p := start + Vector2(sin(elapsed * (0.9 + i * 0.03) + i) * 14.0, cos(elapsed * 0.7 + i * 0.8) * 9.0)
		var pulse := 0.28 + 0.30 * (sin(elapsed * 2.2 + i) * 0.5 + 0.5)
		draw_circle(p, 7.0, Color(1.0, 0.66, 0.24, pulse * 0.16))
		draw_circle(p, 2.5, Color(1.0, 0.88, 0.46, pulse))
	# The supplied animated backdrop already contains moving lantern light.
	# Keep the procedural lantern pass only for the static fallback background.
	if background_video != null:
		return
	for i in range(5):
		var p: Vector2 = [Vector2(892, 780), Vector2(1250, 800), Vector2(1585, 790), Vector2(640, 450), Vector2(460, 1150)][i]
		var flame := 0.5 + 0.5 * sin(elapsed * 5.0 + i)
		draw_circle(p, 25.0 + flame * 5.0, Color(1.0, 0.48, 0.15, 0.06))
		draw_rect(Rect2(p - Vector2(7, 13), Vector2(14, 26)), Color("#4a2b1e"))
		draw_rect(Rect2(p - Vector2(4, 9), Vector2(8, 18)), Color(1.0, 0.70 + flame * 0.15, 0.28, 1.0))
		draw_line(p + Vector2(-11, -17), p + Vector2(11, -17), Color("#c9823a"), 3.0)

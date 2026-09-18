extends Node2D

class_name TeodoroNpc

var elapsed := 0.0
var player_near := false
var sprite: Sprite2D

func _ready() -> void:
	z_index = 1000
	sprite = Sprite2D.new()
	sprite.name = "TeodoroPixelArt"
	sprite.texture = load("res://assets/characters/teodoro/teodoro.webp") as Texture2D
	sprite.position = Vector2(0, -60)
	sprite.scale = Vector2(0.09, 0.09)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)

	var body := StaticBody2D.new()
	body.name = "TeodoroCollision"
	body.collision_layer = 1
	body.collision_mask = 1
	var hit := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(42, 34)
	hit.shape = shape
	hit.position = Vector2(0, -24)
	body.add_child(hit)
	add_child(body)
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	if sprite:
		sprite.position.y = -60.0 + sin(elapsed * 2.0) * 1.4
	queue_redraw()

func _draw() -> void:
	var bob := sin(elapsed * 2.0) * 1.4
	var shadow := PackedVector2Array()
	for i in range(18):
		var angle := float(i) * TAU / 18.0
		shadow.append(Vector2(cos(angle) * 29.0, sin(angle) * 7.0 + 3.0))
	draw_colored_polygon(shadow, Color(0.02, 0.04, 0.03, 0.42))
	if player_near:
		var pulse := 0.6 + 0.3 * sin(elapsed * 4.0)
		draw_circle(Vector2(0, -137 + bob), 16.0, Color(1.0, 0.76, 0.26, 0.08 + pulse * 0.08))
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, -150 + bob), Vector2(9, -140 + bob), Vector2(0, -130 + bob), Vector2(-9, -140 + bob)
		]), Color(1.0, 0.82, 0.36, pulse))

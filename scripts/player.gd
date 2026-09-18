extends CharacterBody2D

class_name EricPlayer

const ATLAS: Texture2D = preload("res://assets/characters/eric/spritesheet.webp")
const SPEED := 230.0

var dialogue_locked := false
var animation_clock := 0.0
var sprite: Sprite2D
var collision: CollisionShape2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	z_index = 100
	collision = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(34, 24)
	collision.shape = shape
	collision.position = Vector2(0, -14)
	add_child(collision)

	sprite = Sprite2D.new()
	sprite.name = "EricAnimatedSprite"
	sprite.texture = ATLAS
	sprite.hframes = 8
	sprite.vframes = 11
	sprite.scale = Vector2(0.58, 0.58)
	sprite.position = Vector2(0, -60)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	_set_frame(0, 0)

	var shadow := Polygon2D.new()
	shadow.name = "GroundShadow"
	shadow.polygon = PackedVector2Array([
		Vector2(-34, -2), Vector2(-20, -8), Vector2(18, -8), Vector2(36, -2),
		Vector2(18, 5), Vector2(-21, 5)
	])
	shadow.color = Color(0.02, 0.04, 0.03, 0.38)
	shadow.z_index = -1
	add_child(shadow)

func _physics_process(delta: float) -> void:
	var input_dir := _read_movement_input()
	if dialogue_locked:
		input_dir = Vector2.ZERO
		velocity = Vector2.ZERO
	else:
		velocity = input_dir * SPEED
		move_and_slide()
		global_position.x = clamp(global_position.x, 50.0, 2350.0)
		global_position.y = clamp(global_position.y, 90.0, 1430.0)
		if input_dir.length_squared() > 0.01:
			animation_clock += delta
		else:
			animation_clock += delta * 0.80
	_update_animation(input_dir)
	z_index = 100 + int(global_position.y)

func _read_movement_input() -> Vector2:
	var axis := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		axis.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		axis.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		axis.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		axis.y += 1.0
	return axis.normalized() if axis.length_squared() > 1.0 else axis

func _update_animation(input_dir: Vector2) -> void:
	var row := 0
	var frame_count := 6
	var fps := 5.5
	if dialogue_locked:
		row = 3
		frame_count = 4
		fps = 5.0
	elif input_dir.length_squared() > 0.01:
		if abs(input_dir.x) > 0.18:
			row = 1 if input_dir.x > 0.0 else 2
			frame_count = 6
			fps = 10.0
		elif input_dir.y < 0.0:
			row = 9
			frame_count = 1
		else:
			row = 10
			frame_count = 1
	var frame := int(animation_clock * fps) % frame_count
	_set_frame(row, frame)
	var moving_horizontally: bool = not dialogue_locked and input_dir.length_squared() > 0.01 and abs(input_dir.x) > 0.18
	if moving_horizontally:
		# A small synced bounce reinforces the contact/pass/contact rhythm at game scale.
		sprite.position.y = -60.0 + sin(animation_clock * fps * TAU / 6.0) * 1.6
	else:
		sprite.position.y = -60.0

func _set_frame(row: int, frame: int) -> void:
	if sprite == null:
		return
	sprite.frame_coords = Vector2i(frame, row)

func can_interact(target: Node2D) -> bool:
	return target != null and global_position.distance_to(target.global_position) <= 132.0

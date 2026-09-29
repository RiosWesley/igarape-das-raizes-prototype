extends CharacterBody2D

class_name EricPlayer

const ATLAS: Texture2D = preload("res://assets/characters/eric/spritesheet_directional.png")
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
	var animation_input := input_dir
	if dialogue_locked:
		input_dir = Vector2.ZERO
		animation_input = Vector2.ZERO
		velocity = Vector2.ZERO
	else:
		var movement_world := get_parent().get_node_or_null("IgarapeDasRaizes")
		var frame_motion := input_dir * SPEED * delta
		var allowed_input := input_dir
		if movement_world != null and movement_world.has_method("can_player_stand_at"):
			if not bool(movement_world.call("can_player_stand_at", global_position + frame_motion)):
				allowed_input = Vector2.ZERO
				var can_move_x: bool = abs(input_dir.x) > 0.0 and bool(movement_world.call("can_player_stand_at", global_position + Vector2(frame_motion.x, 0.0)))
				var can_move_y: bool = abs(input_dir.y) > 0.0 and bool(movement_world.call("can_player_stand_at", global_position + Vector2(0.0, frame_motion.y)))
				if can_move_x and can_move_y:
					if abs(input_dir.x) >= abs(input_dir.y):
						allowed_input.x = input_dir.x
					else:
						allowed_input.y = input_dir.y
				elif can_move_x:
					allowed_input.x = input_dir.x
				elif can_move_y:
					allowed_input.y = input_dir.y
		animation_input = allowed_input
		velocity = allowed_input * SPEED
		var previous_position := global_position
		move_and_slide()
		if movement_world != null and movement_world.has_method("can_player_stand_at") and not bool(movement_world.call("can_player_stand_at", global_position)):
			global_position = previous_position
			velocity = Vector2.ZERO
			animation_input = Vector2.ZERO
		if animation_input.length_squared() > 0.01:
			animation_clock += delta
		else:
			animation_clock += delta * 0.80
	_update_animation(animation_input)
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
			frame_count = 8
			fps = 10.0
		else:
			row = 10
			frame_count = 8
			fps = 10.0
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

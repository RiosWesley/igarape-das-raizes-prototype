extends Node2D

class_name RiverStage

var world: Node2D
var player: CharacterBody2D
var npc: Node2D
var hud: CanvasLayer

var dialogue_active := false
var dialogue_index := 0
var objective_step := 0
var action_menu_open := false
var dialogue_lines := [
	["TEODORO BARCOS", "Voce ouviu? O igarape muda de voz quando a mata precisa de ajuda."],
	["TEODORO BARCOS", "Atravesse a ponte e procure o marco com tres raizes. A primeira pista esta la."],
	["TEODORO BARCOS", "Leve o que encontrar com respeito, Eric. O rio sempre devolve um caminho."],
	["TEODORO BARCOS", "Boa sorte, menino. Quando a agua brilhar, escute antes de tocar."]
]

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("#07151c"))
	world = preload("res://scripts/world.gd").new()
	world.name = "IgarapeDasRaizes"
	add_child(world)

	player = preload("res://scripts/player.gd").new()
	player.name = "EricPeresa"
	player.position = Vector2(430, 1060)
	add_child(player)

	npc = preload("res://scripts/npc.gd").new()
	npc.name = "TeodoroBarcos"
	npc.position = Vector2(1080, 858)
	add_child(npc)

	hud = preload("res://scripts/hud.gd").new()
	hud.name = "AdventureHUD"
	hud.game = self
	add_child(hud)

	var camera := Camera2D.new()
	camera.name = "ExplorerCamera"
	camera.position = Vector2(0, -115)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(world.WORLD_SIZE.x)
	camera.limit_bottom = int(world.WORLD_SIZE.y)
	camera.limit_smoothed = true
	player.add_child(camera)

	objective_step = 1

func _process(_delta: float) -> void:
	if npc and player:
		npc.player_near = player.can_interact(npc)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_E or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		if dialogue_active:
			_advance_dialogue()
		elif player.can_interact(npc):
			_start_dialogue()
	elif event.keycode == KEY_ESCAPE and dialogue_active:
		_close_dialogue()

func _start_dialogue() -> void:
	dialogue_active = true
	dialogue_index = 0
	objective_step = max(objective_step, 2)
	player.dialogue_locked = true

func _advance_dialogue() -> void:
	if dialogue_index < dialogue_lines.size() - 1:
		dialogue_index += 1
	else:
		_close_dialogue()

func _close_dialogue() -> void:
	dialogue_active = false
	player.dialogue_locked = false
	objective_step = 3

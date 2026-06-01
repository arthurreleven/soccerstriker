extends Node

var tempo_restante = 490.0
var placar_p1 = 0
var placar_p2 = 0
var jogo_ativo = true
var gol_em_andamento = false

@onready var player1 = $"../Player1"
@onready var player2 = $"../Player2"
@onready var bola = $"../Ball"
@onready var hud = $"../HUD"
@onready var gol_effect = get_tree().get_root().find_child("GolEffect", true, false)
@onready var sound_effect = $SomChute
@onready var sound_jump = $SomPulo
@onready var sound_apito = $SomApito
@onready var sound_apito_final = $SomApitoFinal
@onready var spawn_bola = $"../SpawnBola"

var pos_p1 = Vector2.ZERO
var pos_p2 = Vector2.ZERO
var pos_bola = Vector2.ZERO

func _ready():
	pos_p1 = player1.global_position
	pos_p2 = player2.global_position
	pos_bola = bola.global_position
	tocar_apito()

func _process(delta):
	if jogo_ativo:
		tempo_restante -= delta
		hud.atualizar_tempo(tempo_restante)
		if tempo_restante <= 0:
			fim_de_jogo()

func gol_player1():
	if not jogo_ativo or gol_em_andamento:
		return
	gol_em_andamento = true
	
	jogo_ativo = false  
	hud.atualizar_tempo(tempo_restante)
	
	placar_p1 += 1
	hud.atualizar_placar(placar_p1, placar_p2)
	
	player1.set_physics_process(false)
	player2.set_physics_process(false)
	if "velocity" in player1:
		player1.velocity = Vector2.ZERO
	if "velocity" in player2:
		player2.velocity = Vector2.ZERO
	
	if gol_effect:
		var tween = gol_effect.mostrar_gol()
		gol_effect._spawn_particulas()
		await tween.finished
	reiniciar_jogo()

func gol_player2():
	if not jogo_ativo or gol_em_andamento:
		return
	gol_em_andamento = true
	
	jogo_ativo = false
	hud.atualizar_tempo(tempo_restante)
	
	placar_p2 += 1
	hud.atualizar_placar(placar_p1, placar_p2)

	player1.set_physics_process(false)
	player2.set_physics_process(false)
	if "velocity" in player1:
		player1.velocity = Vector2.ZERO
	if "velocity" in player2:
		player2.velocity = Vector2.ZERO

	if gol_effect:
		var tween = gol_effect.mostrar_gol()
		gol_effect._spawn_particulas()
		await tween.finished
	reiniciar_jogo()

func reiniciar_jogo():
	jogo_ativo = false
	gol_em_andamento = true
	
	player1.set_physics_process(false)
	player2.set_physics_process(false)
	
	if "velocity" in player1:
		player1.velocity = Vector2.ZERO
	if "velocity" in player2:
		player2.velocity = Vector2.ZERO
		
	await get_tree().create_timer(0.5).timeout

	player1.global_position = pos_p1
	player2.global_position = pos_p2

	await get_tree().physics_frame
	
	await bola.resetar(spawn_bola.global_position)
	
	await get_tree().physics_frame
	
	player1.set_physics_process(true)
	player2.set_physics_process(true)
	
	$"../GolEsquerdo".set_deferred("monitoring", true)
	$"../GolDireita".set_deferred("monitoring", true)
	
	gol_em_andamento = false
	jogo_ativo = true
	
	tocar_apito()

func fim_de_jogo():
	jogo_ativo = false
	hud.mostrar_fim(placar_p1, placar_p2)
	tocar_apito_final()
	print("⏱️ Fim de jogo!")
	if "velocity" in player1:
		player1.velocity = Vector2.ZERO
	if "velocity" in player2:
		player2.velocity = Vector2.ZERO
	player1.set_physics_process(false)
	player2.set_physics_process(false)
	bola.freeze = true

func tocar_apito_final():
	sound_apito_final.play(2.38)
	await get_tree().create_timer(0.68).timeout
	sound_apito_final.stop()

func tocar_chute():
	sound_effect.stream = load("res://sounds/kick.wav")
	sound_effect.play()

func tocar_pulo():
	sound_jump.stream = load("res://sounds/jump.wav")
	sound_jump.play()

func tocar_apito():
	sound_apito.play(0.0)
	await get_tree().create_timer(1.35).timeout
	sound_apito.stop()

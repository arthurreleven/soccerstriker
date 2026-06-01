extends Control

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/selecao_mapa.tscn")
	pass
	
func _on_local_pressed():
	print("Botão local clicado")
	GameState.multiplayer_mode = false
	print("Modo:", GameState.multiplayer_mode)
	var err = get_tree().change_scene_to_file("res://scenes/main.tscn")
	print("Troca de cena:", err)

func _on_multiplayer_pressed():
	print("Botão multiplayer clicado")
	GameState.multiplayer_mode = true
	print("Modo:", GameState.multiplayer_mode)
	var err = get_tree().change_scene_to_file("res://scenes/main.tscn")
	print("Troca de cena:", err)

func _on_credits_pressed() -> void:
	pass

func _on_quit_game_pressed() -> void:
	get_tree().quit()

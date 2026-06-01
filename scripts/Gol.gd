extends Area2D

@export var lado = ""

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("COLIDIU COM:", body.name)

	if body.name == "Ball":
		print("BOLA ENTROU")

		var gm = get_tree().get_root().find_child("GameManager", true, false)

		print("GAME MANAGER:", gm)
		print("LADO:", lado)

		if lado == "esquerdo":
			print("VAI CHAMAR PLAYER 2")
			gm.gol_player2()

		elif lado == "direito":
			print("VAI CHAMAR PLAYER 1")
			gm.gol_player1()

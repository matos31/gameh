extends Node2D

var is_in_corrupted_world = false

func _ready():
	var player = $Player
	player.connect("request_world_change", Callable(self, "change_world"))
	is_in_corrupted_world = false
	change_world(true)
	_atualizar_inimigos(false)

func _unhandled_input(event):
	if event.is_action_pressed("change_world"):
		change_world()

func change_world(force := false):
	if not force:
		is_in_corrupted_world = !is_in_corrupted_world

	# 🧱 Terreno
	$TileMapNormal/Terrainormal.visible = !is_in_corrupted_world
	$TileMapNormal/Terrainormal.enabled = !is_in_corrupted_world
	$TileMapCorrompido/Terraincorruptd.visible = is_in_corrupted_world
	$TileMapCorrompido/Terraincorruptd.enabled = is_in_corrupted_world
	
	# 🎨 Decorações
	$TileMapNormal/Decoration.visible = !is_in_corrupted_world
	$TileMapNormal/Decoration.enabled = !is_in_corrupted_world
	$TileMapCorrompido/Decoration.visible = is_in_corrupted_world
	$TileMapCorrompido/Decoration.enabled = is_in_corrupted_world

	# 🌄 Parallax
	$ParallaxBackgroundNormal.visible = !is_in_corrupted_world
	$ParallaxBackgroundCorrompido.visible = is_in_corrupted_world

	# 👾 Inimigos
func _atualizar_inimigos(ativar: bool):
	for inimigo in $EnemiesCorrompido.get_children():
		inimigo.visible = ativar
		inimigo.set_process(ativar)
		inimigo.set_physics_process(ativar)

		if inimigo.has_node("CollisionShape2D"):
			inimigo.get_node("CollisionShape2D").disabled = !ativar

		if inimigo.has_node("Hitbox"):
			var hitbox = inimigo.get_node("Hitbox")
			hitbox.monitoring = ativar
			hitbox.set_process(ativar)
			hitbox.set_physics_process(ativar)
			if hitbox.has_node("CollisionShape2D"):
				hitbox.get_node("CollisionShape2D").disabled = !ativar


	print("🌍 Mundo atual:", "Corrompido" if is_in_corrupted_world else "Normal")

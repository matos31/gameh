extends Node2D

var is_in_corrupted_world = false

func _ready():
	var player = $Player  # ou o caminho correto
	player.connect("request_world_change", Callable(self, "change_world"))
# 
	
func _unhandled_input(event):
	if event.is_action_pressed("change_world"):
		change_world()

func change_world():
	is_in_corrupted_world = !is_in_corrupted_world

	# 🧱 Terreno
	$TileMapNormal/Terrainormal.visible = !is_in_corrupted_world
	$TileMapNormal/Terrainormal.enabled = !is_in_corrupted_world
	$TileMapCorrompido/Terraincorruptd.visible = is_in_corrupted_world
	$TileMapCorrompido/Terraincorruptd.enabled = is_in_corrupted_world

	# 🌄 Parallax
	$ParallaxBackgroundNormal.visible = !is_in_corrupted_world
	$ParallaxBackgroundCorrompido.visible = is_in_corrupted_world

	# 👾 Inimigos
	

	print("🌍 Mundo atual:", "Corrompido" if is_in_corrupted_world else "Normal")

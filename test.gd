extends Node

@onready var tile_layer_scene: PackedScene = preload("res://node_2d.tscn")
@onready var player_scene: PackedScene = preload("res://player_test.tscn")

func _ready() -> void:
	var tile_layer_instance = tile_layer_scene.instantiate()
	add_child(tile_layer_instance)
	
	# Conectar la señal para colocar al jugador
	tile_layer_instance.connect("tiles_generated", Callable(self, "_on_tiles_generated"))

func _on_tiles_generated() -> void:
	var tile_layer_instance = get_node("node_2d")  # Asegúrate de que esta ruta sea correcta
	var random_position = tile_layer_instance.get_random_tile_position()
	
	if random_position != Vector2.ZERO:
		var player_instance = player_scene.instantiate()
		tile_layer_instance.add_child(player_instance)  # Hacemos al jugador hijo del TileLayer
		player_instance.global_position = random_position
	else:
		push_error("No se encontró una posición válida para colocar al jugador.")

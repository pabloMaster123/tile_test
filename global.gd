extends Node

@onready var tile_layer_instance: Node = null
@onready var player_instance: Node = null

func _ready():
	# Cargar las escenas
	tile_layer_instance = load_scene_instance("res://tile_json.tscn")
	player_instance = load_scene_instance("res://player_test.tscn")

	if tile_layer_instance and player_instance:
		add_child(tile_layer_instance)
		add_child(player_instance)

		# Conectar la señal del TileLayer
		if tile_layer_instance.has_signal("tiles_generated"):
			tile_layer_instance.connect("tiles_generated", Callable(self, "_on_tiles_generated"))
			print("Señal 'tiles_generated' conectada con éxito")
		else:
			push_error("El TileLayer no tiene la señal 'tiles_generated'")
	else:
		push_error("No se pudieron cargar las escenas correctamente")

func load_scene_instance(scene_path: String) -> Node:
	var scene = load(scene_path)
	if scene:
		return scene.instantiate()
	else:
		push_error("Error al cargar la escena: %s" % scene_path)
		return null

func _on_tiles_generated():
	# Callback para cuando los tiles sean generados
	if tile_layer_instance.has_method("get_random_tile_position"):
		var spawn_position: Vector2 = tile_layer_instance.call("get_random_tile_position")
		if spawn_position != Vector2.ZERO:
			player_instance.global_position = spawn_position
			print("Jugador movido a la posición:", spawn_position)
		else:
			push_error("No se pudo obtener una posición válida en el TileLayer")
	else:
		push_error("El TileLayer no tiene el método 'get_random_tile_position'")

extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

# Ruta al archivo JSON
const JSON_PATH: String = "res://tile_layer.json"

func _ready() -> void:
	if tile_map_layer == null:
		push_error("TileMapLayer no encontrado. Verifica la ruta o el nombre del nodo.")
		return

	print("Cargando archivo JSON desde ", JSON_PATH)
	var json_data = load_json(JSON_PATH)
	if json_data:
		print("Archivo JSON cargado correctamente")
		process_tile_data(json_data)
		road_creation(json_data)
	else:
		push_error("Error al cargar el archivo JSON")

func load_json(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		print("Archivo JSON encontrado en ", path)
		var file = FileAccess.open(path, FileAccess.ModeFlags.READ)
		var json_content = file.get_as_text()
		file.close()
		
		var json_parser = JSON.new()
		var result = json_parser.parse(json_content)
		if result == OK:
			print("JSON parseado correctamente")
			return json_parser.data
		else:
			push_error("Error al parsear JSON: " + str(result))
	else:
		push_error("Archivo no encontrado: " + path)
	return {}

func process_tile_data(data: Dictionary) -> void:
	print("Iniciando procesamiento de datos")
	var tile_data = data.get("tile", [])
	var model_data = data.get("model", [])
	
	var model_dict: Dictionary = {}
	for model in model_data:
		var model_id = model.get("id")
		var atlas_position = Vector2i(model["atlas_position"]["x"], model["atlas_position"]["y"])
		model_dict[model_id] = atlas_position
		print("Modelo registrado: ID = ", model_id, " Posición en atlas = ", atlas_position)
	
	for tile in tile_data:
		for item in tile.get("items", []):
			var item_id = item.get("id", null) # Leer el nuevo campo id
			var model_id = item.get("model")
			var atlas_position = model_dict.get(model_id, null)
			
			if atlas_position == null:
				push_error("Modelo no encontrado para ID " + str(model_id))
				continue
			
			var from_pos = Vector2i(item["area"]["from"]["x"], item["area"]["from"]["y"])
			var to_pos = Vector2i(item["area"]["to"]["x"], item["area"]["to"]["y"])
			print("Procesando área desde ", from_pos, " hasta ", to_pos, " para el item ID: ", item_id)

			for x in range(from_pos.x, to_pos.x + 1):
				for y in range(from_pos.y, to_pos.y + 1):
					var cell_position = Vector2i(x, y)
					set_tile_in_layer(tile_map_layer, cell_position, atlas_position)
	print("Procesamiento de datos completado")

func road_creation(json_data: Dictionary) -> void:
	var rng = RandomNumberGenerator.new()
	var random_int = 0
	
	var border = []
	var items = []
	
	var roads = []
	
	items = get_item_ids(json_data)
	
	for x in range(items.size()):
		print(items[x])
		border = get_border_positions_by_model(json_data, items[x])
		# Generar un número aleatorio entero entre 0 y border.size() - 1
		random_int = rng.randi_range(0, border.size() - 1)
		roads.append(border[random_int])
	
	for x in range(roads.size()):
		set_tile_in_layer(tile_map_layer, roads[x], Vector2i(3, 0))

func get_item_ids(json_data: Dictionary) -> Array:
	var item_ids = []

	# Iterar sobre los mosaicos y sus items
	var tile_data = json_data.get("tile", [])
	for tile in tile_data:
		for item in tile.get("items", []):
			var item_id = item.get("id", null) # Leer el csampo id
			if item_id != null:
				item_ids.append(item_id)

	return item_ids

# Encuentra las posiciones de los bordes dentro de las áreas de un modelo específico
func get_border_positions_by_model(json_data: Dictionary, model_id: int) -> Array:
	var borders = []

	# Iterar sobre los mosaicos y sus áreas
	var tile_data = json_data.get("tile", [])
	for tile in tile_data:
		for item in tile.get("items", []):
			if item.get("id") == model_id:  # Verificar si el modelo coincide
				var area_from = Vector2i(item["area"]["from"]["x"], item["area"]["from"]["y"])
				var area_to = Vector2i(item["area"]["to"]["x"], item["area"]["to"]["y"])

				# Agregar posiciones de los bordes
				# Bordes horizontales
				for x in range(area_from.x, area_to.x + 1):
					borders.append(Vector2i(x, area_from.y))  # Borde superior
					borders.append(Vector2i(x, area_to.y))    # Borde inferior

				# Bordes verticales
				for y in range(area_from.y + 1, area_to.y):  # Evitar duplicados en esquinas
					borders.append(Vector2i(area_from.x, y))  # Borde izquierdo
					borders.append(Vector2i(area_to.x, y))    # Borde derecho

	# Devolver las posiciones de los bordes
	return borders

func set_tile_in_layer(layer: TileMapLayer, cell_position: Vector2i, atlas_position: Vector2i) -> void:
	if not layer:
		push_error("Layer no válido")
		return
	# Colocar el mosaico si la celda está libre
	if atlas_position != null:
		layer.set_cell(cell_position, 0, atlas_position)
		print("Mosaico colocado en celda ", cell_position, " con atlas ", atlas_position)
	else:
		push_error("Posición del atlas inválida para la celda ", cell_position)

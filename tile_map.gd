extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

# Ruta al archivo JSON
const DUNGEON_PATH = "res://tile_layer.json"

var dungeonData: Dictionary = {}

func _ready():
	# Cargar los datos del JSON
	dungeonData = load_json(DUNGEON_PATH)
	print("Dungeon Data: ", dungeonData)

	# Validar que `chunks` existe en el JSON
	if "chunks" in dungeonData:
		for chunk in dungeonData["chunks"]:
			if "items" in chunk:
				for item in chunk["items"]:
					process_item(item)

func process_item(item: Dictionary):
	# Validar que el item tiene los datos necesarios
	if "model" in item and "area" in item:
		var currentModel = item["model"]
		var yCoordinate = item["area"]["from"]["y"]
		var initial = item["area"]["from"]
		var final = item["area"]["to"]

		print("Processing Model: ", currentModel)
		print("Area From: ", initial, ", To: ", final)

		# Llamar a la función para manejar el área
		make_area(currentModel, yCoordinate, initial, final)

func make_area(model: int, yCoordinate: int, initial: Dictionary, final: Dictionary):
	# Colocar tiles dentro del área definida
	for x in range(initial["x"], final["x"] + 1):
		for y in range(initial["y"], final["y"] + 1):
			tile_map_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))  # Usa el modelo para el atlas si es necesario

func load_json(filePath: String) -> Dictionary:
	if FileAccess.file_exists(filePath):
		print("File Does Exist!")
		var file = FileAccess.open(filePath, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()

		print("JSON String: ", json_string)  # Mostrar el contenido del archivo

		# Intentar parsear el JSON
		var json_result = JSON.parse_string(json_string)
		if json_result.error == OK:
			return json_result.result
		else:
			print("Failed to parse JSON. Error Code: ", json_result.error)
	else:
		print("File Does not Exist!")
	return {}

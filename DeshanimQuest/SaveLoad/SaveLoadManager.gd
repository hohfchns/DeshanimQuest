extends Node


func __save_to_file(path: String, data: Dictionary):
	var file = File.new()
	
	file.open(path, file.WRITE)
	
	file.store_line(to_json(data))
	
	file.close()

func __load_from_file(path):
	var file = File.new()
	
	if not file.file_exists(path):
		print("Tried to load but path is invalid. Returning null.")
		return null
	
	file.open(path, file.READ)
	
	var text = file.get_as_text()
	
	var data = parse_json(text)
	
	file.close()
	
	return data


func get_cur_save_data() -> Dictionary:
	var save_data: Dictionary = {}
	
	save_data["last_scene"] = get_tree().current_scene
	
	save_data["player"] = {}
	save_data["player"]["max_health"] = PlayerStats.get_max_health()
	save_data["player"]["health"] = PlayerStats.get_health()
	save_data["player"]["inventory_items"] = PlayerInventory.inventory.get_items()
	
	return save_data


func load_data(data: Dictionary):
	if "last_scene" in data:
		get_tree().change_scene_to(data["last_scene"])
	
	if "player" in data:
		if "max_health" in data["player"]:
			PlayerStats.set_max_health(data["player"]["max_health"])
		if "health" in data["player"]:
			PlayerStats.set_health(data["player"]["health"])
		if "inventory_items" in data["player"]:
			PlayerInventory.inventory.set_items(data["player"]["inventory_items"])


func save_to_slot(slot_index: int):
	var dir_path = "user:://Saves/"
	var path = "%ssave%s.json" % [dir_path, slot_index]
	
	var dir = Directory.new()
	
	if not dir.dir_exists(dir_path):
		dir.make_dir_recursive(dir_path)
	
	var save_data: Dictionary = get_cur_save_data()
	
	__save_to_file(path, save_data)

func load_from_slot(slot_index: int):
	var path = "user://Saves/save%s.json" % slot_index
	
	var save_data: Dictionary = __load_from_file(path)
	
	load_data(save_data)

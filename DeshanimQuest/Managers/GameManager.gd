extends Node

var __player_ref = null

var is_mouse_on_button = false

var menus_ll: LinkedList = LinkedList.new()

# Should be called by the player when it enters the scene
func generate_player_ref():
	__player_ref = get_node("/root/SceneRoot/YSort/Player")

func get_player():
	if __player_ref:
		return __player_ref
	else:
		print("Player not found, is likely not in scene.")


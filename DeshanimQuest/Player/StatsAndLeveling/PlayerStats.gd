extends Node

signal class_changed(new_class)

signal stats_changed(old_stats, new_stats)

signal health_changed
signal no_health

signal stamina_changed

signal mana_changed


enum Classes { NOCLASS, RANGER, WARRIOR }

export(Classes) var player_class
var current_class_name = Classes.keys()[player_class]

export var __stats: Dictionary = {
	# VITALITY - Increase health
	"VIT": 0,
	# ENDURANCE - Increase stamina
	"END": 0,
	# STRENGTH - Increased damage with melee weapons
	"STR": 0,
	# DEXTERITY - Slightliy increased stamina and increased damage with ranged weapons
	"DEX": 0,
	# RESISTANCE - Increased defense
	"RES": 0,
	# INTELLIGENCE - Increased mana and damage with magic weapons
	"INT": 0,
} setget set_stats, get_stats


export var __base_max_health: int = 200.0
var __max_health: int = __base_max_health setget set_max_health, get_max_health
export var __health: int = __max_health setget set_health, get_health

export var __base_max_stamina: int = 100.0
var __max_stamina: int = __base_max_stamina setget set_max_stamina, get_max_stamina
export var __stamina: int = __max_stamina setget set_stamina, get_stamina

export var __base_max_mana: int = 100.0
var __max_mana: int = __base_max_mana setget set_max_mana, get_max_mana
export var __mana: int = __max_mana setget set_mana, get_mana


export var vit_health_mult_amt: float = 0.05
export var end_stamina_mult_amt: float = 0.05
export var str_damage_mult_amt: float = 0.05
export var dex_stamina_mult_amt: float = 0.02
export var dex_damage_mult_amt: float = 0.04
export var res_defense_mult_amt: float = 0.05
export var int_mana_mult_amt: float = 0.03
export var int_damage_mult_amt: float = 0.04


func _ready():
	connect("stats_changed", self, "_on_stats_changed")
	
	connect("health_changed", self, "_on_health_changed")
	SaveLoad.connect("save_loaded", self, "_on_save_loaded")
	
	current_class_name = Classes.keys()[player_class]
	
	set_stats(
		{
			"VIT": 5,
			"END": 3,
			"STR": 10,
			"DEX": 20,
			"RES": 5,
			"INT": 10,
		}
	)
	
	set_max_health(calc_max_health())


func set_class(new_class):
	player_class = new_class
	current_class_name = Classes.keys()[new_class]
	
	emit_signal("class_changed", new_class)


func set_stats(new_stats):
	var old_stats = __stats
	
	__stats = new_stats
	
	emit_signal("stats_changed", old_stats, new_stats)

func get_stats():
	return __stats


func set_health(value):
	__health = value
	
	emit_signal("health_changed")

func get_health():
	return __health

func add_health(value):
	set_health(min(get_health() + value, get_max_health()))

func subtract_health(value):
	set_health(__health - value)


func set_max_health(value):
	__max_health = value

func get_max_health():
	return __max_health

func calc_max_health():
	var multiplier = 1 + (vit_health_mult_amt * get_stats()["VIT"])
	return int(__base_max_health * multiplier)


func set_stamina(value):
	__stamina = value
	
	emit_signal("stamina_changed")

func get_stamina():
	return __stamina

func add_stamina(value):
	set_stamina(min(get_stamina() + value, get_max_stamina()))

func subtract_stamina(value):
	set_stamina(__stamina - value)


func set_max_stamina(value):
	__max_stamina = value

func get_max_stamina():
	return __max_stamina

func calc_max_stamina():
	var multiplier = 1 + (end_stamina_mult_amt * get_stats()["END"]) + (dex_stamina_mult_amt * get_stats()["DEX"])
	return int(__base_max_stamina * multiplier)


func set_mana(value):
	__mana = value
	
	emit_signal("mana_changed")

func get_mana():
	return __mana

func add_mana(value):
	set_mana(min(get_mana() + value, get_max_mana()))

func subtract_mana(value):
	set_mana(__mana - value)


func set_max_mana(value):
	__max_mana = value

func get_max_mana():
	return __max_mana

func calc_max_mana():
	var multiplier = 1 + (int_mana_mult_amt * get_stats()["END"])
	return int(__base_max_mana * multiplier)


func _on_health_changed():
	if __health <= 0:
		emit_signal("no_health")


func _on_save_loaded(save_data, slot_idx):
	if not "player" in save_data:
		return
	
	if "class" in save_data["player"]:
		set_class(save_data["player"]["class"])
	else:
		set_class(Classes.RANGER)
	
	if "max_health" in save_data["player"]:
		if save_data["save_version"] > 2:
			set_max_health(save_data["player"]["max_health"])
		else:
			set_max_health(save_data["player"]["max_health"] * 20)
	if "health" in save_data["player"]:
		if save_data["save_version"] > 2:
			set_health(save_data["player"]["health"])
		else:
			set_health(save_data["player"]["health"] * 20)
	
	print("Player stats set from save %s" % (slot_idx+1))


func _on_stats_changed(old_stats, new_stats):
	set_health(calc_max_health())
	
	set_stamina(calc_max_stamina())
	
	set_mana(calc_max_mana())

extends KinematicBody2D

export var __max_speed = Vector2(200, 200)
export var __acceleration_amt = 1500
export var __friction_amt = 1200

#export(NodePath) var __right_hand_path; onready var __right_hand = get_node(__right_hand_path) as FloatingHand
export(NodePath) onready var __hand_axis = get_node(__hand_axis) as Node2D
export(NodePath) onready var __hand_rot_point = get_node(__hand_rot_point) as Node2D
onready var __current_item = __hand_rot_point.get_child(0)

export(NodePath) onready var __body_anim = get_node(__body_anim) as AnimationPlayer

var __can_attack: bool = true
var __can_move: bool = true

var __input_vector = Vector2(0, 0)
var __last_input_vector = Vector2(1, 0)

var __velocity = Vector2(0, 0)

func _ready():
	pass


func _physics_process(delta):
	
	__calc_input_vector()
	
	__movement_code(delta)
	
	__animate_sprites()
	
	__set_hand_distance_and_rot()
	
	__get_player_input()
	
	__last_input_vector = __input_vector if __input_vector else __last_input_vector 


func __calc_input_vector():
	__input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	__input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	__input_vector = __input_vector.normalized()


func __movement_code(delta):
	if __input_vector != Vector2.ZERO:
		__velocity = __velocity.move_toward(__input_vector * __max_speed, __acceleration_amt * delta)
	else:
		__velocity = __velocity.move_toward(Vector2(0, 0), __friction_amt * delta)
	
	move_and_collide(__velocity * delta)


func __animate_sprites():
	var moving: bool = __input_vector != Vector2.ZERO
	var rot = __hand_axis.rotation_degrees
	
	if moving:
		if __current_item.global_position > self.global_position:
			__body_anim.play("RunRight")
		else:
			__body_anim.play("RunLeft")
	elif not moving:
		if __current_item.global_position > self.global_position:
			__body_anim.play("IdleRight")
		else:
			__body_anim.play("IdleLeft")


func __set_hand_distance_and_rot():
	
	if get_global_mouse_position() > self.get_global_position():
		__hand_axis.scale.x = 1
	else:
		__hand_axis.scale.x = -1
	
	__hand_rot_point.look_at(get_global_mouse_position())
	


func __play_current_item_anim(var anim_name: String):
	var ap = __current_item.get_node("AnimationPlayer") as AnimationPlayer
	ap.play(anim_name)


func __get_player_input():
	if Input.is_action_just_pressed("use_item"):
		__play_current_item_anim("Main")
	elif Input.is_action_just_pressed("alt_use_item"):
		__play_current_item_anim("Alt")





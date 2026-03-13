extends Node
class_name InputHelper
var last_z_press: int = 0999
var last_x_press: int = 0999
var last_c_press: int = 0999
var last_shift_press: int = 0999
var last_z_release: int = 0999
var last_x_release: int = 0999
var last_c_release: int = 0999
var last_shift_release: int = 0999
var z_pressed: bool = false
var x_pressed: bool = false
var c_pressed: bool = false
var shift_pressed: bool = false
var menu_just_pressed: bool = false
var d: Vector2 = Vector2.ZERO
func _physics_process(_d):
	last_z_press = 0 if Input.is_action_just_pressed("z") else last_z_press + 1
	last_x_press = 0 if Input.is_action_just_pressed("x") else last_x_press + 1
	last_c_press = 0 if Input.is_action_just_pressed("c") else last_c_press + 1
	last_shift_press = 0 if Input.is_action_just_pressed("shift") else last_shift_press + 1
	last_z_release = 0 if Input.is_action_just_released("z") else last_z_release + 1
	last_x_release = 0 if Input.is_action_just_released("x") else last_x_release + 1
	last_c_release = 0 if Input.is_action_just_released("c") else last_c_release + 1
	last_shift_release = 0 if Input.is_action_just_released("shift") else last_shift_release + 1
	z_pressed = Input.is_action_pressed("z")
	x_pressed = Input.is_action_pressed("x")
	c_pressed = Input.is_action_pressed("c")
	shift_pressed = Input.is_action_pressed("shift")
	menu_just_pressed = Input.is_action_just_pressed("menu")
	d = Vector2(Input.get_axis("left", "right"), Input.get_axis("down", "up"))
	

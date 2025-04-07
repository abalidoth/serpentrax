extends Node2D
class_name ComboTile


var rotate_tween :Tween
var rotating = false
var locked:bool
@export var tile_position: Vector3i

var number_to_coord : Array = [
	Vector3i(0,-1,1),
	Vector3i(1,-1,0),
	Vector3i(1,0,-1),
	Vector3i(0,1,-1),
	Vector3i(-1,1,0),
	Vector3i(-1,0,1)
]

var input_to_output : Array[int] = [
	1,0,4,5,2,3
]

var number_to_path : Array[Path2D] 

func _ready():
	number_to_path =  [
		%Path01,
		%Path10,
		%Path24,
		%Path35,
		%Path42,
		%Path53
]

func rotate_cw(instant =false) -> void:
	rotating = true
	var temp_pop : Vector3i = number_to_coord.pop_front()
	number_to_coord = number_to_coord + [temp_pop]
	if instant:
		rotation_degrees += 60
		rotating=false
	else:
		rotate_tween = get_tree().create_tween()
		rotate_tween.tween_property(self,"rotation_degrees",rotation_degrees+60,0.2)
		rotate_tween.tween_callback(_on_rotate_tween_finished)
	
func rotate_ccw(instant=false) -> void:
	rotating = true
	var temp_pop : Vector3i = number_to_coord.pop_back()
	number_to_coord =  [temp_pop] + number_to_coord
	if instant:
		rotation_degrees -= 60
		rotating=false
	else:
		rotate_tween = get_tree().create_tween()
		rotate_tween.tween_property(self,"rotation_degrees",rotation_degrees-60,0.2)
		rotate_tween.tween_callback(_on_rotate_tween_finished)

func create_follower(progress:float, entry_point:String) -> void:
	pass

func _input(event):
	pass

func _on_rotate_tween_finished():
	rotating = false
	

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and not rotating and not locked:
		if event.button_index==MOUSE_BUTTON_LEFT:
			print("click left")
			rotate_cw()
		elif event.button_index==MOUSE_BUTTON_RIGHT:
			print("click right")
			rotate_ccw()

func lock():
	locked = true
	var tween = get_tree().create_tween()
	tween.tween_property(self,"modulate",Color(0.8,0.8,0.8),0.3)

func unlock():
	locked = false
	var tween = get_tree().create_tween()
	tween.tween_property(self,"modulate",Color.WHITE,0.3)

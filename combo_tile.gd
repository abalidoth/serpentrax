extends AbstractTile
class_name ComboTile


func _ready():
	number_to_path =  [
		%Path01,
		%Path10,
		%Path24,
		%Path35,
		%Path42,
		%Path53
	]
	input_to_output = [
		1,0,4,5,2,3
	]

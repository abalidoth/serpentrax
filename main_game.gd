extends Node2D

var rng = RandomNumberGenerator.new()

var tile_spacing = 57 #space between tiles, used to determine vectors
var tile_scale = 0.3 #scale of tiles
var tile_radius = 3 #how big the board is

var number_to_coord : Array = [
	Vector3i(0,-1,1),
	Vector3i(1,-1,0),
	Vector3i(1,0,-1),
	Vector3i(0,1,-1),
	Vector3i(-1,1,0),
	Vector3i(-1,0,1)
]

#project from cubic coordinates to cartesian
var project_y = Vector3(1,-0.5,-0.5) * tile_spacing 
var project_x = -Vector3(0,sqrt(3)/2, -sqrt(3)/2) * tile_spacing

var sample_frequency = 0.05 #how smooth the snake moves

var snake_tiles

var growing = false

var tiles: Dictionary = {}
var ComboTileScene = preload("res://combo_tile.tscn")

var HTileScene = preload("res://h_tile.tscn")

var apple_tile : Vector3i

func make_playfield():
	for i in range(-tile_radius, tile_radius+1):
		for j in range(-tile_radius, tile_radius+1):
			var k = -i-j
			if abs(k)<=tile_radius:
				var tile_pos = Vector3i(i,j,k)
				#var new_tile:ComboTile = ComboTileScene.instantiate()
				
				var new_tile:AbstractTile = ComboTileScene.instantiate()
				$Playfield.add_child(new_tile)
				var new_pos = Vector2(
					project_x.dot(tile_pos),
					project_y.dot(tile_pos)
				)
				new_tile.position = new_pos
				new_tile.tile_position = tile_pos
				new_tile.scale = Vector2(tile_scale, tile_scale)
				tiles[tile_pos]=new_tile
				for r in range(rng.randi_range(0,5)):
					new_tile.rotate_cw(true)

func follow_path(prev_tile: Vector3i, this_tile: Vector3i) -> Vector3i:
	#Assuming you leave tile a and enter tile b, what tile do you end up?
	var entry_direction: Vector3i = prev_tile - this_tile
	var this_obj:AbstractTile = tiles[this_tile]
	var entry_point: int = this_obj.number_to_coord.find(entry_direction)
	var exit_point :int = this_obj.input_to_output[entry_point]
	var exit_direction: Vector3i = this_obj.number_to_coord[exit_point]
	return this_tile + exit_direction
	
func get_path_obj(prev_tile: Vector3i, this_tile: Vector3i):
	#assuming you leave tile a and enter tile b, return the path object.
	var entry_direction: Vector3i = prev_tile - this_tile
	var this_obj:AbstractTile = tiles[this_tile]
	var entry_point: int = this_obj.number_to_coord.find(entry_direction)
	return this_obj.number_to_path[entry_point]

	
func init_snake():
	#The snake is always n+2 tiles long -- it's touching n+1
	#and the hex BEFORE the tail is also saved.
	var second_tile = number_to_coord[rng.randi()%6]
	snake_tiles = [Vector3i.ZERO, second_tile]
	snake_tiles.append(follow_path(snake_tiles[0], snake_tiles[1]))
	tiles[snake_tiles[1]].lock()
	tiles[snake_tiles[2]].lock()
	draw_snake()
	
func advance_snake():
	var new_head = follow_path(snake_tiles[-2],snake_tiles[-1])
	if new_head not in tiles:
		game_over()
		return
	snake_tiles.append(new_head)
	if not growing:
		snake_tiles.pop_front()
	growing = (new_head == apple_tile)
	if growing:
		place_apple()
	if snake_tiles.count(snake_tiles[0])==1: #avoid unlocking multiply visited tiles
		tiles[snake_tiles[0]].unlock()
	tiles[snake_tiles[-1]].lock()
	draw_snake()
	
	
func draw_snake():
	var proportion = 1-%SnakeTimer.time_left/%SnakeTimer.wait_time
	var out = []
	var tail_curve = get_path_obj(snake_tiles[0],snake_tiles[1]).curve
	var this_proportion
	if growing:
		this_proportion=0
	else:
		this_proportion = proportion
	while this_proportion < 1:
		var local_point = tail_curve.sample_baked(this_proportion * tail_curve.get_baked_length(), true)
		out.append(tiles[snake_tiles[1]].global_transform * local_point)
		this_proportion += sample_frequency
	for i in range(2,len(snake_tiles)-1):
		this_proportion = 0
		var body_curve = get_path_obj(snake_tiles[i-1],snake_tiles[i]).curve
		while this_proportion < 1:
			var local_point = body_curve.sample_baked(this_proportion * body_curve.get_baked_length(), true)
			out.append(tiles[snake_tiles[i]].global_transform*local_point)
			this_proportion += sample_frequency
	var head_curve  = get_path_obj(snake_tiles[-2],snake_tiles[-1]).curve
	this_proportion = 0
	while this_proportion < proportion:
		var local_point = head_curve.sample_baked(this_proportion * head_curve.get_baked_length(), true)
		out.append(tiles[snake_tiles[-1]].global_transform * local_point)
		this_proportion += sample_frequency
	%SnakeBody.points = out
	
func place_apple():
	var out = []
	for i in tiles:
		if i not in snake_tiles:
			out.append(i)
	apple_tile = out[rng.randi_range(0,len(out)-1)]
	%Apple.position = tiles[apple_tile].global_position
	%Apple.visible = true
	

func _ready():
	make_playfield()
	init_snake()
	place_apple()
	
func _process(delta):
	draw_snake()
				


func _on_snake_timer_timeout():
	advance_snake()

func game_over():
	for i in snake_tiles:
		tiles[i].unlock()
	init_snake()

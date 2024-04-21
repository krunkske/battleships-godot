extends Node

var direction = "HORIZONTAL"
var last_hovered_cell
var current_hovered_cell

func _ready():
	#aLoad.you.global_position = (get_viewport().get_visible_rect().size/2) - Vector2(200,200) + get_viewport().get_visible_rect().size/5
	#aLoad.opponent.global_position = (get_viewport().get_visible_rect().size/2) - Vector2(200,200) - get_viewport().get_visible_rect().size/5
	$AnimationPlayer.play("RESET")


func _process(delta):
	if Input.is_action_just_pressed("LmouseButton"):
		if aLoad.gameloop == "pregame":
			add_boat(aLoad.you.local_to_map(aLoad.you.get_local_mouse_position()))
		elif aLoad.gameloop == "game" and aLoad.user_turn == multiplayer.get_unique_id():
			var place = aLoad.opponent.local_to_map(aLoad.opponent.get_local_mouse_position())
			if $opponent.get_cell_source_id(2, place) == -1:
				if place.x >= 0 and place.x < 10 and place.y >= 0 and place.y < 10:
					guess_boat.rpc(place)
					clear_layer(3, "opponent")
	
	if Input.is_action_just_pressed("RmouseButton") and aLoad.gameloop == "pregame" and aLoad.youReady != true:
		remove_boat(aLoad.you.local_to_map(aLoad.you.get_local_mouse_position()))
	
	if Input.is_action_just_pressed("change_direction"):
		if direction == "HORIZONTAL":
			direction = "VERTICAL"
		else:
			direction = "HORIZONTAL"
		if aLoad.gameloop == "pregame":
			current_hovered_cell = aLoad.you.local_to_map(aLoad.you.get_local_mouse_position())
			last_hovered_cell = current_hovered_cell
			preview(current_hovered_cell, 1)
	
	if aLoad.gameloop == "pregame":
		current_hovered_cell = aLoad.you.local_to_map(aLoad.you.get_local_mouse_position())
		if current_hovered_cell != last_hovered_cell:
			last_hovered_cell = current_hovered_cell
			preview(current_hovered_cell, 1)
	elif aLoad.gameloop == "game" and aLoad.user_turn == multiplayer.get_unique_id():
		current_hovered_cell = aLoad.opponent.local_to_map(aLoad.opponent.get_local_mouse_position())
		if current_hovered_cell.x >= 0 and current_hovered_cell.x < 10 and current_hovered_cell.y >= 0 and current_hovered_cell.y < 10:
			if current_hovered_cell != last_hovered_cell:
				last_hovered_cell = current_hovered_cell
				preview(current_hovered_cell, 2)
		else:
			clear_layer(3, "opponent")
	else:
		pass

func preview(cell, num):
	if num == 1:
		clear_layer(3, "you")
		match aLoad.selected_boat:
			"small":
				small_boat(cell, 3)
			
			"medium":
				medium_boat(cell, 3)
			
			"large":
				large_boat(cell, 3)
			
			"extra_large":
				extra_large_boat(cell, 3)
	elif num == 2:
		clear_layer(3, "opponent")
		$opponent.set_cell(3 , Vector2i(cell.x, cell.y), 1, Vector2i(1,0))

func clear_layer(layer, tilemap):
	if tilemap == "you":
		for kol in range(0,10):
			for row in range(0, 10):
				$you.set_cell(layer, Vector2i(kol, row), -1)
	elif tilemap == "opponent":
		for kol in range(0,10):
			for row in range(0, 10):
				$opponent.set_cell(layer, Vector2i(kol, row), -1)

func add_boat(cell):
	match aLoad.selected_boat:
		"small":
			if not aLoad.boats_placed[0] > 0:
				if small_boat(cell, 1):
					aLoad.boats_placed[0] += 1
					aLoad.boat_select_GUI.set_value("small", 0)
		
		"medium":
			if not aLoad.boats_placed[1] > 1:
				if medium_boat(cell, 1):
					aLoad.boats_placed[1] += 1
					aLoad.boat_select_GUI.set_value("medium", 2 - aLoad.boats_placed[1])
		
		"large":
			if not aLoad.boats_placed[2] > 0:
				if large_boat(cell, 1):
					aLoad.boats_placed[2] += 1
					aLoad.boat_select_GUI.set_value("large", 0)
		
		"extra_large":
			if not aLoad.boats_placed[3] > 0:
				if extra_large_boat(cell, 1):
					aLoad.boats_placed[3] += 1
					aLoad.boat_select_GUI.set_value("extra_large", 0)

func remove_boat(cell):
	var count = 0
	for i in aLoad.boats:
		for j in i:
			if j.x == cell.x and j.y == cell.y:
				for k in i:
					$you.set_cell(1, k, 0, Vector2i(-1, -1))
				aLoad.boats.pop_at(count)
				match len(i):
					2:
						aLoad.boat_select_GUI.set_value("small", 1)
						aLoad.boats_placed[0] -= 1
					3:
						aLoad.boats_placed[1] -= 1
						aLoad.boat_select_GUI.set_value("medium",2 - aLoad.boats_placed[1])
					4:
						aLoad.boat_select_GUI.set_value("large", 1)
						aLoad.boats_placed[2] -= 1
					5:
						aLoad.boat_select_GUI.set_value("extra_large", 1)
						aLoad.boats_placed[3] -= 1
				
		count += 1

func cell_valid(cell):
	if $you.get_cell_source_id(1,cell) == -1 and cell.x >= 0 and cell.x < 10 and cell.y >= 0 and cell.y < 10:
		return true


func place_boat(cell, length, preview):
	var modifer = 0
	var layer = 1
	if preview:
		layer = 3
		
	match length:
		2:
			modifer = 0
		3:
			modifer = -1
		4:
			modifer = -1
		5:
			modifer = -2
	
	var boatCells = []
	
	if direction == "HORIZONTAL":
		for i in length:
			if not cell_valid(Vector2i(cell.x + (i + modifer), cell.y)):
				return false
		
		for i in length:
			if i == 0:
				$you.set_cell(layer, Vector2i(cell.x + (i + modifer), cell.y), 0, Vector2i(0,0))
			elif i == length - 1:
				$you.set_cell(layer, Vector2i(cell.x + (i + modifer), cell.y), 0, Vector2i(2,0))
			else:
				$you.set_cell(layer, Vector2i(cell.x + (i + modifer), cell.y), 0, Vector2i(1,0))
			
			boatCells.append(Vector2i(cell.x + (i + modifer), cell.y))
		
	elif direction == "VERTICAL":
		for i in length:
			if not cell_valid(Vector2i(cell.x, cell.y + (i + modifer))):
				return false
		
		for i in length:
			if i == 0:
				$you.set_cell(layer, Vector2i(cell.x, cell.y + (i + modifer)), 0, Vector2i(0,1))
			elif i == length - 1:
				$you.set_cell(layer, Vector2i(cell.x, cell.y + (i + modifer)), 0, Vector2i(2,1))
			else:
				$you.set_cell(layer, Vector2i(cell.x, cell.y + (i + modifer)), 0, Vector2i(1,1))
			
			boatCells.append(Vector2i(cell.x, cell.y + (i + modifer)))
	if not preview:
		aLoad.boats.append(boatCells)
	
	return true

func small_boat(cell, layer):
	var boatcells = []
	if direction == "HORIZONTAL":
		for i in range(0, 2): #last number not included
			if not cell_valid(Vector2i(cell.x + i, cell.y)):
				return false
			else:
				boatcells.append(Vector2i(cell.x + i, cell.y))
		$you.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(0,0))
		$you.set_cell(layer, Vector2i(cell.x + 1, cell.y), 0, Vector2i(2,0))
	elif direction == "VERTICAL":
		for i in range(0, 2):
			if not cell_valid(Vector2i(cell.x, cell.y + i)):
				return false
			else:
				boatcells.append(Vector2i(cell.x, cell.y + i))
		$you.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(0,1))
		$you.set_cell(layer, Vector2i(cell.x, cell.y + 1), 0, Vector2i(2,1))
	
	if layer == 1:
		aLoad.boats.append(boatcells)
	return true

func medium_boat(cell, layer):
	var boatcells = []
	if direction == "HORIZONTAL":
		for i in range(-1, 2):
			if not cell_valid(Vector2i(cell.x + i, cell.y)):
				return false
			else:
				boatcells.append(Vector2i(cell.x + i, cell.y))
		$you.set_cell(layer, Vector2i(cell.x - 1, cell.y), 0, Vector2i(0,0))
		$you.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,0))
		$you.set_cell(layer, Vector2i(cell.x + 1, cell.y), 0, Vector2i(2,0))
	elif direction == "VERTICAL":
		for i in range(-1, 2):
			if not cell_valid(Vector2i(cell.x, cell.y + i)):
				return false
			else:
				boatcells.append(Vector2i(cell.x, cell.y + i))
		$you.set_cell(layer, Vector2i(cell.x, cell.y - 1), 0, Vector2i(0,1))
		$you.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,1))
		$you.set_cell(layer, Vector2i(cell.x, cell.y + 1), 0, Vector2i(2,1))
	
	if layer == 1:
		aLoad.boats.append(boatcells)
	return true

func large_boat(cell, layer):
	var boatcells = []
	if direction == "HORIZONTAL":
		for i in range(-1, 3):
			if not cell_valid(Vector2i(cell.x + i, cell.y)):
				return false
			else:
				boatcells.append(Vector2i(cell.x + i, cell.y))
		$you.set_cell(layer, Vector2i(cell.x - 1, cell.y), 0, Vector2i(0,0))
		$you.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,0))
		$you.set_cell(layer, Vector2i(cell.x + 1, cell.y), 0, Vector2i(1,0))
		$you.set_cell(layer, Vector2i(cell.x + 2, cell.y), 0, Vector2i(2,0))
	elif direction == "VERTICAL":
		for i in range(-1, 3):
			if not cell_valid(Vector2i(cell.x, cell.y + i)):
				return false
			else:
				boatcells.append(Vector2i(cell.x, cell.y + i))
		$you.set_cell(layer, Vector2i(cell.x, cell.y - 1), 0, Vector2i(0,1))
		$you.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,1))
		$you.set_cell(layer, Vector2i(cell.x, cell.y + 1), 0, Vector2i(1,1))
		$you.set_cell(layer, Vector2i(cell.x, cell.y + 2), 0, Vector2i(2,1))
	
	if layer == 1:
		aLoad.boats.append(boatcells)
	return true

func extra_large_boat(cell, layer):
	var boatcells = []
	if direction == "HORIZONTAL":
		for i in range(-2, 3):
			if not cell_valid(Vector2i(cell.x + i, cell.y)):
				return false
			else:
				boatcells.append(Vector2i(cell.x + i, cell.y))
		$you.set_cell(layer, Vector2i(cell.x - 2, cell.y), 0, Vector2i(0,0))
		$you.set_cell(layer, Vector2i(cell.x - 1, cell.y), 0, Vector2i(1,0))
		$you.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,0))
		$you.set_cell(layer, Vector2i(cell.x + 1, cell.y), 0, Vector2i(1,0))
		$you.set_cell(layer, Vector2i(cell.x + 2, cell.y), 0, Vector2i(2,0))
	elif direction == "VERTICAL":
		for i in range(-2, 3):
			if not cell_valid(Vector2i(cell.x, cell.y + i)):
				return false
			else:
				boatcells.append(Vector2i(cell.x, cell.y + i))
		$you.set_cell(layer, Vector2i(cell.x, cell.y - 2), 0, Vector2i(0,1))
		$you.set_cell(layer, Vector2i(cell.x, cell.y - 1), 0, Vector2i(1,1))
		$you.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,1))
		$you.set_cell(layer, Vector2i(cell.x, cell.y + 1), 0, Vector2i(1,1))
		$you.set_cell(layer, Vector2i(cell.x, cell.y + 2), 0, Vector2i(2,1))
	
	if layer == 1:
		aLoad.boats.append(boatcells)
	return true

@rpc("any_peer", "call_local", "reliable")
func start_pregame():
	aLoad.gameloop = "pregame"
	aLoad.GUI.get_node("boat_select_menu").set_visible(true)
	aLoad.top_gui.get_node("Label").set_text("Place your boats")
	$AnimationPlayer.play("boards_in")
	var sender_id = multiplayer.get_remote_sender_id()
	aLoad.user_turn = sender_id
	print("opponents name is " + aLoad.opponentName)


@rpc("authority", "call_local", "reliable")
func start_game():
	aLoad.gameloop = "game"
	if aLoad.user_turn == multiplayer.get_unique_id():
		aLoad.top_gui.get_node("Label").set_text("It's your turn")
	else:
		aLoad.top_gui.get_node("Label").set_text("It's " + aLoad.opponentName + " turn")
	print("game has started")
	print(aLoad.playerName + " boats")
	print(aLoad.boats)


#TODO this code has to be checked and refactored again. It's a mess
#DONE but still shit and i don't care
@rpc("any_peer", "call_remote", "reliable")
func guess_boat(guess):
	#get sender id first and check if it is the opponents turn and if the cell is withing the grid
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == aLoad.user_turn and guess.x >= 0 and guess.x < 10 and guess.y >= 0 and guess.y < 10:
		aLoad.top_gui.get_node("Label").set_text(aLoad.opponentName + " guessed " + str(guess.x) + ", " + str(guess.y))
	
		var index_1 = 0
		for boats in aLoad.boats:
			var index_2 = 0
			for cell in boats:
				if cell.x == guess.x and cell.y == guess.y:
					hit_or_miss.rpc(true, guess)
					$you.set_cell(2, guess, 1, Vector2i(0, 0))
					aLoad.user_turn = multiplayer.get_unique_id()
					aLoad.boats[index_1].pop_at(index_2)
					#check if the list of cells is empty so we can remove the boat
					if aLoad.boats[index_1] == []:
						aLoad.boats.pop_at(index_1)
					#check if the list of boats is empty to see if the opponent has won
					if aLoad.boats == []:
						win.rpc(sender_id)
					return
				
				index_2 += 1
			
			index_1 += 1
		
		aLoad.user_turn = multiplayer.get_unique_id()
		$you.set_cell(2, guess, 1, Vector2i(1, 0))
		hit_or_miss.rpc(false, guess)


@rpc("any_peer", "call_remote", "reliable")
func hit_or_miss(hit, guess):
	aLoad.user_turn = multiplayer.get_remote_sender_id()
	aLoad.top_gui.get_node("Label").set_text("It's " + aLoad.opponentName + " turn")
	if hit:
		$opponent.set_cell(2, guess, 1, Vector2i(0, 0))
	else:
		if guess.x >= 0 and guess.x < 10 and guess.y >= 0 and guess.y < 10:
			$opponent.set_cell(2, guess, 1, Vector2i(1, 0))

@rpc("any_peer", "call_local", "reliable")
func win(id):
	aLoad.win_gui.win_or_lose(id)
	aLoad.gameloop = "game_over"

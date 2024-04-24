extends Node

var direction = "HORIZONTAL"
var last_hovered_cell
var current_hovered_cell
var current_hovered_board

func _ready():
	#aLoad.you.global_position = (get_viewport().get_visible_rect().size/2) - Vector2(200,200) + get_viewport().get_visible_rect().size/5
	#aLoad.opponent.global_position = (get_viewport().get_visible_rect().size/2) - Vector2(200,200) - get_viewport().get_visible_rect().size/5
	for i in range(1, 5):
		self.get_node("AnimationPlayer" + str(i)).play("RESET")
	current_hovered_board = $board1


func _process(delta):
	if aLoad.gameloop == "pregame":
		preview(aLoad.yourTilemap.local_to_map(aLoad.yourTilemap.get_local_mouse_position()), 1)
		
		if Input.is_action_just_pressed("LmouseButton"):
			add_boat(aLoad.yourTilemap.local_to_map(aLoad.yourTilemap.get_local_mouse_position()))
		elif Input.is_action_just_pressed("RmouseButton"):
			remove_boat(aLoad.yourTilemap.local_to_map(aLoad.yourTilemap.get_local_mouse_position()))
	
	elif aLoad.gameloop == "game" and aLoad.user_turn == multiplayer.get_unique_id():
		if Input.is_action_just_pressed("LmouseButton"):
			var place = current_hovered_board.local_to_map(current_hovered_board.get_local_mouse_position())
			if current_hovered_board.get_cell_source_id(2, place) == -1:
				if place.x >= 0 and place.x < 10 and place.y >= 0 and place.y < 10:
					guess_boat.rpc_id(get_list_from_board(current_hovered_board)[1], place)
					clear_layer(3, "opponent")
		
		if current_hovered_board != aLoad.yourTilemap:
			current_hovered_cell = current_hovered_board.local_to_map(current_hovered_board.get_local_mouse_position())
			if cell_within_bounds(current_hovered_cell):
				if current_hovered_cell != last_hovered_cell:
					last_hovered_cell = current_hovered_cell
					clear_layer(3, "opponent")
					current_hovered_board.set_cell(3 , Vector2i(current_hovered_cell.x, current_hovered_cell .y), 1, Vector2i(1,0))
			else:
				clear_layer(3, "opponent")
	
	if Input.is_action_just_pressed("change_direction"):
		if direction == "HORIZONTAL":
			direction = "VERTICAL"
		else:
			direction = "HORIZONTAL"
		if aLoad.gameloop == "pregame":
			current_hovered_cell = aLoad.yourTilemap.local_to_map(aLoad.yourTilemap.get_local_mouse_position())
			last_hovered_cell = current_hovered_cell
			preview(current_hovered_cell, 1)

func preview(cell, num):

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

func clear_layer(layer, tilemap):
	if tilemap == "you":
		for kol in range(0,10):
			for row in range(0, 10):
				aLoad.yourTilemap.set_cell(layer, Vector2i(kol, row), -1)
	elif tilemap == "opponent":
		for kol in range(0,10):
			for row in range(0, 10):
				current_hovered_board.set_cell(layer, Vector2i(kol, row), -1)

func clear_all_layers():
	for user in aLoad.players:
		for kol in range(0,10):
			for row in range(0, 10):
				user[2].set_cell(1, Vector2i(kol, row), -1)
				user[2].set_cell(2, Vector2i(kol, row), -1)

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
					aLoad.yourTilemap.set_cell(1, k, 0, Vector2i(-1, -1))
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
	if aLoad.yourTilemap.get_cell_source_id(1,cell) == -1 and cell_within_bounds(cell):
		return true

func cell_within_bounds(cell):
	if cell.x >= 0 and cell.x < 10 and cell.y >= 0 and cell.y < 10:
		return true
#deprecated
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
				aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x + (i + modifer), cell.y), 0, Vector2i(0,0))
			elif i == length - 1:
				aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x + (i + modifer), cell.y), 0, Vector2i(2,0))
			else:
				aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x + (i + modifer), cell.y), 0, Vector2i(1,0))
			
			boatCells.append(Vector2i(cell.x + (i + modifer), cell.y))
		
	elif direction == "VERTICAL":
		for i in length:
			if not cell_valid(Vector2i(cell.x, cell.y + (i + modifer))):
				return false
		
		for i in length:
			if i == 0:
				aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y + (i + modifer)), 0, Vector2i(0,1))
			elif i == length - 1:
				aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y + (i + modifer)), 0, Vector2i(2,1))
			else:
				aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y + (i + modifer)), 0, Vector2i(1,1))
			
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
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(0,0))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x + 1, cell.y), 0, Vector2i(2,0))
	elif direction == "VERTICAL":
		for i in range(0, 2):
			if not cell_valid(Vector2i(cell.x, cell.y + i)):
				return false
			else:
				boatcells.append(Vector2i(cell.x, cell.y + i))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(0,1))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y + 1), 0, Vector2i(2,1))
	
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
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x - 1, cell.y), 0, Vector2i(0,0))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,0))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x + 1, cell.y), 0, Vector2i(2,0))
	elif direction == "VERTICAL":
		for i in range(-1, 2):
			if not cell_valid(Vector2i(cell.x, cell.y + i)):
				return false
			else:
				boatcells.append(Vector2i(cell.x, cell.y + i))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y - 1), 0, Vector2i(0,1))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,1))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y + 1), 0, Vector2i(2,1))
	
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
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x - 1, cell.y), 0, Vector2i(0,0))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,0))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x + 1, cell.y), 0, Vector2i(1,0))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x + 2, cell.y), 0, Vector2i(2,0))
	elif direction == "VERTICAL":
		for i in range(-1, 3):
			if not cell_valid(Vector2i(cell.x, cell.y + i)):
				return false
			else:
				boatcells.append(Vector2i(cell.x, cell.y + i))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y - 1), 0, Vector2i(0,1))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,1))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y + 1), 0, Vector2i(1,1))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y + 2), 0, Vector2i(2,1))
	
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
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x - 2, cell.y), 0, Vector2i(0,0))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x - 1, cell.y), 0, Vector2i(1,0))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,0))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x + 1, cell.y), 0, Vector2i(1,0))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x + 2, cell.y), 0, Vector2i(2,0))
	elif direction == "VERTICAL":
		for i in range(-2, 3):
			if not cell_valid(Vector2i(cell.x, cell.y + i)):
				return false
			else:
				boatcells.append(Vector2i(cell.x, cell.y + i))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y - 2), 0, Vector2i(0,1))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y - 1), 0, Vector2i(1,1))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y), 0, Vector2i(1,1))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y + 1), 0, Vector2i(1,1))
		aLoad.yourTilemap.set_cell(layer, Vector2i(cell.x, cell.y + 2), 0, Vector2i(2,1))
	
	if layer == 1:
		aLoad.boats.append(boatcells)
	return true

func get_list_from_id(id):
	for i in aLoad.players:
		if i[1] == id:
			return i

func get_list_from_board(board):
	for i in aLoad.players:
		if i[2] == board:
			return i

@rpc("authority", "call_local", "reliable")
func start_pregame():
	aLoad.gameloop = "pregame"
	aLoad.GUI.get_node("boat_select_menu").set_visible(true)
	aLoad.top_gui.get_node("Label").set_text("Place your boats")
	for i in len(aLoad.players):
		aLoad.players[i][2] = aLoad.boards[i]
		if aLoad.players[i][1] == multiplayer.get_unique_id():
			aLoad.yourPosition = i
	aLoad.yourTilemap = aLoad.players[aLoad.yourPosition][2]
	
	for i in len(aLoad.players):
		print("played board" + str(i+1) + "_in")
		self.get_node("AnimationPlayer" + str(i+1)).play("board_in")
	
	print("playerList " + str(multiplayer.get_unique_id()) + " : " + str(aLoad.players))


@rpc("authority", "call_local", "reliable")
func start_game():
	aLoad.user_turn = 1
	aLoad.gameloop = "game"
	ready_all()
	if aLoad.user_turn == multiplayer.get_unique_id():
		aLoad.top_gui.get_node("Label").set_text("It's your turn")
	else:
		aLoad.top_gui.get_node("Label").set_text("It's turn")

func ready_all():
	for i in len(aLoad.players):
		aLoad.players[i][3] = true

func next_user_turn(id):
	var valid_players = []
	for i in aLoad.players:
		if i[3]:
			valid_players.append(i)
	
	print(str(multiplayer.get_unique_id()) + str(valid_players))
	
	var next = false
	for i in valid_players:
		if next:
			print(i[1])
			return i[1]
		if i[1] == id and i[3]:
			next = true

	return aLoad.players[0][1]

#TODO this code has to be checked and refactored again. It's a mess
#DONE but still shit and i don't care
@rpc("any_peer", "call_remote", "reliable")
func guess_boat(guess):
	#get sender id first and check if it is the opponents turn and if the cell is withing the grid
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == aLoad.user_turn and guess.x >= 0 and guess.x < 10 and guess.y >= 0 and guess.y < 10:
		aLoad.top_gui.get_node("Label").set_text(" guessed " + str(guess.x) + ", " + str(guess.y))
	
		var index_1 = 0
		for boats in aLoad.boats:
			var index_2 = 0
			for cell in boats:
				if cell.x == guess.x and cell.y == guess.y:
					hit_or_miss.rpc(true, guess, multiplayer.get_remote_sender_id())
					aLoad.yourTilemap.set_cell(2, guess, 1, Vector2i(0, 0))
					aLoad.user_turn = next_user_turn(multiplayer.get_remote_sender_id())
					if aLoad.user_turn == multiplayer.get_unique_id():
						aLoad.top_gui.get_node("Label").set_text("It's your turn")
					aLoad.boats[index_1].pop_at(index_2)
					#check if the list of cells is empty so we can remove the boat
					if aLoad.boats[index_1] == []:
						aLoad.boats.pop_at(index_1)
					#check if the list of boats is empty to see if the opponent has won
					if aLoad.boats == []:
						player_out.rpc(aLoad.yourPosition)
					return
				
				index_2 += 1
			
			index_1 += 1
		
		aLoad.yourTilemap.set_cell(2, guess, 1, Vector2i(1, 0))
		hit_or_miss.rpc(false, guess, multiplayer.get_remote_sender_id())
		aLoad.user_turn = next_user_turn(multiplayer.get_remote_sender_id())
		if aLoad.user_turn == multiplayer.get_unique_id():
			aLoad.top_gui.get_node("Label").set_text("It's your turn")


@rpc("any_peer", "call_remote", "reliable")
func hit_or_miss(hit, guess, guesser):
	var sender = get_list_from_id(multiplayer.get_remote_sender_id())
	aLoad.user_turn = next_user_turn(guesser)
	
	if hit:
		sender[2].set_cell(2, guess, 1, Vector2i(0, 0))
	else:
		if guess.x >= 0 and guess.x < 10 and guess.y >= 0 and guess.y < 10:
			sender[2].set_cell(2, guess, 1, Vector2i(1, 0))
	
	if aLoad.user_turn == multiplayer.get_unique_id():
		aLoad.top_gui.get_node("Label").set_text("It's your turn")
	else:
		aLoad.top_gui.get_node("Label").set_text(" guessed " + str(guess.x) + ", " + str(guess.y))


@rpc("any_peer", "call_local", "reliable")
func win(id):
	aLoad.win_gui.win_or_lose(id)
	aLoad.gameloop = "game_over"

@rpc("any_peer", "call_local", "reliable")
func player_out(pos):
	aLoad.players[pos][3] = false
	var count = 0
	var winning_player_id = 0
	for i in aLoad.players:
		if count > 1:
			return
		if i[3]:
			count += 1
			winning_player_id = i[1]
	win.rpc(winning_player_id)

func mouse_board_1():
	if len(aLoad.players) >= 1:
		current_hovered_board = aLoad.board1

func mouse_board_2():
	if len(aLoad.players) >= 2:
		current_hovered_board = aLoad.board2

func mouse_board_3():
	if len(aLoad.players) >= 3:
		current_hovered_board = aLoad.board3

func mouse_board_4():
	if len(aLoad.players) >= 4:
		current_hovered_board = aLoad.board4

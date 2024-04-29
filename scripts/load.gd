extends Node

@onready var main = get_tree().root.get_node("main")
@onready var GUI = main.get_node("GUI")
@onready var top_gui = GUI.get_node("top_gui")
@onready var top_container_box = top_gui.get_node("VBoxContainer")
@onready var boat_select_GUI = GUI.get_node("boat_select_menu")
@onready var win_gui = GUI.get_node("win_GUI")
@onready var lobby_UI = GUI.get_node("lobby_UI")
@onready var board1 = main.get_node("board1")
@onready var board2 = main.get_node("board2")
@onready var board3 = main.get_node("board3")
@onready var board4 = main.get_node("board4")

@onready var usernameNode1 = board1.get_node("username")
@onready var usernameNode2 = board2.get_node("username")
@onready var usernameNode3 = board3.get_node("username")
@onready var usernameNode4 = board4.get_node("username")

@onready var selected_boat = "small"

@onready var boats_placed = [0,0,0,0] #from 2 to 5, left to right
@onready var boats = []

@onready var gameloop = "main_menu"

@onready var user_turn = 1

@onready var players = []

@onready var yourPosition = -1
@onready var yourTilemap = null
@onready var authorized = 1

@onready var boards = [board1, board2, board3, board4] #deprecated but still used, preferably use player_dict

@onready var usernamesNodes = [usernameNode1, usernameNode2, usernameNode3, usernameNode4]
#only for server
@onready var headless = false

@onready var player_boats = [
	{"id": 0, "boats": []},
	{"id": 0, "boats": []},
	{"id": 0, "boats": []},
	{"id": 0, "boats": []},
]

func reset():
	
	main.clear_all_layers()
	
	multiplayer.multiplayer_peer = null
	selected_boat = "small"
	boats_placed = [0,0,0,0]
	boats = []
	gameloop = "main_menu"
	user_turn = 1
	players = []
	yourPosition = -1
	yourTilemap = null
	boards = [board1, board2, board3, board4]
	
	player_boats = [
	{"id": 0, "boats": []},
	{"id": 0, "boats": []},
	{"id": 0, "boats": []},
	{"id": 0, "boats": []},
]
	
	lobby_UI.set_visible(true)
	lobby_UI.tween.kill()
	lobby_UI.get_node("Panel").scale = Vector2(1,1)
	top_gui.get_node("host_or_client").text = ""
	top_container_box.get_node("Label").text = ""
	
	
	boat_select_GUI.set_visible(false)
	boat_select_GUI.set_value("small", 1)
	boat_select_GUI.set_value("medium", 2)
	boat_select_GUI.set_value("large", 1)
	boat_select_GUI.set_value("extra_large", 1)

extends Node

@onready var main = get_tree().root.get_node("main")
@onready var GUI = main.get_node("GUI")
@onready var top_gui = GUI.get_node("top_gui")
@onready var boat_select_GUI = GUI.get_node("boat_select_menu")
@onready var win_gui = GUI.get_node("win_GUI")
@onready var lobby_UI = GUI.get_node("lobby_UI")
@onready var board1 = main.get_node("board1")
@onready var board2 = main.get_node("board2")
@onready var board3 = main.get_node("board3")
@onready var board4 = main.get_node("board4")

@onready var selected_boat = "small"

@onready var boats_placed = [0,0,0,0] #from 2 to 5, left to right
@onready var boats = []

@onready var gameloop = "main_menu"

@onready var user_turn = 1

@onready var players = [] #[name, id, board, ready]
@onready var yourPosition = -1
@onready var yourTilemap = null

@onready var boards = [board1, board2, board3, board4]

func reset():
	multiplayer.multiplayer_peer = null
	gameloop = "main_menu"
	boats_placed = [0,0,0,0]
	boats = []
	user_turn = 1
	selected_boat = "small"
	
	main.get_node("AnimationPlayer").play("RESET")
	lobby_UI.set_visible(true)
	top_gui.get_node("host_or_client").text = ""
	top_gui.get_node("Label").text = ""
	
	main.clear_layer(1, "you")
	main.clear_layer(2, "you")
	main.clear_layer(2, "opponent")
	
	boat_select_GUI.set_visible(false)
	boat_select_GUI.set_value("small", 1)
	boat_select_GUI.set_value("medium", 2)
	boat_select_GUI.set_value("large", 1)
	boat_select_GUI.set_value("extra_large", 1)

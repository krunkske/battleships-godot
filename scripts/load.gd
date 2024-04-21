extends Node

@onready var main = get_tree().root.get_node("main")
@onready var GUI = main.get_node("GUI")
@onready var top_gui = GUI.get_node("top_gui")
@onready var boat_select_GUI = GUI.get_node("boat_select_menu")
@onready var win_gui = GUI.get_node("win_GUI")
@onready var lobby_UI = GUI.get_node("lobby_UI")
@onready var you = main.get_node("you")
@onready var opponent = main.get_node("opponent")

@onready var selected_boat = "small"

@onready var boats_placed = [0,0,0,0] #from 2 to 5, left to right
@onready var boats = []

@onready var youReady = false
@onready var opponentReady = false

@onready var gameloop = "main_menu"

@onready var user_turn = 1

@onready var playerName = "Player 1"
@onready var opponentName = ""


func reset():
	gameloop = "main_menu"
	boats_placed = [0,0,0,0]
	boats = []
	youReady = false
	opponentReady = false
	playerName = "Player 1"
	opponentName = ""
	user_turn = 1
	selected_boat = "small"
	
	main.get_node("AnimationPlayer").play("RESET")
	lobby_UI.set_visible(true)
	top_gui.get_node("host_or_client").text = ""
	top_gui.get_node("Label").text = ""
	
	Lobby.terminate()
	main.clear_layer(1, "you")
	main.clear_layer(2, "you")
	main.clear_layer(2, "opponent")
	
	boat_select_GUI.set_value("small", 1)
	boat_select_GUI.set_value("medium", 2)
	boat_select_GUI.set_value("large", 1)
	boat_select_GUI.set_value("extra_large", 1)

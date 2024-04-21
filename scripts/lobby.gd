extends Node

var PORT = 1026
const MAX_CLIENTS = 1
var client = false

var peer = null

func _ready():
	multiplayer.peer_connected.connect(self._player_connected)
	multiplayer.peer_disconnected.connect(self._player_disconnected)
	#multiplayer.connected_to_server.connect(self._connected_ok)
	multiplayer.connection_failed.connect(self._connected_fail)
	multiplayer.server_disconnected.connect(self._server_disconnected)

func terminate():
	multiplayer.multiplayer_peer = null

func create_client(ip_address):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, int(PORT))
	multiplayer.multiplayer_peer = peer
	aLoad.top_gui.get_node("host_or_client").set_text("client")
	aLoad.top_gui.get_node("Label").set_text("Waiting for Host.")

func create_server():
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(int(PORT), MAX_CLIENTS)
	if err != OK:
		print("could not create server. Restart your game please.")
		aLoad.top_gui.get_node("Label").set_text("could not create server. Restart your game please.")
		aLoad.top_gui.get_node("host_or_client").set_text("host")
		return
	multiplayer.multiplayer_peer = peer
	aLoad.top_gui.get_node("host_or_client").set_text("host")
	aLoad.top_gui.get_node("Label").set_text("Waiting for opponent.")

func _player_connected(_id):
	print(str(_id) + " connected")
	_register_player.rpc_id(_id, aLoad.playerName)
	if multiplayer.is_server():
		aLoad.main.start_pregame.rpc()

func _player_disconnected(_id):
	print(str(_id) + " disconnected")

func _connected_fail():
	print("connection failed.")
	multiplayer.multiplayer_peer = null

func _server_disconnected():
	print("server disconnected.")
	multiplayer.multiplayer_peer = null

@rpc("any_peer", "reliable")
func _register_player(username):
	aLoad.opponentName = username


func player_is_ready():
	aLoad.youReady = true
	if aLoad.opponentReady:
		aLoad.main.start_game.rpc()

@rpc("any_peer", "reliable")
func opponent_is_ready():
	aLoad.opponentReady = true
	if aLoad.youReady:
		aLoad.main.start_game.rpc()

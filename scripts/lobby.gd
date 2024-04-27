extends Node

var PORT = 1026
const MAX_CLIENTS = 3

var peer = null

var connected = 0

#only needed for clients
var playerName = "Player"


func _ready():
	multiplayer.peer_connected.connect(self._player_connected)
	multiplayer.peer_disconnected.connect(self._player_disconnected)
	multiplayer.connected_to_server.connect(self._connected_ok)
	multiplayer.connection_failed.connect(self._connected_fail)
	multiplayer.server_disconnected.connect(self._server_disconnected)


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
		return
	
	multiplayer.multiplayer_peer = peer
	aLoad.top_gui.get_node("host_or_client").set_text("host")
	aLoad.top_gui.get_node("Label").set_text("Waiting for opponent.")

func _player_connected(_id):
	if not _id == 1:
		print(str(_id) + " connected from " + str(multiplayer.get_unique_id()))
	if multiplayer.is_server():
		connected += 1

func _connected_ok():
	_register_player.rpc(playerName)
	print("sucessfully connected to server")

func _connected_fail():
	print("connection failed.")
	multiplayer.multiplayer_peer = null
	aLoad.reset()

func _player_disconnected(_id):
	print(str(_id) + " disconnected")
	connected -= 1

func _server_disconnected():
	print("server disconnected.")
	multiplayer.multiplayer_peer = null
	aLoad.reset()

#registers a new player and adds it to the ist of players
#called on every client except sender
@rpc("any_peer", "call_remote", "reliable")
func _register_player(username):
	aLoad.players.append([username, multiplayer.get_remote_sender_id(), null, false])
	if multiplayer.is_server():
		recieve_players.rpc(aLoad.players)
	print("playerList " + str(multiplayer.get_unique_id()) + " : " + str(aLoad.players))

#gets response back from server to add all of the existing players to the players array
@rpc("authority", "call_remote", "reliable")
func recieve_players(users):
	aLoad.players = users
	var i = 0
	for user in users:
		if user[1] == multiplayer.get_unique_id():
			aLoad.yourPosition = i
			return
		i += 1
	print("playerList " + str(multiplayer.get_unique_id()) + " : " + str(aLoad.players))

@rpc("any_peer", "call_remote", "reliable")
func is_ready(index):
	aLoad.players[index][3] = true
	for i in len(aLoad.players):
		if not aLoad.players[i][3]:
			return
	aLoad.main.start_game.rpc()

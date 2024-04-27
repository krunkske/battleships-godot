extends Node

#the ENTIRE infrastructure has to be changed from peer to peer to server
#good luck!

var PORT = 8080
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
	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_client(str(ip_address))
	if err != OK:
		print(err)
	multiplayer.multiplayer_peer = peer
	aLoad.top_gui.get_node("host_or_client").set_text("client")
	aLoad.top_gui.get_node("Label").set_text("Waiting for Host.")


func create_server(Name):
	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_server(int(PORT))
	if err != OK:
		print("could not create server. Restart your game please.")
		aLoad.top_gui.get_node("Label").set_text("could not create server. Restart your game please.")
		return
	
	if not aLoad.headless:
		aLoad.players.append({"name": Name, "id": 1, "board": aLoad.board1, "ready": false})
		aLoad.yourPosition = 0
		connected += 1
		
		aLoad.top_gui.get_node("host_or_client").set_text("host")
		aLoad.top_gui.get_node("Label").set_text("Waiting for opponents.")
	
	multiplayer.multiplayer_peer = peer
	

func _player_connected(_id):
	if not _id == 1:
		print(str(_id) + " connected from " + str(multiplayer.get_unique_id()))
	if multiplayer.is_server():
		connected += 1

func _connected_ok():
	_register_player.rpc_id(1, playerName)
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
	aLoad.players.append({"name": username, "id": multiplayer.get_remote_sender_id(), "board": null, "ready": false})
	if multiplayer.is_server():
		if connected == 1 and aLoad.headless:
			aLoad.authorized = multiplayer.get_remote_sender_id()
			recieve_players.rpc(aLoad.players, true)
		else:
			recieve_players.rpc(aLoad.players, false)
	print("playerList " + str(multiplayer.get_unique_id()) + " : " + str(aLoad.players))

#gets response back from server to add all of the existing players to the players array
@rpc("authority", "call_remote", "reliable")
func recieve_players(users, authorized):
	if authorized:
		aLoad.authorized = true
	aLoad.players = users
	var i = 0
	for user in users:
		if user.id == multiplayer.get_unique_id():
			aLoad.yourPosition = i
			return
		i += 1
	print("playerList " + str(multiplayer.get_unique_id()) + " : " + str(aLoad.players))

@rpc("any_peer", "call_remote", "reliable")
func is_ready(index, boats):
	var id = multiplayer.get_remote_sender_id()
	if id == 0:
		id = 1
	aLoad.players[index].ready = true
	aLoad.player_boats[index] = {"id": id, "boats": boats}
	for i in len(aLoad.players):
		if not aLoad.players[i].ready:
			return
	aLoad.main.start_game.rpc()

@rpc("any_peer", "call_remote", "reliable")
func is_authorized():
	if multiplayer.get_remote_sender_id() == aLoad.authorized or multiplayer.get_remote_sender_id() == 1:
		aLoad.main.start_pregame.rpc()

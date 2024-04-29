extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/start.set_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_pressed():
	if multiplayer.is_server():
		aLoad.authorized = 1
		Lobby.is_authorized()
		$VBoxContainer/start.set_visible(false)
		print("attempted start pregame")
	elif aLoad.authorized:
		Lobby.is_authorized.rpc_id(1)
		$VBoxContainer/start.set_visible(false)

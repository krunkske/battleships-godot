extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_pressed():
	if multiplayer.is_server():
		aLoad.authorized = 1
		Lobby.is_authorized()
		self.set_visible(false)
	elif aLoad.authorized:
		Lobby.is_authorized.rpc_id(1)
		self.set_visible(false)

extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_pressed():
	aLoad.playerName = $Panel/VBoxContainer/HBoxContainer2/name.get_text()
	Lobby.PORT = $Panel/VBoxContainer/HBoxContainer4/port.text
	Lobby.create_server()
	self.set_visible(false)


func _on_join_pressed():
	if $"Panel/VBoxContainer/HBoxContainer2/ip-adress".get_text().is_valid_ip_address():
		aLoad.playerName = $Panel/VBoxContainer/HBoxContainer2/name.get_text()
		$Panel/VBoxContainer/HBoxContainer4/port.text
		if aLoad.playerName == "Player 1":
			aLoad.playerName = "Player 2"
		Lobby.create_client($"Panel/VBoxContainer/HBoxContainer2/ip-adress".get_text())
		self.set_visible(false)


func _on_port_toggled(toggled_on):
	$Panel/VBoxContainer/HBoxContainer4/port.set_editable(toggled_on)
	if not toggled_on:
		$Panel/VBoxContainer/HBoxContainer4/port.text = "1026"

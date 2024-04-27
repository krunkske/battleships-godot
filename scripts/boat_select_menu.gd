extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_visible(false)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_small_boat_pressed():
	aLoad.selected_boat = "small"

func _on_medium_boat_pressed():
	aLoad.selected_boat = "medium"

func _on_large_boat_pressed():
	aLoad.selected_boat = "large"

func _on_extra_large_boat_pressed():
	aLoad.selected_boat = "extra_large"

func _on_ready_pressed():
	if aLoad.boats_placed == [1,2,1,1]:
		self.set_visible(false)
		aLoad.top_gui.get_node("Label").set_text("Waiting for opponents")
		if not multiplayer.is_server():
			Lobby.is_ready.rpc_id(1, aLoad.yourPosition, aLoad.boats)
		else:
			Lobby.is_ready(aLoad.yourPosition, aLoad.boats)
	else:
		aLoad.top_gui.get_node("Label").set_text("You have not placed all your boats")

func set_value(textBox, value):
	match textBox:
		"small":
			$GridContainer/HBoxContainer/small_amount.text = str(value)
		"medium":
			$GridContainer/HBoxContainer2/medium_amount.text = str(value)
		"large":
			$GridContainer/HBoxContainer3/large_amount.text = str(value)
		"extra_large":
			$GridContainer/HBoxContainer4/extra_large_amount.text = str(value)

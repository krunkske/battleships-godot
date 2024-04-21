extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	aLoad.reset()
	self.set_visible(false)

func win_or_lose(id):
	self.set_visible(true)
	if id == multiplayer.get_unique_id():
		$VBoxContainer/Label.text = "You win!"
	else:
		$VBoxContainer/Label.text = "You lose!"

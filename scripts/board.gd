extends TileMap

@export var user_icon_left = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$username.scale = Vector2(0.8,0.8)
	$user_icon.scale = Vector2(0.8,0.8)
	
	var tile = Vector2i(0,0)
	if user_icon_left:
		$user_icon.position = Vector2(-45, 0)
		$username.position = Vector2(-45, 45)
	
	$username.set_self_modulate(Color(1, 1, 1, 0.5))
	$user_icon.set_self_modulate(Color(1, 1, 1, 0.5))
	
	match name:
		"board1":
			tile = Vector2i(0,0)
		"board2":
			tile = Vector2i(1,0)
		"board3":
			tile = Vector2i(0,1)
		"board4":
			tile = Vector2i(1,1)
	
	
	for i in range(0, 10):
		for j in range(0, 10):
			set_cell(0, Vector2i(i, j), 4, tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fade_in():
	var tweenNameFade = get_tree().create_tween()
	var tweenNameScale = get_tree().create_tween()
	var tweenIconFade = get_tree().create_tween()
	var tweenIconScale = get_tree().create_tween()
	tweenNameFade.set_trans(Tween.TRANS_LINEAR)
	tweenNameScale.set_trans(Tween.TRANS_SPRING)
	tweenIconFade.set_trans(Tween.TRANS_SPRING)
	tweenIconScale.set_trans(Tween.TRANS_SPRING)
	tweenNameFade.tween_property($username, "self_modulate", Color(1, 1, 1, 1), 0.25)
	tweenNameScale.tween_property($username, "scale", Vector2(1,1), 0.25)
	tweenIconFade.tween_property($user_icon, "self_modulate", Color(1, 1, 1, 1), 0.25)
	tweenIconScale.tween_property($user_icon, "scale", Vector2(1,1), 0.25)

func _on_area_2d_mouse_entered() -> void:
	aLoad.main.set_hovered_board(name)

extends CheckBox



# Called when the node enters the scene tree for the first time.
func _ready():
	button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func reapply_window_mode():
	DisplayServer.window_set_mode(DisplayServer.window_get_mode())

func _on_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

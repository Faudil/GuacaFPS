extends Control
@onready var color_rect = $ColorRect
@onready var hitmarker = $Hitmarker


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var size = DisplayServer.window_get_size()
	color_rect.set_position(Vector2(size.x / 2 - 2, size.y / 2 - 2))
	hitmarker.set_position(Vector2(size.x / 2 - 10, size.y / 2 - 10))

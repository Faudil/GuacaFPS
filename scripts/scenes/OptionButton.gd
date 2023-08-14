extends OptionButton

@onready var check_box = $"../../FullscreenRow/CheckBox"

@export var screen_size_list = [
	Vector2i(3840, 2160),
	Vector2i(2560, 1440),
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1280, 720),
	Vector2i(1024, 546),
]

# Called when the node enters the scene tree for the first time.
func _ready():
	var windows_size = get_window().size
	add_item("%dx%d" % [windows_size.x, windows_size.y])
	for screen_size in screen_size_list:
		add_item("%dx%d" % [screen_size.x, screen_size.y])
	screen_size_list = [windows_size] + screen_size_list

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_item_selected(index: int):
	get_window().size = screen_size_list[index]
	check_box.reapply_window_mode()

extends VBoxContainer
@onready var line_edit = $LineEdit
@onready var color_picker = $ColorPicker


var player_info: PlayerInfo = PlayerInfo.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_player_info() -> PlayerInfo:
	return player_info


func _on_color_picker_color_changed(color: Color):
	player_info.set_avatar_color(color.to_html(false))

func _on_line_edit_text_changed(new_text: String):
	print(new_text)
	player_info.set_pseudo(new_text)

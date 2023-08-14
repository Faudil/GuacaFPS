extends VBoxContainer

@onready var audio_slider = $AudioSlider

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), audio_slider.value)

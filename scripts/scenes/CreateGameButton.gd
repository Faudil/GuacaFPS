extends Button

@onready var player = $"../../Player"
@onready var max_players = $"../MaxPlayers"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_lobby():
	# Hide MainMenu UI
	$"../../../..".visible = false
	# Remove old lobby if any.
	var level = $"../../../../../Lobby"
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	var scene = load("res://scenes/lobby.tscn")
	# Add new level.
	var instanciated_scene = scene.instantiate()
	level.add_child(instanciated_scene)
	instanciated_scene.init_as_host(player.get_player_info(), max_players.value)

func _on_pressed():
	print("Host Game: ", player.get_player_info().serialize())
	create_lobby()

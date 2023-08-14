extends Button

@onready var player = $"../../Player"


func _on_pressed():
	print("Join Game: ", player.get_player_info().serialize())
	create_lobby()
	
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
	var host = $"../../JoinGameBox/HostIPAdressLineEdit".text
	instanciated_scene.init_as_client(player.get_player_info(), host)

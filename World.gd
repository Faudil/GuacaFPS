extends Node3D

const SPAWN_RANDOM := 5.0

var connected_players = []

func _ready():
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		print("Not multiplayer server")
		return
	else:
		print('Is multiplayer server')

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players
	#for id in multiplayer.get_peers():
	#	print("Add player", id)
	#	if id in connected_players:
	#		print("NOOOOOOOOOO")
	#	else:
	#		connected_players.append(id)
			# add_player(id)
	print("Lobby setup")
	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	var character = preload("res://player.tscn").instantiate()
	# Set player id.
	character.player = id
	# Randomize character position.
	var pos := Vector2.from_angle(randf() * 2 * PI)
	character.position = Vector3(pos.x * SPAWN_RANDOM * randf(), 0, pos.y * SPAWN_RANDOM * randf())
	character.name = str(id)
	$SpawnPoint.add_child(character, true)


func del_player(id: int):
	if not $SpawnPoint.has_node(str(id)):
		return
	$SpawnPoint.get_node(str(id)).queue_free()


# Typical lobby implementation; imagine this being in /root/lobby.

extends Node

func _ready():
# Called when the node enters the scene tree for the first time.
	get_tree().network_peer_connected.connect(_player_connected)
	get_tree().network_peer_disconnected.connect(_player_disconnected)
	get_tree().connected_to_server.connect(_connected_ok)
	get_tree().connection_failed.connect(_connected_fail)
	get_tree().server_disconnected.connect(_server_disconnected)

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	print("New connection", id)
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	print("WTF")
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

@rpc
func register_player(info):
	print("New player connected", info)
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc
func pre_configure_game():
	var selfPeerID = get_tree().get_network_unique_id()
	print("preconfigure_game ", selfPeerID)

	# Load world
	var world = load("res://").instantiate()
	get_node("/root").add_child(world)

	# Load my player
	var my_player = preload("res://player.tscn").instantiate()
	my_player.set_name(str(selfPeerID))
	my_player.set_multiplayer_authority(selfPeerID) # Will be explained later
	get_node("/root/world/players").add_child(my_player)

	# Load other players
	for p in player_info:
		var player = preload("res://player.tscn").instantiate()
		player.set_name(str(p))
		player.set_multiplayer_authority(p)
		get_node("/root/world/players").add_child(player)

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	rpc_id(1, "done_preconfiguring")

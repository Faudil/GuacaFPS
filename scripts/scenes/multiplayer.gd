# multiplayer.gd
extends Node

const PORT = 4433
var enet = ENetMultiplayerPeer.new()
var external_ip_adress = "Setting up upnp"
var game_started = false

var player_info_list = []
var _player_info: PlayerInfo

@onready var start_game_button = $UI/Net/StartGameButton

func _ready():
	# get_tree().paused = true
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false

	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		init_as_host.call_deferred()

func init_as_host(player_info: PlayerInfo, max_players: int, dedicated_server: bool=false):
	_player_info = player_info
	var pl = player_info.serialize()
	pl["id"] = 1
	player_info_list.append(pl)
	display_player(pl)
	# Start as server
	enet.create_server(PORT)
	if enet.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server")
		return
	multiplayer.multiplayer_peer = enet
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	upnp_setup()
	start_game_button.visible = true

@rpc("call_local")
func display_player(pi: Dictionary):
	var label = Label.new()
	var color_rect = ColorRect.new()
	color_rect.set_custom_minimum_size(Vector2(10, 10))
	color_rect.color = Color(pi["avatar_color"])
	label.text = pi["pseudo"] + " " + str(pi["id"])
	var player_row = HBoxContainer.new()
	player_row.add_child(color_rect)
	player_row.add_child(label)
	$UI/Net.add_child(player_row)


@rpc("any_peer", "call_remote")
func add_player_client(pi):
	player_info_list.append(pi)
	display_player.rpc(pi)

@rpc
func register_client():
	var pl = _player_info.serialize()
	pl["id"] = multiplayer.get_unique_id()
	add_player_client.rpc_id(1, pl)

func add_player(id: int):
	var pl = _player_info.serialize()
	pl["id"] = 1
	display_player.rpc_id(id, pl)
	register_client.rpc_id(id)
	


func del_player(id: int):
	pass

func init_as_client(player_info: PlayerInfo, host: String):
	_player_info = player_info
	enet.create_client(host, PORT)
	if enet.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client")
		return
	multiplayer.multiplayer_peer = enet


func start_game():
	# Hide the UI and unpause to start the game.
	$UI.hide()
	#get_tree().paused = false
	game_started = true
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		change_level.call_deferred(load("res://scenes/world.tscn"))

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	var instanciated_scene = scene.instantiate()
	level.add_child(instanciated_scene)
	instanciated_scene.init(player_info_list)


func _process(delta):
	if multiplayer.is_server():
		return
	if not game_started:
		var stat = get_peer_latency(1)
		$UI/Net/Ping.text = str(stat)
	if $Level.get_child_count() > 0:
		start_game()


func get_peer_latency(id):
	var peer = enet.get_peer(id)
	if peer:
		return peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
	return 0

func upnp_setup():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	external_ip_adress = "Server's ip address: %s" % upnp.query_external_address()
	print("Success! Join Address: %s" % upnp.query_external_address())


func _on_start_game_button_pressed():
		start_game()

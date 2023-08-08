# multiplayer.gd
extends Node

const PORT = 4433
var enet = ENetMultiplayerPeer.new()

var game_started = false

func _ready():
	# get_tree().paused = true
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false


	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_pressed.call_deferred()

func _on_host_pressed():
	# Start as server
	enet.create_server(PORT)
	if enet.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server")
		return
	multiplayer.multiplayer_peer = enet
	upnp_setup()
	start_game()


func _on_connect_pressed():
	# Start as client
	var txt : String = $UI/Net/Option/Remote.text
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	enet.create_client(txt, PORT)
	if enet.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client")
		return
	if enet.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		OS.alert("Connecting")
	multiplayer.multiplayer_peer = enet
	start_game()

func start_game():
	# Hide the UI and unpause to start the game.
	$UI/Net/Option.hide()
	get_tree().paused = false
	game_started = true
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		change_level.call_deferred(load("res://world.tscn"))

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())


func _process(delta):
	if not game_started or multiplayer.is_server():
		return
	var stat = get_peer_latency(1)
	$UI/Net/Ping.text = str(stat)

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
	
	print("Success! Join Address: %s" % upnp.query_external_address())

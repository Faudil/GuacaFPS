extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false

@export var firing := false

@export var mouse_movement = Vector2()

var _mouse_movement = Vector2()
var _mouse_moved = false

# Synchronized property.
@export var direction := Vector3()

func _ready():
	# Only process for the local player.
	print("PlayerInput ", multiplayer.get_unique_id())
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	if not OS.has_feature("dedicated_server"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


@rpc("call_local", "any_peer")
func jump():
	jumping = true

@rpc("call_local", "any_peer")
func fire():
	firing = true

@rpc("call_local", "any_peer")
func rotate(mouse_position):
	mouse_movement = mouse_position

func _unhandled_input(event):
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	if event is InputEventMouseMotion:
		_mouse_moved = true
		_mouse_movement = event.relative


func _process(delta):
	var head = $"../Head"
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	if Input.is_action_just_pressed("fire"):
		# fire.rpc()
		firing = true
		pass
	if _mouse_moved:
		# rotate.rpc(_mouse_movement)
		_mouse_moved = false
		mouse_movement = _mouse_movement


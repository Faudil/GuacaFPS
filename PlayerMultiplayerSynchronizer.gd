extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false

@export var firing := false

@export var mouse_movement = Vector2()

var _mouse_movement = Vector2()

# Synchronized property.
@export var direction := Vector2()

func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	if not OS.has_feature("dedicated_server"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


@rpc("call_local")
func jump():
	jumping = true
	
@rpc("call_local")
func fire():
	firing = true
	
@rpc("call_local")
func rotate(mouse_position):
	mouse_movement = mouse_position

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_mouse_movement = event.relative

func _process(_delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	if Input.is_action_just_pressed("fire"):
		fire.rpc()
	rotate.rpc(_mouse_movement)
	_mouse_movement = Vector2()

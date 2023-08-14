extends MultiplayerSynchronizer

const SENSITIVITY = 0.004

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false

@export var firing := false

@export var sprinting := false

@export var pseudo := ""

@export var mouse_movement = Vector2()

@export var camera_x_axis = 0

@export var head_y_axis = 0

var _mouse_movement = Vector2()
var _mouse_moved = false

# Synchronized property.
@export var direction := Vector3()

func _ready():
	# Only process for the local player.
	print("PlayerInput ", multiplayer.get_unique_id())
	var is_authority = multiplayer.get_unique_id() == get_multiplayer_authority()
	if is_authority:
		var player_vars = get_node("/root/Globals")
		if not OS.has_feature("dedicated_server"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			print("Mouse captured")
	set_process(is_authority)


@rpc("call_local", "any_peer")
func jump():
	jumping = true

@rpc("call_local")
func fire():
	firing = true
	
@rpc("call_local", "any_peer")
func sprint():
	sprinting = true

@rpc("call_local", "any_peer")
func walk():
	sprinting = false


func _unhandled_input(event):
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
		fire.rpc()
	if Input.is_action_just_pressed("sprint"):
		sprint.rpc()
	if Input.is_action_just_released("sprint"):
		walk.rpc()
	# Camera rotation
	if _mouse_moved:
		_mouse_moved = false
		mouse_movement = _mouse_movement
		var camera = $"../Head/Camera3D"
		$"../Head".rotate_y(-mouse_movement.x * SENSITIVITY)
		# Camera rotation
		camera.rotate_x(-mouse_movement.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		camera_x_axis = camera.rotation.x
		head_y_axis = head.rotation.y
		



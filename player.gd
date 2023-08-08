extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004

#bob variables
const BOB_FREQ = 3
const BOB_AMP = 0.06
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8



# Set by the authority, synchronized on spawn.
@export var player := 1:
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerMultiplayerSynchronizer.set_multiplayer_authority(id)

@onready var firing = false
@onready var input = $PlayerMultiplayerSynchronizer


func _ready():
	if player == multiplayer.get_unique_id():
		$Head/Camera3D.current = true


@rpc("call_local")
func fire():
	var weapon = $Head/Camera3D/Hand/pistol
	weapon.fire()
	
@rpc("call_local")
func rotate_camera(head_y_axis, camera_x_axis):
	if player == multiplayer.get_unique_id():
		return
	# print('Called in ', player, " for ", multiplayer.get_unique_id())
	var camera = $Head/Camera3D
	$Head.rotation.y = head_y_axis
	# Camera rotation
	camera.rotation.x = camera_x_axis
	

func _physics_process(delta):
	var head = $Head
	var camera = $Head/Camera3D
	var weapon = $Head/Camera3D/Hand/pistol
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


	# Handle Jump.
	if input.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Sprint.
	if input.jumping:
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	input.jumping = false

	if multiplayer.is_server():
		if input.firing:
			fire.rpc()
			input.firing = false
		if player != 1:
			rotate_camera.rpc_id(1, input.head_y_axis, input.camera_x_axis)
		for id in multiplayer.get_peers():
			if id != player:
				rotate_camera.rpc_id(id, input.head_y_axis, input.camera_x_axis)

	# Get the input direction and handle the movement/deceleration.
	var input_dir = input.direction


	var direction = input_dir
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	if not OS.has_feature("dedicated_server"):

		# Weapon sway
		var x_mov = -input.mouse_movement.x
		weapon.apply_weapon_sway(x_mov, delta)
		# Reset mouse movement
		input.mouse_movement = Vector2()

		# Head bob
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)

		# FOV
		var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
		var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

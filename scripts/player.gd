extends CharacterBody3D


var speed: float
const WALK_SPEED: float = 5.0
const SPRINT_SPEED: float = 10.0
const JUMP_VELOCITY: float = 6.8
const SENSITIVITY: float = 0.004

#bob variables
const BOB_FREQ: float = 3
const BOB_AMP: float = 0.1
var t_bob: float = 0.0


const HIMARKER_DURATION: float = 0.1

var hitmarker_timer: float = 0

#fov variables
const BASE_FOV = 90.0
const FOV_CHANGE = 1.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8


@export var kills = 0

# Set by the authority, synchronized on spawn.
@export var player := 1:
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerMultiplayerSynchronizer.set_multiplayer_authority(id)

@onready var firing = false
@onready var input = $PlayerMultiplayerSynchronizer
@onready var player_stat = $PlayerStat

func _ready():
	if player == multiplayer.get_unique_id():
		$Control.visible = true
		$Head/Camera3D.current = true


func get_pseudo() -> String:
	return input.pseudo


@rpc("call_local")
func receive_damage(damages):
	player_stat.receive_damage(damages)
	if player == multiplayer.get_unique_id():
		$Control/HealthBar.value = player_stat.get_health()
		$AudioStreamPlayer.play()

@rpc("call_local")
func kill(killed_by):
	kills = 0
	position = Vector3.ZERO
	player_stat.respawn()
	if player == multiplayer.get_unique_id():
		$Control/HealthBar.value = player_stat.get_health()
		$Control/Info.text = "You've been killed by " + killed_by
		$AudioStreamPlayer.play()

@rpc("call_local")
func add_kill():
	kills += 1
	$Control/KillCount.text = "Kills: " + str(kills)

@rpc("call_local")
func hitmarker():
	$Control/Hitmarker.visible = true
	hitmarker_timer = HIMARKER_DURATION


func apply_damage(killed_by, damage) -> bool:
	var new_health = player_stat.get_health() - damage
	if new_health <= 0:
		kill.rpc(killed_by)
		return true
	else:
		receive_damage.rpc(damage)
	return false

@rpc("call_local")
func fire_effect():
	var weapon = $Head/Camera3D/Hand/pistol
	weapon.fire()

func fire():
	var raycast = $Head/Camera3D/RayCast3D
	if raycast.is_colliding():
		var hit_player = raycast.get_collider()
		if "apply_damage" in hit_player:
			# If the player is the host
			print("Hit client ", hit_player.player)
			hitmarker.rpc_id(player)
			if hit_player.apply_damage(get_pseudo(), 1):
				add_kill.rpc()

@rpc("call_local")
func rotate_camera(head_y_axis, camera_x_axis):
	if player == multiplayer.get_unique_id():
		return
	var camera = $Head/Camera3D
	$Head.rotation.y = head_y_axis
	# Camera rotation
	camera.rotation.x = camera_x_axis
	
func server_process(delta: float):
	var weapon = $Head/Camera3D/Hand/pistol
	if input.firing and not weapon.is_firing():
		fire_effect.rpc()
		fire()
		input.firing = false
	if player != 1:
		rotate_camera.rpc_id(1, input.head_y_axis, input.camera_x_axis)
		for id in multiplayer.get_peers():
			if id != player:
				rotate_camera.rpc_id(id, input.head_y_axis, input.camera_x_axis)

func client_process(delta: float):
	var camera = $Head/Camera3D
	var weapon = $Head/Camera3D/Hand/pistol
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


func direction_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if input.jumping and is_on_floor():
		if input.sprinting:
			velocity.y = JUMP_VELOCITY * 1.4
		else:
			velocity.y = JUMP_VELOCITY
	input.jumping = false
	# Handle Sprint.
	if input.sprinting:
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

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

func _physics_process(delta):
	if $Control/Hitmarker.visible:
		hitmarker_timer -= delta
		if hitmarker_timer <= 0:
			$Control/Hitmarker.visible = false
	var weapon = $Head/Camera3D/Hand/pistol
	direction_process(delta)

	if multiplayer.is_server():
		server_process(delta)
	# Get the input direction and handle the movement/deceleration.


	if player == multiplayer.get_unique_id():
		client_process(delta)
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

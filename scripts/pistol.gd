extends Node3D

# Weapon Sway
var sway_threshold:float = 10
var sway_lerp: float = 5

@export var sway_left: Vector3 = Vector3(0, 0.3, 0.2)
@export var sway_right: Vector3 = Vector3(0, -0.3, -0.2)
@export var sway_normal: Vector3 = Vector3()

@export var recoil_vector: Vector3 = Vector3(-10, 0, 0)

var rng = RandomNumberGenerator.new()
@export var RECOIL: int = 3

var recoil: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	apply_recoil(delta)

func apply_weapon_sway(x_mov, delta):
	if x_mov > sway_threshold:
		rotation = rotation.lerp(sway_left, sway_lerp * delta)
	elif x_mov < -sway_threshold:
		rotation = rotation.lerp(sway_right, sway_lerp * delta)
	else:
		rotation = rotation.lerp(sway_normal, sway_lerp * delta)
		
func apply_recoil(delta: float):
	if recoil < 0:
		return
	recoil -= delta
	rotation = rotation.lerp(recoil_vector, recoil * delta)

func is_firing() -> bool:
	return $pistol/AnimationPlayer.current_animation == "Fire"

func fire():
	$AudioStreamPlayer3D.pitch_scale = rng.randf_range(0.9, 1.1)
	$AudioStreamPlayer3D.play()
	recoil += RECOIL
	$pistol/AnimationPlayer.play("Fire")


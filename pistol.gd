extends Node3D

# Weapon Sway
var sway_threshold = 10
var sway_lerp = 5

@export var sway_left = Vector3()
@export var sway_right = Vector3() 
@export var sway_normal = Vector3()

const RAY_LENGTH = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func apply_weapon_sway(x_mov, delta):
	if x_mov > sway_threshold:
		rotation = rotation.lerp(sway_left, sway_lerp * delta)
	elif x_mov < -sway_threshold:
		rotation = rotation.lerp(sway_right, sway_lerp * delta)
	else:
		rotation = rotation.lerp(sway_normal, sway_lerp * delta)

func fire():
	$AnimationPlayer.play("fire")


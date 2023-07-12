extends Node3D


const RAY_LENGTH = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func fire():
	$AnimationPlayer.play("fire")


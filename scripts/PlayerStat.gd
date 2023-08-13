extends Node

var walk_speed: float = 5.0
var sprint_speed: float = 10.0
var jump_velocity: float = 6.8
var sensitivity: float = 0.004


var health: float = 3.0

func get_walk_speed() -> float:
	return walk_speed

func get_sprint_speed() -> float:
	return sprint_speed
	
func get_jump_velocity() -> float:
	return jump_velocity

func get_sensitivity() -> float:
	return sensitivity

func get_health() -> float:
	return health

@rpc("call_local")
func receive_damage(damage: float):
	health = maxf(0, health - damage)

func respawn():
	health = 3

func is_alive():
	return health > 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

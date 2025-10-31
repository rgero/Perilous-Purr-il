extends Camera3D

@onready var objectToFollow: CharacterBody3D
@onready var offsetDistance: Vector3 = Vector3(0, 10, 10)
@onready var targetRotation: Vector3 = Vector3(10, 0, 0)

func _ready() -> void:
	objectToFollow = get_tree().get_first_node_in_group("Player")
	rotation = targetRotation

func _process(delta: float) -> void:
	var target_pos = objectToFollow.global_position + offsetDistance
	global_position = global_position.lerp(target_pos, delta * 5.0)

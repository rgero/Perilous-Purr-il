extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 6
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var playerCamera: PackedScene
@export var cameraOffset: Vector3

@export var sprintTime := 3.0
@export var speedIncrease := 1.3
var currentSprint := 0.0

var cameraInstance: Node

func _ready() -> void:
	cameraInstance = playerCamera.instantiate()
	get_tree().current_scene.add_child.call_deferred(cameraInstance)
	call_deferred("_position_camera")
	
func _position_camera() -> void:
	cameraInstance.global_position += cameraOffset
	
func _process(_delta: float) -> void:
	cameraInstance.global_position = global_position + cameraOffset
	cameraInstance.look_at(global_position)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()

	var target_speed = SPEED
	if Input.is_action_pressed("Sprint") and currentSprint < sprintTime:
		target_speed *= speedIncrease

	if direction != Vector3.ZERO:
		animation_player.play("Walking")
		var target_rot_y = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot_y, delta * 10.0)
		velocity.x = direction.x * target_speed
		velocity.z = direction.z * target_speed
	else:
		animation_player.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
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

	if direction != Vector3.ZERO:
		animation_player.play("Walking")
		
		# Rotate the CharacterBody3D itself
		var target_rot_y = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot_y, delta * 10.0)

		# Movement should now use world space (not local transform)
		var move_dir = Vector3(input_dir.x, 0, input_dir.y).normalized()
		
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
		
		if Input.is_action_pressed("Sprint") and currentSprint < sprintTime:
			velocity.x *= speedIncrease
			velocity.z *= speedIncrease

	else:
		animation_player.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if not Input.is_action_pressed("Sprint"):
		currentSprint = 0

	move_and_slide()

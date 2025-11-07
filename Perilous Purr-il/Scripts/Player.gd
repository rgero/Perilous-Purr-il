extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var playerCamera: PackedScene
@export var cameraOffset: Vector3

@export var playerSpeed = 5.0
@export var jumpVelocity = 6.0
@export var sprintTime := 3.0
@export var speedIncrease := 1.3
var currentSprint := 0.0

var cameraInstance: Node3D
var cameraYAngle: float = 0.0  # tracks rotation around player
@export var cameraRotationSpeed := 2.0

func _ready() -> void:
	cameraInstance = playerCamera.instantiate()
	get_tree().current_scene.add_child.call_deferred(cameraInstance)
	call_deferred("PositionCamera")

func _process(delta: float) -> void:
	HandleCameraRotation(delta)
	UpdateCameraPosition()
	
func PositionCamera() -> void:
	cameraInstance.global_position = global_position + cameraOffset
	cameraInstance.look_at(global_position)

func UpdateCameraPosition() -> void:
	var rot = Basis(Vector3.UP, deg_to_rad(cameraYAngle))
	var rotated_offset = rot * cameraOffset
	cameraInstance.global_position = global_position + rotated_offset
	cameraInstance.look_at(global_position)

func HandleCameraRotation(delta: float) -> void:
	if Input.is_action_pressed("Rotate CW"):
		cameraYAngle += cameraRotationSpeed * delta * 60.0
	elif Input.is_action_pressed("Rotate CCW"):
		cameraYAngle -= cameraRotationSpeed * delta * 60.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jumpVelocity

	var directionInput := Input.get_vector("Left", "Right", "Up", "Down")

	if directionInput != Vector2.ZERO:
		var cam_to_player := (global_position - cameraInstance.global_position)
		cam_to_player.y = 0.0
		var cam_forward := cam_to_player.normalized()
		
		var cam_right := cam_forward.cross(Vector3.UP).normalized()
		
		# Combine input with camera orientation:
		# directionInput.y is "Up" (forward/backward) - Has to be negative to get pet walking away
		# directionInput.x is "Right"/"Left"
		var move_dir := (cam_forward * -directionInput.y + cam_right * directionInput.x)
		if move_dir.length() > 0.001:
			move_dir = move_dir.normalized()

		var targetSpeed = playerSpeed
		if Input.is_action_pressed("Sprint") and currentSprint < sprintTime:
			targetSpeed *= speedIncrease

		velocity.x = move_dir.x * targetSpeed
		velocity.z = move_dir.z * targetSpeed

		# Face movement direction
		var target_rot_y = atan2(move_dir.x, move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot_y, delta * 10.0)

		animation_player.play("Walking")
	else:
		animation_player.stop()
		velocity.x = move_toward(velocity.x, 0, playerSpeed)
		velocity.z = move_toward(velocity.z, 0, playerSpeed)

	move_and_slide()

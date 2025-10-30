extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
	else:
		animation_player.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

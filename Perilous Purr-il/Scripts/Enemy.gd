extends CharacterBody3D
class_name Enemy

@export var speed: float = 5.0
@export var maxHealth: float = 100.0
@export var eye_height: float = 1.5  # height from which to cast vision rays
@export var aggro_range: float = 10.0  # optional detection distance

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var detectionArea: Area3D = $Area3D

var provoked := false
var player: Node3D = null
var spaceState: PhysicsDirectSpaceState3D

func _ready() -> void:
	spaceState = get_world_3d().get_direct_space_state()
	assert(spaceState != null, "Space State not found.")
	
	# Connect signals safely in case they aren’t already connected
	if not detectionArea.body_entered.is_connected(_on_area_3d_body_entered):
		detectionArea.body_entered.connect(_on_area_3d_body_entered)
	if not detectionArea.body_exited.is_connected(_on_area_3d_body_exited):
		detectionArea.body_exited.connect(_on_area_3d_body_exited)

func _process(_delta: float) -> void:
	if player:
		navAgent.target_position = player.global_position

func _physics_process(delta: float) -> void:
	if provoked and player:
		if not DetermineCanSee(player):
			provoked = false
			player = null
			if animationPlayer.is_playing():
				animationPlayer.stop()
			return
		ChasePlayer(delta)
	elif provoked:
		provoked = false

func ChasePlayer(delta: float) -> void:
	if not provoked:
		if animationPlayer.is_playing():
			animationPlayer.stop()
		return
		
	animationPlayer.play("Walking")
		
	var nextPosition = navAgent.get_next_path_position()

	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var direction := global_position.direction_to(nextPosition)
	if direction:
		LookAtTarget(direction)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func LookAtTarget(direction: Vector3) -> void:
	var adjustedDirection = direction
	adjustedDirection.y = 0.0
	
	var lookAtDirection = global_position + adjustedDirection
	if global_position.distance_to(lookAtDirection) > 0.001:
		look_at(lookAtDirection, Vector3.UP, true)

func DetermineCanSee(body: Node3D) -> bool:
	if not body or not is_instance_valid(body):
		return false

	var params = PhysicsRayQueryParameters3D.new()
	params.from = global_position + Vector3.UP * eye_height
	params.to = body.global_position + Vector3.UP * 1.0
	params.exclude = [self]
	params.collide_with_areas = false
	params.collide_with_bodies = true

	var raycastResult = spaceState.intersect_ray(params)

	if raycastResult:
		var hitObject = raycastResult["collider"]
		return hitObject.is_in_group("Player")

	return false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if DetermineCanSee(body):
			provoked = true
			player = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		provoked = false
		player = null

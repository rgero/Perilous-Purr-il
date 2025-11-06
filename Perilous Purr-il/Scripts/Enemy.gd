extends CharacterBody3D

class_name Enemy

@export var speed = 5.
@export var attackRange: float = 1.5
@export var maxHealth: float = 100

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var collisonShape: CollisionShape3D = $Area3D/CollisionShape3D

var provoked := false
var player: Node3D

var spaceState: PhysicsDirectSpaceState3D

func _ready() -> void:

	spaceState = get_world_3d().get_direct_space_state()
	assert(spaceState != null, "Space State is fucked")

func _process(_delta: float) -> void:
	if player:
		navAgent.target_position = player.global_position;
	
func _physics_process(delta: float) -> void:
	#var distance = global_position.distance_to(player.global_position)
	#if distance <= aggroRange:
		#provoked = true
	#else:
		#provoked = false
		#
	ChasePlayer(delta)

func ChasePlayer(delta: float) -> void:
	if !provoked:
		if animationPlayer.is_playing():
			animationPlayer.stop()
		return
		
	animationPlayer.play("Walking")
		
	var nextPosition = navAgent.get_next_path_position()
	# Add the gravity.
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
	adjustedDirection.y = 0;
	
	# look_at uses a global position.
	var lookAtDirection = global_position + adjustedDirection
	if global_position.distance_to(lookAtDirection) > 0.001:
		look_at(lookAtDirection, Vector3.UP, true)

func DetermineCanSee(body: Node3D) -> bool:
	var params = PhysicsRayQueryParameters3D.new()
	params.from = collisonShape.global_position
	params.to = body.global_position
	var raycastResult = spaceState.intersect_ray(params)
	if raycastResult:
		var hitObject = raycastResult["collider"]
		return hitObject.is_in_group("Player")
	return false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if DetermineCanSee(body):
		provoked = true
		player = body

func _on_area_3d_body_exited(_body: Node3D) -> void:
	provoked = false
	player = null

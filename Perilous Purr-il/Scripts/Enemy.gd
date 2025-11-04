extends CharacterBody3D

class_name Enemy

@export var speed = 5.
@export var attackRange: float = 1.5
@export var maxHealth: float = 100

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

var player: Node3D
var provoked := false
var aggroRange = 15.0
var damage := 20.0
var health: float = maxHealth:
	set(value):
		health = value
		provoked = true
		if health <= 0:
			queue_free()
		

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta: float) -> void:
	navAgent.target_position = player.global_position;
	
func _physics_process(delta: float) -> void:
	var distance = global_position.distance_to(player.global_position)
	if distance <= aggroRange:
		provoked = true
	else:
		provoked = false
		
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

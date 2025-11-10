extends Node3D

@export var levelContainer: Node3D
@export var selectedPlayerPrefab: PackedScene
var playerSpawnPoint: Node3D

func _ready() -> void:
	playerSpawnPoint = levelContainer.find_child("Player Spawn", true, true)
	if !playerSpawnPoint:
		push_error("Player Spawn Point not found")
		return;
	SpawnPlayer()

func SpawnPlayer() -> void:
	var player = selectedPlayerPrefab.instantiate();
	player.global_position = playerSpawnPoint.global_position;
	levelContainer.add_child(player);

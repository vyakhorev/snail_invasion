extends Node
class_name GameController 

@export var _spawned_instances_root : Node
@export var _player_spawn : Node2D
@export var _enemy_spawns_root : Node
@export var _default_camera_target : Node2D
@export var _player_prefab : PackedScene
@export var _snail_prefab : PackedScene
@export var _camera : Camera2D

@onready var _snail_spawn_timer : Timer = $SnailSpawnTimer
@onready var _HUD : HUDScript = $HUD


var _spawned_snails_this_run : int
var _player : PlayerCharacterController
var _enemies : Array[Enemy]
var _score : int = 0
var _total_score : int = 0
var _game_running : bool = false
var _max_player_health : int


func _ready():
	_camera.global_position = _default_camera_target.global_position
	MessageBus.connect("after_player_died", after_player_death)
	MessageBus.connect("after_enemy_killed", after_enemy_killed)
	MessageBus.connect("on_health_changed", on_health_changed)
	_HUD.to_new_game_state()
	_HUD.set_message("Survive!")
	

func _process(delta):
	if _game_running:
		var camera_target = _player.get_camera_target()
		if camera_target != null:
			_camera.global_position = camera_target.global_position


func after_player_death():
	game_over()


func after_enemy_killed(score: int):
	_score += score
	_total_score += score
	_HUD.update_score(_score)
	
	
func on_health_changed(node: Node, health_left: int, health_changed: int):
	if node is PlayerCharacterController:
		var health_level : int = round((health_left as float / _max_player_health) * 100)
		_HUD.update_health(health_level)
	

func game_over():
	_game_running = false
	_camera.global_position = _default_camera_target.global_position
	_snail_spawn_timer.stop()
	destroy_spawned_instances()
	_player = null
	_HUD.show_game_over()


func new_game():
	_spawned_snails_this_run = 0
	_score = 0
	_total_score = 0
	_HUD.update_score(_total_score)
	_HUD.show_message("Get Ready!")
	spawn_player()
	_snail_spawn_timer.start()
	_game_running = true


func spawn_player():
	_player = _player_prefab.instantiate() as PlayerCharacterController
	_player.global_position = _player_spawn.global_position
	
	_max_player_health = 0
	for child in _player.get_children():
		if child is Damagable:
			_max_player_health = child._health
	if _max_player_health == 0:
		push_error("max player health is 0 - that's wrong!")
	
	_HUD.update_health(100)
	
	_spawned_instances_root.add_child(_player)
		
	
func destroy_spawned_instances():
	for ch_i in _spawned_instances_root.get_children():
		ch_i.queue_free()


func _on_hud_start_game():
	new_game()


func _on_snail_spawn_timer_timeout():
	spawn_snail()
	_spawned_snails_this_run += 1


func spawn_snail():
	var spawns = []
	for ch_i in _enemy_spawns_root.get_children():
		if ch_i is Node2D:
			spawns.append(ch_i)
		else:
			print("Enemy spawn is expected to be Node2D")
		
	var rand_index: int = randi_range(0, spawns.size() - 1)

	var random_spawn_point : Node2D = spawns[rand_index]
	
	var new_snail = _snail_prefab.instantiate() as Enemy
	new_snail.global_position = random_spawn_point.global_position
	_spawned_instances_root.add_child(new_snail)


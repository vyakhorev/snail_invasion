extends CharacterBody2D
class_name PlayerCharacterController

@export var _character_speed : float = 300.0
@export var _jump_velocity : float = -400.0
@export var _sword_damage : int = 1

@onready var _animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var _sword_area : Area2D = $Sword
@onready var _camera_target : Node2D = $CameraTarget
@onready var _hurt_sfx : AudioStreamPlayer2D = $HurtSFX


var _gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _is_state_attacking : bool = false
var _sword_area_right_x : float
var _camera_target_right_x : float
var _is_alive: bool = true


func get_camera_target() -> Node2D:
	return _camera_target


func _ready():
	_sword_area.monitoring = false
	_sword_area_right_x = _sword_area.position.x
	_camera_target_right_x = _camera_target.position.x


func _physics_process(delta):
	# direactional input + physics
	if not is_on_floor():
		velocity.y += _gravity * delta
	
	if not _is_alive:
		velocity.x = 0
		move_and_slide()
		return

	if Input.is_action_just_pressed("char_jump") and is_on_floor():
		velocity.y = _jump_velocity

	var intended_direction = Input.get_vector("char_left", "char_right", "char_up", "char_down")
	if intended_direction.x != 0:
		velocity.x = intended_direction.x * _character_speed
	else:
		velocity.x = move_toward(velocity.x, 0, _character_speed)
	
	move_and_slide()
	
	# Attack
	if Input.is_action_just_pressed("char_attack"):
		_is_state_attacking = true
		_sword_area.monitoring = true
		_animated_sprite.play("attack")
	
	# Animation
	if not _is_state_attacking:
		if intended_direction.x != 0:
			_animated_sprite.play("run")
		else:
			_animated_sprite.play("idle")
		
	if intended_direction.x > 0:
		_animated_sprite.flip_h = false
		_sword_area.position.x = _sword_area_right_x
		_camera_target.position.x = _camera_target_right_x
	elif intended_direction.x < 0:
		_sword_area.position.x = -1 * _sword_area_right_x
		_camera_target.position.x = -1 * _camera_target_right_x
		_animated_sprite.flip_h = true


func _on_animated_sprite_2d_animation_finished():
	if _animated_sprite.animation == "attack":
		_is_state_attacking = false
		_sword_area.monitoring = false
	
	elif _animated_sprite.animation == "dead":
		MessageBus.emit_signal("after_player_died")


func _on_sword_body_entered(body):
	if not _is_state_attacking:
		return
	
	for child in body.get_children():
		if child is Damagable:
			child.damagable_hit(_sword_damage)


func _on_damagable_damage_received(damage, health_left):
	_hurt_sfx.play()
	if health_left <= 0:
		_is_alive = false
		_animated_sprite.play("dead")

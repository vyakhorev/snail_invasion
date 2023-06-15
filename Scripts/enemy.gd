extends CharacterBody2D

class_name Enemy

@export var _character_speed = 20.0
@export var _damage = 1
@export var _score = 1
@export var _move_direction : Vector2
@onready var _animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var _damaging_area : Area2D = $DamagingArea
@onready var _hurt_sfx : AudioStreamPlayer2D = $HurtSFX
@onready var _forward_sensor : Area2D = $SensorArea

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _external_impulse: Vector2 = Vector2.ZERO
var _is_alive: bool = true
var _forward_sensor_left_x : float

func _ready():
	_damaging_area.monitoring = true
	_forward_sensor.monitoring = true
	_forward_sensor_left_x = _forward_sensor.position.x
	if randf() > 0.5:
		_move_direction = Vector2.LEFT
	else:
		_move_direction = Vector2.RIGHT
	

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += _gravity * delta
	
	var direction : float
	
	if _move_direction.x > 0:
		_animated_sprite.flip_h = true
		_forward_sensor.position.x = -1 * _forward_sensor_left_x
	elif _move_direction.x < 0:
		_forward_sensor.position.x = _forward_sensor_left_x
		_animated_sprite.flip_h = false
	
	if _is_alive:
		direction = _move_direction.x
	else:
		direction = 0
	
	if direction != 0:
		velocity.x = direction * _character_speed
		_animated_sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, _character_speed)
		if _is_alive:
			_animated_sprite.play("idle")

	move_and_slide()


func _on_damagable_damage_received(damage, health_left):
	_hurt_sfx.play()
	if health_left <= 0:
		_is_alive = false
		_damaging_area.monitoring = false
		_animated_sprite.play("dead")


func _on_animated_sprite_2d_animation_finished():
	if _animated_sprite.animation == "dead":
		MessageBus.emit_signal("after_enemy_killed", _score)
		queue_free()


func _on_damaging_area_body_entered(body):
	for child in body.get_children():
		if child is Damagable:
			child.damagable_hit(_damage)


func _on_sensor_area_body_entered(body):
	_move_direction = -1 * _move_direction

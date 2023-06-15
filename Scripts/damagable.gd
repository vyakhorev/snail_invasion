extends Node

class_name Damagable

@export var _health : int = 2
var _can_receive_damage : bool = true
var _owner : Node2D

signal damage_received(damage : int, health_left : int)


func _ready():
	_owner = get_parent()


func damagable_hit(damage : int):
	if _can_receive_damage:
		_health -= damage
		if _health <= 0:
			_can_receive_damage = false
			
		damage_received.emit(
			damage, 
			_health
		)
		
		MessageBus.emit_signal(
			"on_health_changed", 
			_owner, 
			_health, 
			-1 * _health
		)
	

func is_still_alive() -> bool:
	return _health > 0

extends Node
class_name MesssageBus

signal after_player_died
signal after_enemy_killed(score: int)
signal on_health_changed(node: Node, health_left: int, health_changed: int)

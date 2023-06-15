extends CanvasLayer
class_name HUDScript 


signal start_game


@onready var _message_label : Label = $Message
@onready var _message_timer : Timer = $MessageTimer
@onready var _score_label : Label = $TopMenu/ScoreLabel
@onready var _start_button : Button = $StartButton
@onready var _health_bar : ProgressBar = $TopMenu/HealthBar


func set_message(text):
	_message_label.text = text


func show_message(text):
	_message_label.text = text
	_message_label.show()
	_message_timer.start()


func show_game_over():
	show_message("Game\nOver")
	
	await _message_timer.timeout
	
	to_new_game_state()


func to_new_game_state():
	_health_bar.hide()
	_score_label.hide()
	_start_button.show()


func to_ingame_state():
	_health_bar.show()
	_score_label.show()
	_start_button.hide()


func update_health(health_left_perc : int):
	_health_bar.value = health_left_perc


func update_score(score):
	_score_label.text = "Score: " + str(score)


func _on_start_button_pressed():
	to_ingame_state()
	start_game.emit()


func _on_message_timer_timeout():
	_message_label.hide()




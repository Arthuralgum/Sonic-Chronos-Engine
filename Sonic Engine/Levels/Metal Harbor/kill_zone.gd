extends Area2D

@onready var timer: Timer = $Timer


func _on_body_entered(body: Player) -> void:
	print("You died!")
	Engine.time_scale = 0.5
	timer.start()


func _on_timer_timeout() -> void:
	Global.game_over = true
	Engine.time_scale = 1
	System.ExitStageTo("res://System/UI/Level Selection Screen/Level selection screen.tscn")

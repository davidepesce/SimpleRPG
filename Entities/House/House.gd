extends Node2D


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		$Roof.hide()
	elif body.name.find("Skeleton") >= 0:
		body.direction = -body.direction
		body.bounce_countdown = 16


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		$Roof.show()

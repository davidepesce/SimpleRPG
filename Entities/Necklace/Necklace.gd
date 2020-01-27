extends Area2D

var fiona

func _ready():
	fiona = get_tree().root.get_node("Root/Fiona")

func _on_Necklace_body_entered(body):
	if body.name == "Player":
		get_tree().queue_delete(self)
		fiona.necklace_found = true

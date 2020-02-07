extends Area2D

var tilemap
var speed = 80
var direction : Vector2
var attack_damage


func _ready():
	tilemap = get_tree().root.get_node("Root/TileMap")


func _process(delta):
	position = position + speed * delta * direction


func _on_Fireball_body_entered(body):
	# Ignore collision with Player and Water
	if body.name == "Player":
		return
	
	if body.name == "TileMap":
		var cell_coord = tilemap.world_to_map(position)
		var cell_type_id = tilemap.get_cellv(cell_coord)
		if cell_type_id == tilemap.tile_set.find_tile_by_name("Water"):
			return
	
	# If the fireball hit a Skeleton, call the hit() function
	if body.name.find("Skeleton") >= 0:
		body.hit(attack_damage)
	
	# Stop the movement and explode
	direction = Vector2.ZERO
	$AnimatedSprite.play("explode")
	
	# Play explosion sound
	$SoundExplosion.play()

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "explode":
		get_tree().queue_delete(self)


func _on_Timer_timeout():
	$AnimatedSprite.play("explode")

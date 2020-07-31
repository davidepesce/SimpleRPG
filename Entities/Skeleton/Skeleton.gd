extends KinematicBody2D

signal death

# Node references
var player

# Random number generator
var rng = RandomNumberGenerator.new()

# Skeleton stats
var health = 100
var health_max = 100
var health_regeneration = 1

# Attack variables
var attack_damage = 10
var attack_cooldown_time = 1500
var next_attack_time = 0

# Movement variables
export var speed = 25
var direction : Vector2
var last_direction = Vector2(0, 1)
var bounce_countdown = 0

# Animation variables
var other_animation_playing = false

# Reference to potion scene
var potion_scene = preload("res://Entities/Potion/Potion.tscn")


func _ready():
	player = get_tree().root.get_node("Root/Player")
	rng.randomize()


func _process(delta):
	# Regenerates health
	health = min(health + health_regeneration * delta, health_max)
	
	# Check if Skeleton can attack
	var now = OS.get_ticks_msec()
	if now >= next_attack_time:
		# What's the target?
		var target = $RayCast2D.get_collider()
		if target != null and target.name == "Player" and player.health > 0:
			# Play attack animation
			other_animation_playing = true
			var animation = get_animation_direction(last_direction) + "_attack"
			$AnimatedSprite.play(animation)
			# Add cooldown time to current time
			next_attack_time = now + attack_cooldown_time


func _on_Timer_timeout():
	# Calculate the position of the player relative to the skeleton
	var player_relative_position = player.position - position
	
	if player_relative_position.length() <= 16:
		# If player is near, don't move but turn toward it
		direction = Vector2.ZERO
		last_direction = player_relative_position.normalized()
	elif player_relative_position.length() <= 100 and bounce_countdown == 0:
		# If player is within range, move toward it
		direction = player_relative_position.normalized()
	elif bounce_countdown == 0:
		# If player is too far, randomly decide whether to stand still or where to move
		var random_number = rng.randf()
		if random_number < 0.05:
			direction = Vector2.ZERO
		elif random_number < 0.1:
			direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI)
	
	# Update bounce countdown
	if bounce_countdown > 0:
		bounce_countdown = bounce_countdown - 1


func _physics_process(delta):
	var movement = direction * speed * delta
	
	var collision = move_and_collide(movement)
	
	if collision != null and collision.collider.name != "Player":
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		bounce_countdown = rng.randi_range(2, 5)
	
	# Animate skeleton based on direction
	if not other_animation_playing:
		animates_monster(direction)
	
	# Turn RayCast2D toward movement direction
	if direction != Vector2.ZERO:
		$RayCast2D.cast_to = direction.normalized() * 16


func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.y >= 0.707:
		return "down"
	elif norm_direction.y <= -0.707:
		return "up"
	elif norm_direction.x <= -0.707:
		return "left"
	elif norm_direction.x >= 0.707:
		return "right"
	return "down"


func animates_monster(direction: Vector2):
	if direction != Vector2.ZERO:
		last_direction = direction
		
		# Choose walk animation based on movement direction
		var animation = get_animation_direction(last_direction) + "_walk"
		
		# Play the walk animation
		$AnimatedSprite.play(animation)
	else:
		# Choose idle animation based on last movement direction and play it
		var animation = get_animation_direction(last_direction) + "_idle"
		$AnimatedSprite.play(animation)


func arise():
	other_animation_playing = true
	$AnimatedSprite.play("birth")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "birth":
		$AnimatedSprite.animation = "down_idle"
		$Timer.start()
	elif $AnimatedSprite.animation == "death":
		get_tree().queue_delete(self)
	other_animation_playing = false


func hit(damage):
	health -= damage
	if health > 0:
		$AnimationPlayer.play("Hit")
	else:
		$Timer.stop()
		direction = Vector2.ZERO
		set_process(false)
		other_animation_playing = true
		$AnimatedSprite.play("death")
		emit_signal("death")
		# Play death sound
		$SoundDeath.play()
		# 80% probability to drop a potion on death
		if rng.randf() <= 0.8:
			var potion = potion_scene.instance()
			potion.type = rng.randi() % 2
			get_tree().root.get_node("Root").call_deferred("add_child", potion)
			potion.position = position
		# Add XP to player
		player.add_xp(25)


func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation.ends_with("_attack") and $AnimatedSprite.frame == 1:
		var target = $RayCast2D.get_collider()
		if target != null and target.name == "Player" and player.health > 0:
			player.hit(attack_damage)
		# Play attack sound
		$SoundAttack.play()


func to_dictionary():
	return {
		"position" : [position.x, position.y],
		"health" : health
	}


func from_dictionary(data):
	position = Vector2(data.position[0], data.position[1])
	health = data.health

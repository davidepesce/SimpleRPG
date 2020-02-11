extends Popup

onready var player = get_node("/root/Root/Player")
var already_paused
var selected_menu


func change_menu_color():
	$Resume.color = Color.gray
	$Restart.color = Color.gray
	$Quit.color = Color.gray
	
	match selected_menu:
		0:
			$Resume.color = Color.greenyellow
		1:
			$Restart.color = Color.greenyellow
		2:
			$Quit.color = Color.greenyellow


func _input(event):
	if event is InputEventKey:
		var just_pressed = event.pressed and not event.echo
		
		if not visible:
			if event.scancode == KEY_ESCAPE and just_pressed:
				# Pause game
				already_paused = get_tree().paused
				get_tree().paused = true
				# Reset the popup
				selected_menu = 0
				change_menu_color()
				# Show popup
				player.set_process_input(false)
				popup()
		else:
			if event.scancode == KEY_DOWN and just_pressed:
				selected_menu = (selected_menu + 1) % 3;
				change_menu_color()
			elif event.scancode == KEY_UP and just_pressed:
				if selected_menu > 0:
					selected_menu = selected_menu - 1
				else:
					selected_menu = 2
				change_menu_color()
			elif event.scancode == KEY_SPACE and just_pressed:
				match selected_menu:
					0:
						# Resume game
						if not already_paused:
							get_tree().paused = false
						player.set_process_input(true)
						hide()
					1:
						# Restart game
						get_tree().change_scene("res://Scenes/Main.tscn")
						get_tree().paused = false
					2:
						# Quit game
						get_tree().quit()

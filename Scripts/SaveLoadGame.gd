extends Node

var load_saved_game = false

func _ready():
	var file = File.new()
	if load_saved_game and file.file_exists("user://savegame.json"):
		file.open("user://savegame.json", File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		
		$Player.from_dictionary(data.player)
		$Fiona.from_dictionary(data.fiona)
		$SkeletonSpawner.from_dictionary(data.skeletons)
		if($Fiona.necklace_found):
			$Necklace.queue_free()
		if(not data.potion1):
			$StartPotion1.queue_free()
		if(not data.potion2):
			$StartPotion2.queue_free()


func save():
	var data = {
		"player" : $Player.to_dictionary(),
		"fiona" : $Fiona.to_dictionary(),
		"skeletons" : $SkeletonSpawner.to_dictionary(),
		"potion1" : is_instance_valid(get_node("/root/Root/StartPotion1")),
		"potion2" : is_instance_valid(get_node("/root/Root/StartPotion2"))
	}
	
	var file = File.new()
	file.open("user://savegame.json", File.WRITE)
	var json = to_json(data)
	file.store_line(json)
	file.close()

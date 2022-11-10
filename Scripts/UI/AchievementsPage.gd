extends Control
class_name AchievementsPage

@onready var table:ScrollableTable = $ScrollContainer

func _ready():
	GameData.register_set_global_hook('achievements',self,'update_items')
	update_items()
	
func update_items(_path=null):
	var achievements = GameData.get_global('achievements')
	table.set_items(capitalize_keys(achievements))
	
func capitalize_keys(dict):
	var new_dict = {}
	for k in dict:
		new_dict[k.capitalize()] = dict[k]
	
	return new_dict

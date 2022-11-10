extends Control
class_name StatsPage

@onready var mental_stat_table:ScrollableTable = $HBoxContainer/StatsPanel_Mental/VBoxContainer/UI_Scrollable_Table
@onready var physical_stat_table:ScrollableTable = $HBoxContainer/StatsPanel_Physical/VBoxContainer/UI_Scrollable_Table

func _ready():
	GameData.register_set_global_hook('stats',self,'update_items')
	GameData.register_set_data_hook('characters/Lily/stats',self,'update_items')
	update_items()
	
func update_items(_path=null):
	var stats_mental = GameData.get_global('stats')
	mental_stat_table.set_items(capitalize_keys(stats_mental))
	var stats_physical = GameData.get_data('characters/Lily/stats')
	physical_stat_table.set_items(capitalize_keys(stats_physical))
	
func capitalize_keys(dict):
	var new_dict = {}
	for k in dict:
		new_dict[k.capitalize()] = dict[k]
	
	return new_dict

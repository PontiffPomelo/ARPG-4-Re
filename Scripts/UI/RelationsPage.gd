extends Control
class_name RelationsPage

@onready var table:ScrollableTable = $ScrollContainer

func _ready():
	GameData.register_set_global_hook('relations',self,'update_items')
	GameData.register_set_data_hook('characters/Lily/relations',self,'update_items')
	update_items()
	
func update_items(_path = null):
	table.set_items({"CHARACTER":["YOUR OPINION OF THEM","THEIR OPINION OF YOU"]})
	table.set_items(collect_table_data(),false)

func collect_table_data(_path=null):
	var relations = Helper.deep_copy(GameData.get_data('characters/Lily/relations'))
	for k in relations:
		relations[k]  = [relations[k]]
	
	for k in relations:
		relations[k].append(GameData.get_data('characters/'+k+'/relations/Lily','???'))
	
	return relations

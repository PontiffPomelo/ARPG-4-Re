extends FocusPanel
class_name QuestElement

var quest :
	get:
		return quest # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of _set_quest

func _set_quest(v):
	quest = v
	var quest_real = ResourceManager.quests[quest.name]
	get_node('./Label').text = quest_real.label
	


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	pass # Replace with function body.


		
func _focus_entered():
	super._focus_entered()
	GameData.get_temp('UI').quest_menu.set_active_quest(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

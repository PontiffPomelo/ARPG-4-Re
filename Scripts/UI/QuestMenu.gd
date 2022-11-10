extends Control
class_name QuestMenu

const default_quest_element = preload("res://Prefabs/UI/UI_QuestElement.tscn")

@onready var list = $AutoFocusContainer/List/ScrollContainer/VBoxContainer
@onready var title = $AutoFocusContainer/Content/VBoxContainer/Title
@onready var description = $AutoFocusContainer/Content/VBoxContainer/ScrollContainer/Description



var elements = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#GameData.get_temp('UI').quest_menu = self
	elements = list.get_children()
	if visible:
		filter_changed()
		
	GameData.quests_changed.connect(self.filter_changed)
	#GameData.register_set_global_hook('display_ongoing_quests',self,'filter_changed')
	#GameData.register_set_global_hook('display_finished_quests',self,'filter_changed')
	
func filter_changed(_path=null):
	var quests : Dictionary = GameData.get_quest_data() # quests exist in 2 types : local as in fetch quest and global as in MC's own goal. Goals do not reset between timejumps.
	var keys = quests.keys()
	var buttons_size = elements.size() # How many pooled buttons exist already. Do we need to create new ones?
	var quest_size = quests.size()
		
	var display_ongoing_quests = GameData.get_global('display_ongoing_quests')
	var display_finished_quests = GameData.get_global('display_finished_quests')
		
		
	for i in range(buttons_size):
		elements[i].hide()
		
	var _i = 0 # Some quests may be skipped due to filter, so this maps quests to buttons
	for i in range(quest_size):
		if _i >= buttons_size:
			var newele = default_quest_element.instantiate()
			elements.append(newele)
			list.add_child(newele)
			newele.set_owner(list)
		
		var button : QuestElement = elements[_i]

		var quest = quests[keys[i]]
		if quest == null:
			continue;
		
		var _quest : Quest = ResourceManager.quests[quest.name]
		
		if _quest.is_finished() and not display_finished_quests:
			continue
		if not _quest.is_finished() and not display_ongoing_quests:
			continue

		button.quest = quest
		button.show()
		_i += 1

func show():
	
	filter_changed()
	super.show()
	#list.show()# otherwise focus won't be set correctly
	$AutoFocusContainer.show()
	pass

func set_active_quest(quest_element):
	var quest = quest_element.quest
	var quest_real = ResourceManager.quests[quest.name]
	title.text = quest_real.get_label()
	description.set_bbcode(quest_real.get_description())
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


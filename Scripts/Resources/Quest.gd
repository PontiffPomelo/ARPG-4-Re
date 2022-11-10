extends Resource
class_name Quest
# @tool

@export var is_temporary: bool = true # will this quest revert back in time?
@export var is_repeatable: bool = false # will this quest revert back in time?
@export var name: String
@export var label: String
@export var description: String = "This is the description of the quest as a whole"
@export var stages : Array[Quest_Stage] = [Quest_Stage.new()] # (Array,Quest_Stage)

var loaded = false
var stage = -1 # Only used for internal hook management, always superceded by GameData

func get_quest_instance():
	var quests = GameData.get_data("quests") if is_temporary else GameData.get_global("quests")
	return quests.get(name)
	
func set_quest_instance(qi):
	print('setting quest instance to ', qi, ' checked ', name)
	
	if qi != null:
		if is_temporary:
			GameData.set_data("quests/"+name,qi)
		else:
			GameData.set_global("quests/"+name,qi)
	else:
		var quests:Dictionary = GameData.get_data("quests",{}) if is_temporary else GameData.get_global("quests",{})
		quests.erase(name) # Make sure it's not stored as null, but completely removed
		GameData.set_data("quests",quests) if is_temporary else GameData.set_global("quests",quests)
	
	
func get_stage()->int:
	var instance= get_quest_instance()
	return instance.stage if instance else -1

func get_description():
	var desc = description + '\n\n'
	
	var cur_stage = get_quest_instance().stage
	for i in range(cur_stage+1):
		if i < cur_stage :
			desc += '[color=grey]'
		else:
			desc += '[color=white]'
		desc += '' + stages[i].get_description() + '[/color]\n\n'
	
	return desc
	
	
func get_label():
	return label
	
func is_active():
	return get_quest_instance() != null
	
func is_finished():
	return get_quest_instance().stage + 1 >= stages.size()

func start():
	if get_quest_instance() != null:
		print_debug('QUEST ALREADY STARTED. CAN ONLY START QUEST ONCE')
	
	var quest_data
	quest_data = {"name":name,"stage":0}
	set_quest_instance(quest_data)
	_start()
	
func _start():
	var quest_data = get_quest_instance()
	stage = quest_data.stage
	stages[stage]._load(self,stage)
	stages[stage].start(self)
	
	#on_data_change() # Manually incase load caused preemptive trigger
	
	GameData.get_temp('NotificationSystem').push_notification('New Quest started',label)
	
	check_for_progress()

# undo the start() of this quest, iE if the dialogue it started in gets rolled back
func undo():
	print('undoing quest start')
	if get_quest_instance() != null:
		set_quest_instance(null)
	if stage != -1:
		stages[stage].undo(self,stage)
		stages[stage]._unload(self,stage)
		stage = -1;
	
# This gets called by ResourceManager checked game start
func _load():
	if loaded:
		return
	loaded = true
	
	#stages[stage]._load(self)
	
	if is_temporary:
		GameData.register_set_data_hook("quests/"+name,self,'on_data_change')
	else:
		GameData.register_set_global_hook("quests/"+name,self,'on_data_change')
		
	
		
	
	
# Is this useful anymore?
func _unload():
	if not loaded :
		return
	loaded = false
	#stages[get_quest_instance().stage]._unload(self)
	
	stages[stage]._unload(self,stage)
	
	if is_temporary:
		GameData.remove_set_data_hook("quests/"+name,self,'on_data_change')
	else:
		GameData.remove_set_data_hook("quests/"+name,self,'on_data_change')

#callback directly from stage
func stage_finish():
	if loaded:
		advance_stage()
	
func finish():
	
	pass

func on_data_change(_path = null):
	var qi = get_quest_instance()
	
	print('QUEST DETECTED CHANGE DATA')
	if qi:
		on_stage_change()
	else: 
		undo()
		pass

# This assumes the GameData is already set to new_stage
func on_stage_change():
	var new_stage = get_quest_instance().stage
	
	if new_stage + 1 >= stages.size() or new_stage < 0:
		print('Cannot advance quest ', name, ' as there exists no stage at index ', new_stage)
		return
		
	print('QUEST CHANGE from ', stage, ' to ', new_stage)
		
	while stage != new_stage:
		if stage < new_stage :
			advance_stage(new_stage)
		else:
			revert_stage(new_stage)
#	stages[stage]._unload(self,stage)
#	stages[new_stage]._load(self,new_stage)
#	stages[new_stage].start(self)
#	stage = new_stage

func check_for_progress():
	stages[get_quest_instance().stage].check_for_progress(self)

func revert_stage(target_stage = get_quest_instance().stage-1):
	if target_stage < 0:
		print('Cannot advance quest ', name, ' as there exists no prev stage')
		return
	
	stages[stage].undo(self,stage)
	
	var qi = get_quest_instance()
	qi.stage = target_stage
	stage = qi.stage
	set_quest_instance(qi)
	stages[target_stage]._load(self)
		
	# check_for_progress() # Is this smart? kinda inf loop territory.

func advance_stage(target_stage = get_quest_instance().stage+1):
	if is_finished():
		print('Cannot advance quest ', name, ' as there exists no next stage ')
		return
	
	if stage != -1: # Local stage property stores whatever stage was LOADED last, not necessarily the same as whatever stage was SET last.
		stages[stage]._unload(self,stage)
	
	#print('advancing stage after ')
	#print_stack()
	#stages[get_quest_instance().stage]._unload(self)
	var qi = get_quest_instance()
	qi.stage = target_stage
	stage = target_stage
	set_quest_instance(qi)
	
	
	if stages.size() > target_stage:
		stages[target_stage].start(self)
		stages[target_stage]._load(self)
	
	GameData.get_temp('NotificationSystem').push_notification('Quest advanced : ' + label , stages[get_quest_instance().stage].name)
	
	check_for_progress()

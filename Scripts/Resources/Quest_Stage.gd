extends Resource
class_name Quest_Stage
# @tool

@export var name: String  = "In Progress"
@export var description = "This is the description of the quest" # (String,MULTILINE)
@export var stage_watchers_data: String # check stage completion each time any of these changes. Comma separated
@export var stage_watchers_global: String # check stage completion each time any of these changes. Comma separated
@export_multiline var on_start # Only called once ever, which is when the stage gets entered # (String,MULTILINE)
@export_multiline var on_undo # Only called once ever, which is when the stage gets entered # (String,MULTILINE)
@export_multiline var on_load # Called each time a savegame gets loaded , that uses this stage actively, or checked stage start # (String,MULTILINE)
@export_multiline var on_unload # Called each time this stage was active and the game gets reset or the stage finishes # (String,MULTILINE)
@export_multiline var on_finish # Called once only when the stage is finished # (String,MULTILINE)
@export_multiline var requirements # Code that evaluates to bool, return true if # (String,MULTILINE)

func get_description():
	return description

func start(quest):
	if on_start != "":
		Helper.run_script(on_start,{'quest':quest,'stage':self})
		print('running code ', on_start)
	print('STARTING quest stage ', name , ' with start code ', on_start)
	pass
	
## Opposite of start()
func undo(quest,_quest_stage):
	if on_undo:
		Helper.run_script(on_undo,{'quest':quest,'stage':self})
	pass
	
	
func _load(quest,quest_stage = null):

	print('LOADED QUEST STAGE ', name)

	if quest_stage == null:
		quest_stage = quest.get_quest_instance().stage

	var watchers_data = stage_watchers_data.split(',',false)
	for key in watchers_data:
		GameData.register_set_data_hook(key,self,"check_for_progress",[quest])
	
	var watchers_global = stage_watchers_global.split(',',false)
	for key in watchers_global:
		GameData.register_set_global_hook(key,self,"check_for_progress",[quest])
		
	if quest.is_temporary:
		GameData.register_set_data_hook('quests/'+quest.name,self,"check_quest_state_change",[quest,quest_stage])
	else:
		GameData.register_set_global_hook('quests/'+quest.name,self,"check_quest_state_change",[quest,quest_stage])
		
	if on_load:
		Helper.run_script(on_load,{"quest":quest,"stage":self})
	pass
	
# Unload only if quest got removed entirely, or if the stage changed
# @returns {bool}
func check_quest_state_change(quest,stage_self,_path=null)->bool:
	print('--------------------------- changed quest state to ', quest.get_quest_instance())
	if not quest.get_quest_instance() or quest.get_quest_instance().stage != stage_self:
		_unload(quest,stage_self)
		return false
	if quest.get_quest_instance() == {}:
		assert(false)
		print_stack()
	return true
		
	
	
func _unload(quest,quest_stage):
	print('UNLOADED QUEST STAGE ', name)
	
	
	if quest_stage == null:
		quest_stage = quest.get_quest_instance().stage
		
	if on_unload:
		Helper.run_script(on_unload,[quest,self])
		
	
	var watchers_data = stage_watchers_data.split(',',false)
	
	for key in watchers_data:
		GameData.remove_set_data_hook(key,self,"check_for_progress",[quest])
	
	var watchers_global = stage_watchers_global.split(',',false)
	for key in watchers_global:
		GameData.remove_set_global_hook(key,self,"check_for_progress",[quest])
		
			
	if quest.is_temporary:
		GameData.remove_set_data_hook('quests/'+quest.name,self,"check_quest_state_change",[quest,quest_stage])
	else:
		GameData.remove_set_global_hook('quests/'+quest.name,self,"check_quest_state_change",[quest,quest_stage])
		
	pass
	
func finish(quest):
	if on_finish:
		Helper.run_script(on_finish,{"quest":quest,"context":self})
	quest.stage_finish()
	pass

func check_for_progress(quest,_path=null):
	if(Helper.run_script(requirements,{"quest":quest,"context":self})):
		print('stage is done, ', name)
		finish(quest)
	else:
		print('failed conditional')
	pass

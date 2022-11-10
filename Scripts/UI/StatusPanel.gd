extends Control
class_name StatusPanel

@onready var page_container = $Panel/Pages

var active_page

func _ready():
	GameData.set_temp('StatusMenu',self)
	change_page('StatsPage')

func change_page(page_name):
	if active_page != null:
		active_page.hide()
	
	active_page = page_container.get_node(page_name)
	active_page.show()

func get_stat(name,character="Lily"):
	if character == "Lily": # Some of Lily's stats are in global so they carry over between lives (The mental ones)
		var stat = GameData.get_global('stats/'+name)
		if stat != null:
			return stat
	return GameData.get_data('characters/'+character+'/stats/'+name)
	
func get_relations(towards,character="Lily"):
	if character == "Lily": # Lily has 2 relations stats. One is the apparent ones, which is what she should have if this was her only life, the other is her real feelings, which she accumulated over multiple lives.
		var stat = GameData.get_global('relations/'+towards)
		if stat != null:
			return stat
	return GameData.get_data('characters/'+character+'/relations/'+towards)
	
# If force_mental is true, and the stat does not exist as a physical stat, add it as a mental one instead of a physical one.
func set_stat(name,value,character="Lily",force_mental=false,notification=true):
	var stat = GameData.has_data('characters/'+character+'/stats/'+name)
	if not stat:
		if character == "Lily" and (GameData.has_global('stats/'+name) or force_mental): # Some of Lily's stats are in global so they carry over between lives (The mental ones)
			stat = GameData.set_global('stats/'+name,value)
		else:
			GameData.set_data('characters/'+character+'/stats/'+name,value)
	if notification and character == 'Lily':
		GameData.get_temp('NotificationSystem').push_notification('Stat changed', name + ' = ' + str(value))
	
func add_stat(name,value,character="Lily",notification=true):
	if character == "Lily" and GameData.has_global('stats/'+name): # Some of Lily's stats are in global so they carry over between lives (The mental ones)
		GameData.set_global('stats/'+name,GameData.get_global('stats/'+name,0)+value)
	else: 
		GameData.set_data('characters/'+character+'/stats/'+name,GameData.get_data('characters/'+character+'/stats/'+name,0)+value)
			
	if notification and character == 'Lily':
		GameData.get_temp('NotificationSystem').push_notification('Stat gained', name + ' ' + ('+' if value >= 0 else '') + str(value))
	
func add_relations(towards,value,character="Lily",notification=true):
	if character == "Lily": # Lily has 2 relations stats. One is the apparent ones, which is what she should have if this was her only life, the other is her real feelings, which she accumulated over multiple lives.
		var stat = GameData.get_global('relations/'+towards)
		if stat != null:
			GameData.set_global('relations/'+towards,stat+value)
	var stat = GameData.get_data('characters/'+character+'/relations/'+towards)
	GameData.set_data('characters/'+character+'/relations/'+towards,stat+value)
	
	if notification and character == 'Lily':
		GameData.get_temp('NotificationSystem').push_notification('Relations changed', towards + ' ' + ('+' if value >= 0 else '') + str(value))
	
func set_relations(towards,value,character="Lily",notification=true):
	if character == "Lily": # Lily has 2 relations stats. One is the apparent ones, which is what she should have if this was her only life, the other is her real feelings, which she accumulated over multiple lives.
		GameData.set_global('relations/'+towards,value)
	GameData.set_data('characters/'+character+'/relations/'+towards,value)
	if notification and character == 'Lily':
		GameData.get_temp('NotificationSystem').push_notification('Relations set', towards + ' = ' + str(value))

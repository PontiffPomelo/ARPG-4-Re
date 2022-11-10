extends Node
# @tool
# Singleton that handles all resource imports and management.
# Quests, images, dialogues, etc


###
# CONSTANT RESOURCES
###

var items : Dictionary = {}# items by name

var recipes : Dictionary = {}# items by name

var quests : Dictionary = {}# quests by name

var character_sprites : Dictionary = {} # by gender

var characters : Dictionary = {} # characters by name

var dialogues : Dictionary = {} # dialogues by name, collated (if multiple with same name)

var skills : Dictionary = {} # skills by name

var permission_groups : Dictionary = {} # permission groups by name


func _ready():

#	if not Engine.is_editor_hint():

	load_items()
	load_skills()
	load_recipes()
	load_characters()
	load_character_compositions()
	load_quests()
	load_character_sprites()
	load_dialogue()
	load_resources(permission_groups,"res://Resources/PermissionGroups")
	
	if not Engine.is_editor_hint():
		await RenderingServer.frame_post_draw
		reset()
	
func reset():
	return;
	#var quest_data = GameData.get_quest_data()
	#for quest in quest_data:
	#	quests[quest_data[quest].name]._load()

		


func get_character_sprites():
	#if character_sprites.size() == 0:
	load_character_sprites()
	return character_sprites


const hexa_to_dec = {'0':0,'1':1,'2':2,'3':3,'4':4,'5':5,'6':6,'7':7,'8':8,'9':9,
'a':10,'b':11,'c':12,'d':13,'e':14,'f':15}
func parse_hexadecimal(string:String):
	if string.length() > 10 || not string.begins_with('0x'):
		return string
		
	var offset:int = 1
	var result = 0
	for k in range(2,string.length()):
		var character = string[k]
		result += hexa_to_dec[character] * offset
		offset *= 16
		
	assert(result>=0)
		
	return result#string.hex_to_int()
		
	

# Deeply iterates the dictionary and replaces hexadecimal numbers with integers
func parse_numbers(dict):
	var keys = dict.keys() if dict is Dictionary else range(dict.size())
	for x in keys:
		var val = dict[x]
		if val is Dictionary or val is Array:
			parse_numbers(val)
		else:
			if val is String:
				dict[x] = parse_hexadecimal(val)
	return dict

# Returns a dictionary loaded from the json. It defines the individual sprites needed for the pose/expression and their respective offsets.
#func get_character_composition(character_name,pose,expression):
	
func load_collated_json(dict,dir_path,suffix='.json'):
	#print('LOADING COLLATED JSON')
	var list = Helper.list_files_in_directory(dir_path,suffix)
	for i in range(list.size()):
		var path = list[i] # actual path within path directory
		var file = FileAccess.open(path, FileAccess.READ)
		var text_json = file.get_as_text()
		var test_json_conv = JSON.new()
		var error = test_json_conv.parse(text_json)
	
		if error == OK:  # If parse OK
			var data = parse_numbers(test_json_conv.get_data())
			Helper.deep_join_dictionaries(dict,data)
		else:  # If parse has errors
			print_debug("Error: ", error)
			print("Error Line: ", test_json_conv.get_error_line())
			print("Error String: ", test_json_conv.get_error_message())
			print_stack();
	pass

func load_resources(dict,path:String,suffix=".tres") -> void:
	var list = Helper.list_files_in_directory(path,suffix)
	for i in range(list.size()):
		var element = load(list[i])
		if element:
			var element_name = element.get('name')
			if element_name == null:
				element_name = list[i].get_file()
				element_name = element_name.substr(0,element_name.length()-suffix.length())
			dict[element_name] = element
		else:
			print('Couldn\'t find resource ' + list[i])

func load_characters():
	#print('LOADING CHARACTERS')
	
	load_resources(characters,"res://Resources/Characters")

func load_items():
	#print('LOADING ITEMS')
	
	load_resources(items,"res://Resources/Items")
		
func load_quests():
	#print('LOADING QUESTS')
	load_resources(quests,"res://Resources/Quests")
	for quest in quests:
		quests[quest]._load()
	
func load_recipes():
	#print('LOADING RECIPES')
	load_resources(recipes,"res://Resources/Recipes")
	
func load_skills():
	#print('LOADING SKILLS')
	load_resources(skills,"res://Resources/Skills")

func load_character_compositions():
	#print('LOADING CHAR COMPS')
	#
	return;
	var comps = Helper.list_files_in_directory("res://images/RenderOutput",".json")
	
	for path in comps:
		var file = FileAccess.open(path, FileAccess.READ)
		var text_json = file.get_as_text()
		var test_json_conv = JSON.new()
		var error = test_json_conv.parse(text_json)
	
		if error == OK:  # If parse OK
			var data = test_json_conv.get_data()
			
			if not (data.character in characters) :
				characters[data.character]  = {"compositions" : {},"name":data.character}
			
			if not characters[data.character].compositions.has(data.pose):
				characters[data.character].compositions[data.pose] = {}

			var pose = characters[data.character].compositions[data.pose]
				
			if not characters[data.character].compositions.has("Default"):
				characters[data.character].compositions["Default"] = pose
			
			if not data.expression in pose:
				pose[data.expression] = {'Default':data}
				
			
			pose[data.expression][data.camera] = data
			if data["type"] == 'Expression':
				if pose.get('DefaultExpression') == null:
					pose['DefaultExpression'] = {'Default':data}
				if pose['DefaultExpression'].get(data.camera) == null:
					pose['DefaultExpression'][data.camera] = data # Any expression is better than none, but by design the Default Expression should be set manually
			if data.type == 'Body':
				if pose.get('DefaultBody') == null:
					pose['DefaultBody'] = {'Default':data}
				if pose['DefaultBody'].get(data.camera) == null:
					pose['DefaultBody'][data.camera] = data # Any expression is better than none, but by design the Default Body should be set manually
		else:  # If parse has errors
			print_debug("Error: ", error)
			print("Error Line: ", test_json_conv.get_error_line())
			print("Error String: ", test_json_conv.get_error_message())
			print_stack();
	
func load_character_sprites():
	#print('LOADING CHAR SPRITES')
	var genders = Helper.list_directories("res://images/CharacterCreator/body/")
	
	for gender in genders :
		var offset = "res://images/CharacterCreator/body/".length() + gender.length() + 1
		character_sprites[gender] = Helper.list_files_in_directory("res://images/CharacterCreator/body/" + gender,".png");
		for i in range(character_sprites[gender].size()):
			var path = character_sprites[gender][i]
			character_sprites[gender][i] = path.substr(offset,path.length()-4- offset)
			
func load_dialogue():
	#print('LOADING DIALOGUES')
	load_collated_json(dialogues,"res://Resources/Dialogues")
	
## Split string by needle, but only if needle is not inside single or double quoted block
func split_not_inside_string(text:String,needle:String)->PackedStringArray:
	var result = PackedStringArray()

	var last_split = 0
	var i = 0
	var single_quote = false
	var double_quote = false
	while i < text.length() - needle.length() :
		var success = true
		
		if text[i] == "'" and not double_quote:
			single_quote = not single_quote
			
		if text[i] == '"' and not single_quote:
			double_quote = not double_quote
		
		if not (single_quote or double_quote):
			for j in range(needle.length()):
				if not text[i+j] == needle[j]:
					success = false
					break;
			if success:
				result.append(text.substr(last_split,i-last_split))			
				i += needle.length() - 1
				last_split = i+1
		i+=1
		
	if last_split < text.length()-1:
		result.append(text.substr(last_split))
		
	return result
	
	
func scene_to_json(path="res://Scenes/House1_Inside.tscn"):
	#print('SCENE TO JSON')
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	var segments = text.split('\n[')
	var references = {}
	var open_references = {} # Pair of [node,key] that need to be replaced with the reference once it's loaded
	#var sub_resources = {} # These are all instanced resources specific to the scene, such as Shape3D
	#var open_sub_resources = {} # same as references
	var nodes = {} # Nodes by path
	
	var expression = Expression.new()
	
	var root_node = null; # Equivalent to . in all references for some reason.
	
	#print('TEST ', split_not_inside_string("this 'test is working' fine"," "))
	
	for segment in range(segments.size()):
		var elements = segments[segment].split('\n');
		
		var json_element = {"body":{},"header":{}};
		
		var type_params = split_not_inside_string(elements[0].substr(0,elements[0].length()-1),' '); # Remove the trailing ]
		var type = type_params[0]
		json_element['type'] = type;
		#print('set type to ', type)
		
		for element_index in range(1,type_params.size()):
			var element = type_params[element_index]
			var split_index = element.find('=') # May contain string with =
			var key = element.substr(0,split_index).strip_edges()
			var value = element.substr(split_index+1,element.length()).strip_edges()
			#print('parsing ', value, ' as ', expression.parse(value))
			expression.parse(value)
			json_element['header'][key] = expression.execute()
			#print('result is ',expression.execute())
			#print('found type param ', key, ' = ', value)
		
		for element_index in range(1,elements.size()):
			var element = elements[element_index]
			if element == '':# Ignore empty lines
				break;
			var split_index = element.find('=') # May contain string with =
			var key = element.substr(0,split_index-1).strip_edges()
			var value = element.substr(split_index+1).strip_edges()
			if value.begins_with('ExtResource'):
				expression.parse(value.substr('ExtResource'.length(),value.length() - 'ExtResource'.length())) # strip ExtResource(*) to it's content *
				var v = expression.execute()
				if references.has(v):
					json_element['body'][key] = references[v]
				else:
					print('didn\'t find reference to ', v , ' as string : ', value.substr('ExtResource'.length(),value.length() - 'ExtResource'.length()))
					if not open_references.has(v):
						open_references[v] = []
					open_references[v].append([json_element['body'],key])
			else:
				expression.parse(value)
				json_element['body'][key] = expression.execute()
		
		if type == 'node':
			json_element['children'] = {}
			if(not json_element["header"].has('parent')):
				if root_node != null:
					print("Root node is already defined")
				root_node = json_element
				path = '.'
			else:
				var parent = json_element["header"]['parent']
				if not parent.begins_with('.'):
					parent = './'+parent
				path = parent + '/' + json_element["header"]['name']
			nodes[path] = json_element
		
		elif type == 'ext_resource':
			var id = json_element["header"]['id']
			references[id] = json_element
			if open_references.has(id): # If the reference was added too late, and was needed by a previous node, restore it now.
				for ref in open_references[id]:
					ref[0][ref[1]] = json_element
		
	for node_path in nodes:
		var node = nodes[node_path]
		if node["header"].has('parent'):
			var parent = node["header"]["parent"]
			if not parent.begins_with('.'):
				parent = './'+parent
			nodes[parent]['children'][node["header"]["name"]] = node 
		
	assert(false)
	

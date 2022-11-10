extends Node
@tool

var time = 0

var ESCAPE = PackedByteArray([0x1b]).get_string_from_ascii()
var CODES = {
	"green":ESCAPE+"[1;32m",
	"endc":ESCAPE+"[0m"
	}


func _process(delta):
	time += delta
	
# Specifically meant for scripts that don't have access to nodes
func wait(seconds):
	var start = time
	while(time - start < seconds):
		await RenderingServer.frame_post_draw
	return
	
	
func screenshot(path):
	var image = get_viewport().get_texture().get_data()
	var width = image.get_width()
	var height = image.get_height()
	var maxAsp = max(max(width,height),512)
	width /= maxAsp/512
	height /= maxAsp/512
	image.resize(width,height)
	image.flip_y()
	image.save_png(path + ".png")
	
# Parse a string with insert tags of the shape {{{...}}} into an evaluated string. Used by DialogueBox
func parse_text(text:String) -> String:
	var fragments = []
	var consecutive_brackets = 0
	var i_open = 0
	var is_open = false
	for k in range(text.length()):
		var c = text[k]
		if is_open:
			if c == '}':
				consecutive_brackets+=1
				if consecutive_brackets == 3:
					fragments.append([i_open,k-3 - i_open + 1]) #This is the length, so even if both start and end are the same, result should be 1
					consecutive_brackets = 0
					is_open = false
			else:
				consecutive_brackets = 0
		else:
			if c == '{':
				consecutive_brackets+=1
				if consecutive_brackets == 3:
					i_open = k+1
					consecutive_brackets = 0
					is_open = true
			else:
				consecutive_brackets = 0
		
	var result = ""
	var last_character = 0
	for k in range(fragments.size()):
		var fragment = fragments[k]
		if fragment[0]-3 - last_character > 0:
			result += text.substr(last_character,fragment[0]-3 - last_character) # Skip the brackets
		var code = text.substr(fragment[0],fragment[1])
		result += run_script(code)
		last_character = fragment[0] + fragment[1] + 3
		
	if text.length() != last_character+3:	
		result += text.substr(last_character) # Skip the brackets
		
		
	return result
	
# Sets a node's property, including a nested one. Makes sure to set values too if parents are values (Vector2 etc) Will also call set() checked node if it comes up.
func set_node_property(node,variable_name,value,always_call_set=true):
	var parts = variable_name.split('.')
	var endvar = node
	
	var endvars = [endvar]
	
	# Collect all depths of the variable path first
	
	for part_i in range(parts.size()-1):
		var part = parts[part_i]
		endvar = node.get(part)
		endvars.append(endvar)
	
	endvar = value
	
	var part_i = parts.size()
##
	while not typeof(endvar) in [TYPE_ARRAY ,TYPE_DICTIONARY ,TYPE_OBJECT]:
		part_i = part_i - 1
		if part_i < 0 :
			break

		var new_endvar = endvars[part_i]

		if new_endvar is Node:
			new_endvar.set(parts[part_i],endvar)
		else:
			new_endvar[parts[part_i]] = endvar#value


		endvar = new_endvar
	
	if endvar != node and always_call_set: # Forcefully trigger set incase that's needed for sidechains
		endvar.set(parts[0],endvar.get(parts[0]))

	#node.set(parts[0],node.get(parts[0]))


func list_files_in_directory(path,ends_with=".png",files : PackedStringArray = PackedStringArray([]),deep=true) -> PackedStringArray:
	print(path)
	var dir = DirAccess.open(path)
	var _files = dir.get_files()
	
	for file in _files:
		if file.begins_with('.') or (ends_with != null and not file.ends_with(ends_with) ):
			continue
		files.append(path + "/" + file)
	
	if deep:
		var _dirs = dir.get_directories()
		for subdir in _dirs:
			Helper.list_files_in_directory(path + "/" + subdir,ends_with,files)

	return files
	
func list_directories(path,result=PackedStringArray([])) -> PackedStringArray:
	return DirAccess.open(path).get_directories() if DirAccess.dir_exists_absolute(path) else []

# Can load image from anywhere, while load can only do so within the res:// folder
func load_image(path):
	var img = Image.new()
	var err = img.load(path)
	if(err != 0):
		print("error loading the image: " + path)
		return null
	var img_tex = ImageTexture.create_from_image(img)
	
	return img_tex

# sometimes scenes are not freed before the next one is loaded, which results in @ signs being added for unqiqueness. These break savegames and must be sanitized
var sanitized_chars = {"@":true,"0":true,"1":true,"2":true,"3":true,"4":true,"5":true,"6":true,"7":true,"8":true,"9":true}
func sanitize_path(path):
	var sanitized = "";
	var afterPrct = false
	for k in path:
		if(k == '@'):
			afterPrct = true
		elif not sanitized_chars.has(k):
			afterPrct = false
		if not afterPrct:
			sanitized += k;
	return sanitized
	
	
	
func array_join(arr : Array, glue : String = '') -> String:
	var string : String = ''
	for index in range(0, arr.size()):
		string += str(arr[index])
		if index < arr.size() - 1:
			string += glue
	return string

# Target does not work if v is an object. (TODO)
func deep_copy(v,target=null):
	var t = typeof(v)

	if v == null:
		return v;

	if target == null:
		target = [] if t == TYPE_ARRAY else {}

	

	if t == TYPE_DICTIONARY:
		for k in v:
			target[k] = deep_copy(v[k],target.get(k))
		return target

	elif t == TYPE_ARRAY:
		target.resize(max(len(target),len(v)))
		for i in range(len(v)):
			target[i] = deep_copy(v[i],target[i])
		return target

	elif t == TYPE_OBJECT:
		if v.has_method("duplicate"):
			return v.duplicate()
		else:
			print("Found an object, but I don't know how to copy it!")
			assert(false)
			return v

	else:
		# Other types should be fine,
		# they are value types (except poolarrays maybe)
		return v
	
# compares 2 object and returns true if all fields recursively are the same
func compare(a,b):
	var type = typeof(a)
	if(typeof(a) != typeof(b)):
		return false
		
	if a == b:
		return true
	
	if(type == TYPE_OBJECT):
		if(a.get_type() != b.get_type()):
			return false
		for i in a.get_property_list():
			if not compare(a.get(i),b.get(i)):
				return false
		return true
	if(type == TYPE_ARRAY):
		if a.size() != b.size():
			return false
		for i in range(a.size()):
			if not compare(a[i],b[i]):
				return false
		return true
	if(type == TYPE_DICTIONARY):
		var kA = a.keys()
		var kB = b.keys()
		if not kA.size() == kB.size():
			return false
		if not a.has_all(kB):
			return false
		for k in a:
			if a[k] != b[k]:
				return false
		return true
	
	return a == b
		
		#
	
# Find an identical object in the array, that is not necessarily the same, but can be.
func array_find_copy(array,copy):
	for i in array:
		if(compare(i,copy)):
			return i
		
	
# Join 2 dictionaries into a new one, checked overlap prioritize the first
func join_dictionaries(d1:Dictionary,d2:Dictionary):
	var d3 = d2.duplicate()
	for k in d1.keys():
		d3[k] = d1[k]
	
	return d3
	
# Same as join_dictionary, but will merge all dictionaries within the dictionaries as well (collation). Unlike join_dictionary, this will modify the first parameter (largeDict)
# If smallDict has a different value under the same key as largeDict, and the value is not a dictionary or array, it gets ignored. Arrays get merged via append.
func deep_join_dictionaries(largeDict:Dictionary,smallDict:Dictionary):
	for k in smallDict.keys():
		if not largeDict.has(k):
			largeDict[k] = smallDict[k]
		elif typeof(largeDict[k]) == TYPE_DICTIONARY:
			deep_join_dictionaries(largeDict[k],smallDict[k])
		elif typeof(largeDict[k]) == TYPE_ARRAY:
			largeDict[k] += smallDict[k]
			
	
func get_parent_path(path:String):
	var last_index = -1
	var length = path.length()
	for i in range(length):
		if path[i] == '/' and i != length-1:
			last_index = i
	var parent_path = path.left(last_index)
	return parent_path
		

func get_random(array_or_dict):
	if array_or_dict is Array:
		return array_or_dict[int(randf_range(0,array_or_dict.size()))]
	elif array_or_dict is Dictionary:
		return array_or_dict.values()[int(randf_range(0,array_or_dict.size()))] # Is this faster than getting all keys and looking up the right key?
	else:
		push_error('Tried to get random from ' + array_or_dict + '.\n Only Arrays or Dictionaries allowed. Returning null')
		return null

func find_all_parent_classes(c_name:String,result = []):
	result.append(c_name)
	
	var parent_c_name = ClassDB.get_parent_class(c_name);
	
	if parent_c_name != "":
		return find_all_parent_classes(parent_c_name,result)
	else:
		return result;
	

func find_closest_parent_of_type(node:Node,parent_type:String)->Node:
	
	if node == null:
		return null;
		
		
	if node.has_method("get_parent_classes") && node.get_parent_classes().has(parent_type) or node.is_class(parent_type):
		#print("Returned ", node)
		return node;
		
	#else:
		#print("Failed ", node.name , " vs ", parent_type)
		
	
	return find_closest_parent_of_type(node.get_parent(),parent_type);

func get_entire_hierarchy(node:Node,result = []):
	result.append(node);
	for child in node.get_children():
		get_entire_hierarchy(child,result);
		
	return result;

var expressions = {}

# New godot expression system. It runs independently. (No singletons etc)
# Still very expensive! Therefore all expressions are cached indefinitely.
func run_expression(code,params = [],base_instance = null):
	var expression_variations = expressions.get(code,{})
	
	var expression = expression_variations.get(params.keys(),null)
	if expression == null:
		expression = Expression.new();
		expression.parse(code,params.keys());
		expression_variations[params.keys()] = expression;
		expressions[code] = expression_variations;
	
	
	return expression.execute(params.values(),base_instance,true)

var scripts = {}


# A very expensive way to run gd script from strings. Primarily used in the dialogue system and other placces, where quick and dirty compact code snippets are required 
func run_script(input, params = {}):
	if input == null:
		return
		
	var script_variations = scripts.get(input,{})
	
	var obj = script_variations.get(params.keys(),null)
	if obj == null:
		var script = GDScript.new()
		var param_string = array_join(params.keys(),",")
		var code = "func eval(" + param_string + "):\n	" + input.replace("\n","\n	")
		script.set_source_code(code)
		script.reload()
		
		obj = RefCounted.new()
		#var obj = Node.new() #So we can call get_node
		
		obj.set_script(script)
		script_variations[params.keys()] = obj;
		scripts[input] = script_variations;
		

	
	#print('RUNNING ', input)
	
	
	
	return obj.callv("eval",params.values());
#	return# resources free themselves
#	add_child(obj)
#
#	var ret_val = obj.eval()
#	remove_child(obj)
#
#	return ret_val

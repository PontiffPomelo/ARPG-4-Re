extends Node2D
#class_name SceneManager

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player:Player

var worlds = {};
var packed_scenes : Dictionary = {}
var scenes = {}
var active_scene
var active_scene_name
var _is_loading = false
var _is_switching_scenes = false

var _scene_object_hooks = {} # List of scene objects by path that are tracked via Hooks and GameData.data

var expression = Expression.new()

func _init():
	player = load("res://Prefabs/Player.tscn").instantiate()
	player.owner = self
	
	ResourceManager.load_resources(worlds,'res://Resources/Worlds','.tres')
	packed_scenes = {}
	print('INITIALIZING SCENE MANAGER')
	ResourceManager.load_resources(packed_scenes,'res://Scenes','.tscn')
	var first_scene : String = packed_scenes.keys()[0]
	print("Loaded " + first_scene)
	
	if packed_scenes.get(first_scene) == null:
		assert(false);
	
	load_scene(first_scene)
	
	#GameData.set_temp('SceneManager',self)
	#GameData.register_set_global_hook('world_size',self,"update_world_scale")
	#GameData.register_set_data_hook('active_scene',self,"update_active_scene")
	#GameData.register_set_data_hook('scene_data',self,"update_scene_data")

func clear_world():
	print('LOADING SCENE (RESET)')
	clearScenes()
	scenes = {}
	_scene_object_hooks = {}
	#GameData._data_hooks['children']['scene_data'] = {'children':{'Player':GameData._data_hooks['children']['scene_data']['children']['Player']},'hooks':[]}
	GameData.remove_set_data_hook('scene_data',self,"update_scene_data") # Just to be sure it doesnt exist already
	GameData.register_set_data_hook('scene_data',self,"update_scene_data")

func load_world(name:String,scene_name:String="",reset_position = false):
	clear_world();
	
	var world : SceneWorld = worlds.get(name);
	if scene_name == "":
		scene_name = world.default_scene;
		
	for scene in world.scenes:
		_load_scene(scene)
		
	if scene_name == null:
		load_scene(scene_name,"" if reset_position else null);
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	#load_scene(GameData.get_data("active_scene"))
	pass 
	
# Make sure all hooks are properly set up. For that, remove_at the current scene, and add it again. This will ensure all scenes run synchronize_scene before loading, which syncs them with the new GameData.data.scene_data
func on_load():
	load_world(GameData.get_data("active_world"),GameData.get_data("active_scene"))

# Active scene just changed. Check if it matches, update otherwise
func update_active_scene(_path):
	var cur_active_scene = GameData.get_data('active_scene')
	if cur_active_scene != active_scene_name:
		load_scene(cur_active_scene,null)

func get_node(path:NodePath):
	
	var scene_name = path.get_name(0)
	
	if scene_name:
		if super.has_node(path):
			return super.get_node(path)
		if scene_name in scenes or scene_name in packed_scenes:
			if str(path) == scene_name:
				return get_scene(NodePath(scene_name))
			else:
				return get_scene(NodePath(scene_name)).get_node(str(path).substr(scene_name.length()+1))
		return null
			
	if str(path) == '.' or str(path) == '':
		return self
	return super.get_node(path)
	
	
	
func get_local_path(node_or_path):
	var path : String = ''
	if node_or_path is Node:
		var node : Node = node_or_path
		if not node.is_inside_tree():
			while(node != null):
				path = str(node.name) + '/' + path if path != '' else node.name
				node = node.get_parent()
			return path
		path = node.get_path()
	else:
		path = node_or_path
	var offset = str(get_path()).length()
	return str(path).substr(offset+1)
		

func has_node(path:NodePath):
	var scene_name = path.get_name(0)
	return (scenes.has(scene_name) or packed_scenes.has(scene_name)) and ( scene_name == path or get_scene(NodePath(scene_name)).has_node(str(path).substr(scene_name.length()+1)) ) or super.has_node(path)

func get_scene(scene_name : String = ""):
	if scene_name.is_empty():
		return active_scene
	elif super.has_node(scene_name):
		return super.get_node(scene_name)
	else :
		var scene = scenes.get(scene_name,null)
		if scene == null:
			scene = _load_scene(scene_name)
		return scene

# Get the scene the given node is in
func get_node_scene(node):
	var parent = node.get_parent()
	if parent == null:
		return node if node.name in scenes or node in get_children() else null
	if parent == self:
		return node
	return get_node_scene(parent)

func _load_scene(scene_name) :
	print('LOADING STARTED ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
	print(scene_name)
	print(packed_scenes.keys()[0] == scene_name)
	_is_loading = true # This way any node can find out if it was created during scene load or manually at runtime. This can determine whether it overrides GameData.data or defers to GameData.data for its properties.
	var scene = packed_scenes.get(scene_name).instantiate()
	_is_loading = false
	print('LOADING DONE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
	
	#NavigationManager.load_scene(scene)
	
	scenes[scene_name] = scene
	return scene

func load_scene(path:String,positionMarker=""):
	#printerr('load scene ',path)
	#print_stack()
	clearScenes();
	make_scene_active(path);
	if positionMarker != null:
		position_player(positionMarker)

# Position player within active scene
func position_player(position_marker_path=""):
	print('positioning player')
	var positionMarker:Node2D = active_scene.get_node(position_marker_path) if (position_marker_path and position_marker_path != "") else active_scene.get_node('./EntryPoint') 
	
	if positionMarker == null:
		positionMarker = active_scene.get_node('./EntryPoint') 
	
	if positionMarker and player:
		var cam:Node = player.get_node('./Camera2D')
		player.set_global_position(positionMarker.get_parent().to_global(positionMarker.position))
		cam.align()		
		cam.reset_smoothing()
		#print('set player position')

func make_scene_active(path:String):
	_is_switching_scenes = true
	var scene = get_scene(path)
	if scene == null :
		push_error('Tried to load null scene')
		return #
	scene.add_child(player)
	assert(scene != null)
	active_scene = scene
	active_scene_name = path
	call_deferred('_add_active_as_child')
	
	print('SETTING ACTIVE SCENE ' , path)
	GameData.active_scene = path

func _add_active_as_child():
	#var size = get_parent().scale # Bug : Only occurs in release builds : Colliders won't scale with added scene if parent is scaled.
	#get_parent().scale = Vector2(1,1)
	#active_scene.scale = Vector2(1,1)
	self.add_child(active_scene,true);
	active_scene.set_owner(self)
	#get_parent().scale = size
	#update_world_scale()
	print('uws')
	_is_switching_scenes = false
	
func clearScenes():
	if not active_scene:
		return
	remove_child(active_scene)
	#for child in get_children(): # rename for the time being, so late free() calls won't be a bother
	#	child.name += "_deprecated"
		
	#for i in range(0, get_child_count()):
	#	get_child(i).queue_free();
	
	active_scene = null
	active_scene_name = null


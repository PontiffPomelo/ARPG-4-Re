extends ScaleChildrenToFitContainer
class_name JSON_Sprite
# @tool 

@export_file var path : String : # (String, FILE, "*.json")
	set(v):
		path = v
	
		offset_container = get_node("OffsetContainer")
		if is_queued_for_deletion() or offset_container == null:
			print('no offset container')
			return
			
		if not FileAccess.file_exists(v):
			print('file doesn\'t exits')
			return
		
		_clear_layers()
		var file = FileAccess.open(v, FileAccess.READ)
		var text = file.get_as_text()
		var test_json_conv = JSON.new()
		test_json_conv.parse(text)
		var result = test_json_conv.get_data()
		
		if result.get("error") == OK:  # If parse OK
			_assign_layers(result.result)
		else:  # If parse has errors
			print("Error: ", result.get("error"))
			print("Error Line: ", result.get("error_line"))
			print("Error String: ", result.get("error_string"))
			
@export var mirrored: bool = false

@onready var offset_container = $OffsetContainer

func get_class():
	return "JSON_Sprite"

	
func _clear_layers():
	clear_children()
		
func _assign_layers(jsonData):
	for layer in jsonData.get("layers"):
		add_sprite(layer)
	
func add_sprite(layer):
	var pos = layer.position
	var layer_path = layer.path
	#print('adding ', layer)
	var image = load("res://images/" + layer_path)
	var child = TextureRect.new()
	offset_container.add_child(child)
	child.set_owner(offset_container)
	child.set_meta('z-offset',pos[2])
	child.texture = image
	child.position = Vector2(pos[0],pos[1]) if not mirrored else Vector2(3840 - pos[0],pos[1]) 
	if mirrored:
		child.scale.x = -1;
	child.name = layer.name
	
	var children = offset_container.get_children()
	var max_domain = children.size()-1
	var min_domain = 0
	while(max_domain>min_domain):
		var i = min_domain + ceil((max_domain-min_domain)/2)
		var z_offset = children[i].get_meta('z-offset')
		if z_offset > pos[2]:
			max_domain = i-1
		elif z_offset < pos[2]:
			min_domain = i+1
		else: # equivalent
			min_domain = i
			
		
	
	offset_container.move_child(child,min_domain)
	#print('moved to ', min_domain)
	
	
func clear_children():
	for child in offset_container.get_children():
		child.free()

func _ready():
	path = path;
	super._ready()


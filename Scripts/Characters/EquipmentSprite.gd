extends Sprite2D
class_name EquipmentSprite
# @tool


const MATERIAL = preload("res://Resources/Materials/Sprite_Highpass.material")

var has_changed : bool = true

@export var atlas: String = "Hair/plain/white" :
	set(v):
		if(v == atlas ):
			return
		atlas = v
		has_changed = true
		get_texture()
		queue_redraw()
		
@export var __array_selector_atlas: Array = ['a','b','c']
signal __array_selector_atlas_changed;

@export var tint: Color = Color(1,1,1,1) :
	set(v):
		tint = v
		queue_redraw()
		

@export var priority: float = 0.0 :
	set(v):
		if(v == priority):
			return
		priority = v
		queue_redraw()
		
@export var highpass: float = 0.5 :
	set(v):
		highpass = v
		queue_redraw()
		
@export var color_low: Color = Color(1,1,1,1) :
	set(v):
		color_low = v	
		queue_redraw()
		
@export var color_high: Color = Color(1,1,1,1) :
	set(v):
		color_low = v	
		queue_redraw()


func get_class():
	return "EquipmentSprite"
	
func get_texture():
	
	if(not has_changed):
		return texture
		
	var playerSprite = get_parent()
	
	if not playerSprite :
		#print('no parent')
		return
	
	has_changed = false
	
	if(atlas == null):
		#print("no atlas")
		return texture
		
	var gender = playerSprite.gender
	var genders = playerSprite.__array_selector_gender
	var gender_index = genders.find(gender)
	
	var newtex
	for i in range(genders.size()):
		gender = genders[(gender_index+i) % genders.size()] # try others afterwards
		var atlasPath = "res://Assets/Images/CharacterCreator/Body/"+gender+'/'+atlas+'.png';
		if FileAccess.file_exists(atlasPath):
			newtex = load(atlasPath)
			break
		else:
			pass
			#print('File doesn\'t exist : ' + atlasPath)
		
	if(newtex == texture):
		return texture
	if(newtex == null):
		print('texture not found' + "res://images/CharacterCreator/body/"+gender+'/'+atlas+'.png')
	texture = newtex
	
	return texture
	
func on_body_texture_update():
	__array_selector_atlas = get_parent().valid_equipment
	has_changed = true
	get_texture()
	pass
	
func on_params_changed():
	var playerSprite = get_parent()
	assert(playerSprite != null)
	var parent_class = playerSprite.get_class()
	if parent_class != "PlayerSprite":
		print(name)
		return
	vframes = playerSprite.vframes
	hframes = playerSprite.hframes
	frame = playerSprite.frame
	queue_redraw()

func idled_frame():
	pass

func _ready():
	
	var playerSprite = get_parent()
	playerSprite.connect('update_body_texture',Callable(self,'on_body_texture_update'))
	playerSprite.connect('update_params',Callable(self,'on_params_changed'))
	material = MATERIAL.duplicate()
	
	await RenderingServer.frame_pre_draw # Bug, needs half a frame for the material to load correctly after duplicate
	
	material.set_shader_parameter("highpass", highpass)
	material.set_shader_parameter("color_high", color_high)
	material.set_shader_parameter("color_low", color_low)
	on_params_changed()
	
	
func _draw():
	
	material.set_shader_parameter("highpass", highpass)
	material.set_shader_parameter("color_high", color_high)
	material.set_shader_parameter("color_low", color_low)
	
	
	#if(not texture == null):
		#var source_width = texture.get_width()/vframes;
		#var source_height = texture.get_height()/hframes

		#texture.draw_rect_region(self, Rect2(-source_width/2,-source_height/2,source_width,source_height),Rect2(frame_coords[0]*source_width,frame_coords[1]*source_height,source_width,source_height), tint)
		#draw_texture_rect_region(texture, Rect2(-source_width/2,-source_height/2,source_width,source_height),Rect2(frame_coords[0]*source_width,frame_coords[1]*source_height,source_width,source_height), tint)
	


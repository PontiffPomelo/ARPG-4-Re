extends Node2D
class_name PlayerSprite
@tool

@export var __array_selector_gender := ["Male", "Female","Universal","Child","Cat","Dog","Pregnant"]
signal __array_selector_gender_changed;
@export var __array_selector_race: Array = ["Male", "Female", "Child","Undefined"]
signal __array_selector_race_changed;

@export var gender: String :
	set(value):
		if gender == value:
			return
		print('set ', value)
		__array_selector_race = []
		var list = Helper.list_files_in_directory("res://Assets/Images/CharacterCreator/Body/" + value,'.png',[],false);
		var offset = ("res://Assets/Images/CharacterCreator/Body/" + value + '/').length()
		for path in list:
			__array_selector_race.append(path.substr(offset,path.length()-offset-4))
			
		gender = value
		changed = true
		if not race in __array_selector_race:
			race =  __array_selector_race[0];
		__array_selector_race_changed.emit()
		queue_redraw()
		print("REDRAW")
		
		
@export var race: String :
	set(value):
		race = value
		changed = true
		queue_redraw()

var _body

var bodyTexture:Texture2D
var changed = true
var colorChanged = true
var paramsChanged = true
@export var bodyColor : Color :
	set(value):
		if bodyColor == value:
			return
		bodyColor = value
		colorChanged = true
		queue_redraw()
		
signal update_body_texture()
signal update_params()
@export var vframes: int :
	set(v):
		if vframes == v:
			return
		vframes = v
		paramsChanged = true
		queue_redraw()
		
@export var hframes: int :
	set(v):
		if hframes == v:
			return
		hframes = v
		paramsChanged = true
		queue_redraw()
@export var frame : int :
	set(v):
		if(frame == v):
			return
		frame = v
		paramsChanged = true
		queue_redraw()


var valid_equipment = []
	#changed

func get_class():
	return "PlayerSprite"

func body():
	if not _body:
		_body =  $BodySprite if has_node("BodySprite") else null
	
	if not _body:
		
		var scene = get_tree().get_edited_scene_root() if Engine.is_editor_hint() else self
		_body = Sprite2D.new()
		_body.set_name('BodySprite')
		add_child(_body,true)
		_body.set_owner(scene)
	
	return _body

#export var test # (Array,MyResource)
	
	
func calculate_valid_equipment():
	pass
	#if gender != null:
		#valid_equipment = ResourceManager.get_character_sprites()[gender];

func _ready():
	if Engine.is_editor_hint():
		return
		
	updateBodyTexture()


func _draw():
	# body should always be available checked draw, but not always in setget, which is why we use change-variables for the most part
	var body = body()
	
	if colorChanged:
		body.modulate = bodyColor
		body.queue_redraw()
		colorChanged = false
	
	if paramsChanged:
		body.frame = frame
		body.vframes = vframes
		body.hframes = hframes
		body.frame = frame
		body.queue_redraw()		
		emit_signal('update_params')
		paramsChanged = false
		
	if changed:
		updateBodyTexture()
		changed = false
		
		
	
	#var hasDrawnBody = false
	#draw_anim_sprite(bodyTexture,bodyColor)
	#for overlay in overlays:
	#	if not hasDrawnBody && overlay.priority >= 0 :
	#		draw_anim_sprite(bodyTexture,bodyColor)
	#		hasDrawnBody = true
	#	var texture = overlay.get_texture(self)
	#	draw_anim_sprite(texture,overlay.tint,overlay.highpass,overlay.color_high,overlay.color_low)
		
		
	#draw_texture(bodyTexture, Vector2(),bodyColor)
	
func updateBodyTexture():
	bodyTexture = load("res://Assets/Images/CharacterCreator/Body/"+gender+'/'+race+'.png')
	var body = body()
	body.texture = bodyTexture
	body.queue_redraw()
	calculate_valid_equipment()
	emit_signal('update_body_texture')
	
	


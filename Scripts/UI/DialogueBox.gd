extends Control
class_name DialogueBox

@onready var textLabel:RichTextLabel = $DialogueBox/DialogueContent;
@onready var nameLabel = $DialogueBox/ColorRect2/NameLabel;
@onready var choiceButton = $ChoiceButtons/ChoiceButton;
@onready var choiceButtonContainer = $ChoiceButtons;
@onready var timer_letter = $DialogueBox/Timer_Next_Letter;
@onready var timer_skip = $DialogueBox/Timer_Skip;
@onready var character_left:JSON_Sprite = $Canvas/Character_Left;
@onready var character_left_transition:Transitioner = $Canvas/Transitioner_Left;
@onready var character_right:JSON_Sprite = $Canvas/Character_Right;
@onready var character_right_transition:Transitioner = $Canvas/Transitioner_Right;
@onready var centered_image:JSON_Sprite = $Canvas/Centered_Image;
@onready var centered_image_transition:Transitioner = $Canvas/Transitioner_Center;
@onready var transitioner:Transitioner = $Transitioner_DialogueSystem;
@onready var click_catcher : Button = $ClickCatcher

@onready var choiceButtons = [choiceButton]


# Each dialogue needs :
# 1) Text
# 2) Name of the person, if blank, same as before
# 3) Pose/Body, use default or last used if blank
# 3.5) Expression (kept separately from overlays because it's used a lot')
# 4) Overlays : Accessories,
# 5) Animations : Premade animations, referenced by name
# 6) Expressions : Code that runs after finishing the dialogue page. This can only access Singletons though.

var dialogue = ResourceManager.dialogues

var open = false;
var visibleCharacters = 0;


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("load")
	transitioner.hide()
	character_left_transition.hide()
	character_right_transition.hide()
	centered_image_transition.hide()
	#GameData.register_set_data_hook("dialogueStates",self,"updateDialogueStateCache")
	#GameData.register_set_global_hook("skip_dialogue_speed",self,"update_skip_timer")
	#GameData.register_set_global_hook("dialogue_playback_speed",self,"update_letter_timer")
	var dialogueStates = GameData.dialogue_states
	if dialogueStates.size() != 0 :
		openDialogueWindow();
	
	choiceButton.hide()
	click_catcher.show() # Disabled in editor so it doesn't get in the way
	
	fill_dialogue_data()
	#start_dialogue('test_dialogue');

var character_delta_overhead = 0

func _process(delta):
	
	if(!open or %UI.any_menu_open()):
		return;
		
	if Input.is_action_just_released("dialogue_rollback") :
		prevPage(); 
		
	if Input.is_action_just_released("dialogue_skip_soft") or timer_skip.is_stopped() and Input.is_action_pressed("shift") :
		if(GameData.get_global('skip_unread') or is_page_read()):
			nextPage(true); 
		
	if Input.is_action_just_released("confirm") or Input.is_action_just_released("ui_continue") : 
		consider_next_page()
		
	character_delta_overhead += delta
	
	
	if not getDialogueState() or visibleCharacters >= getMaxCharacters():
		return
	
	
	var charData = getDialogueCharacterData()
	var time_per_character = (charData.text_speed if charData else 1) * GameData.get_global('dialogue_playback_speed')/100.0
	var new_character_count = character_delta_overhead / time_per_character
	if new_character_count == 0:
		return
	character_delta_overhead -= new_character_count * time_per_character
	visibleCharacters += new_character_count
	
	updatePageText()

func show():
	open = true
	print('showing')
	super.show()
	transitioner.run(1)

func hide():
	open= false
	print('hiding')
	transitioner.run(0,self,"_hide_done",[])
	pass

func _hide_done():
	super.hide()

func update_skip_timer(_path=null):
	var v = GameData.get_global("skip_dialogue_speed")/100.0
	timer_skip.stop()
	if v != 0:
		timer_skip.wait_time = v
		timer_skip.start()

#func update_letter_timer(v):
#	timer_letter.stop()
#	if v != 0:
#		timer_letter.wait_time = v
#		timer_letter.start()

func reset():
	pass

func on_load():
	updateDialogueStateCache()


# Fill dictionary with default value if not defined for the specified key
func set_if_null(object,key,defaultValue):
	if not object.has(key) :
		object[key] = defaultValue

# Fill the dialogue dictionary so that all values are always assigned, even if they were left blank ( they will copy previous values for the same field )
func fill_dialogue_data() :
	var default_dialogue_page = {
		"text" : "<<< Error : No text supplied. >>>",
		"color": 0xffffffff,
		"name": "<<<Null>>>",
		"expression" : "DefaultExpression",
		"pose": "default",
		"overlays":[],
		"eval":null,
		"flags":[],
	}
	for i in dialogue.keys():
		var previous_dialogue_pages = {} # by character name
		var previous_dialogue_page = default_dialogue_page # by character name
		var dialogue_item = dialogue[i].get("pages",[])
		for l in range(dialogue_item.size()):
			var page = dialogue_item[l]
			
			previous_dialogue_page = previous_dialogue_page if not page.has("name") else (previous_dialogue_pages[page["name"]] if previous_dialogue_pages.has(page["name"]) else default_dialogue_page )
			var _name = page['name'] if page.has('name') else previous_dialogue_page['name']
			if ResourceManager.characters.has(_name) :
				var new_color = ResourceManager.characters.get(_name).text_color
				set_if_null(page,"color",new_color)
			for k in ["expression","pose","name"]:
				set_if_null(page,k,previous_dialogue_page[k])
			previous_dialogue_pages[_name] = page
			previous_dialogue_page = page
	pass

var path = 'res://dialogues.json'

# Load Dialogue file from FileSystem
func loadDialogues() :
	
	if not FileAccess.file_exists(path):
		reset_data()
		return
	
	var file = FileAccess.open(path, FileAccess.READ);
	var text = file.get_as_text();
	
	var test_json_conv = JSON.new()
	test_json_conv.parse(text);
	var data = test_json_conv.get_data()
	
	
	return data;

func reset_data():
	pass

func updateDialogueStateCache(_path=null):
	cached_dialogue_state = GameData.get_data("dialogueStates",[]);
	if cached_dialogue_state == null: # Hotfix, find out how this state could ever happen?!
		cached_dialogue_state = []
	if cached_dialogue_state == null or cached_dialogue_state.size() == 0:
		closeDialogueWindow()
	else:
		# Handles display only, no sidechaining
		# Could be next page 
		# Could be same page
		# Could be prev page
		# Could be new dialogue
		# Could be fallback from closed dialogue
		openDialogueWindow()
		updatePage()
var cached_dialogue_state

func getDialogueStates():
	if cached_dialogue_state != null:
		updateDialogueStateCache()
	return cached_dialogue_state

func getDialogueState():
	if cached_dialogue_state != null:
		updateDialogueStateCache()
	return cached_dialogue_state.back() if cached_dialogue_state.size() > 0 else null

func pushDialogueStateChanges():
	GameData.set_data("dialogueStates",cached_dialogue_state);	

func getDialogueData():
	return dialogue.get(getDialogueState()["dialogueName"],{});

func getChoiceData():
	var res = getDialogueData().get("choices",[])
	var result = []
	for choice in res:
		if not choice.get('requirements') or Helper.run_script(choice.get('requirements')):
			result.append(choice)
	return result if result else [] 

func getAutoChoiceData():
	var res = getDialogueData().get("auto_choices",[])
	var result = []
	for choice in res:
		if not choice.get('requirements') or Helper.run_script(choice.get('requirements')):
			result.append(choice)
	return result if result else [] 

func getDialoguePageData():
	if getDialogueData().get("pages",[]).size() == 0 :
		return {"text":""}
	return getDialogueData().get("pages",[])[getDialogueState()["page"]];

func getDialogueCharacterData():
	var character = getDialoguePageData().name
	var charData:CharacterData = ResourceManager.characters.get(character)
	return charData;

func getMaxCharacters():
	var pd = getDialoguePageData()
	if 'text' in pd:
		return pd['text'].length()
	return 0

# Is the given dialogue valid? As in, does it have any pages, or valid choices, or valid autochoices? (valid as in requirements fulfilled)
# Only returns true if its certain the dialogue does not have any sideeffects. (eval,flags, etc)
func is_dialogue_valid(dialogue_name):
	var dialogue_data = ResourceManager.dialogues.get(dialogue_name,null)
	if dialogue_data == null :
		return false
		
	var pages = ResourceManager.dialogues[dialogue_name].get('pages',null)
	if pages != null and pages.size() > 0:
		return true
	
	var choices = ResourceManager.dialogues[dialogue_name].get('choices',null)
	if choices != null and choices.size() > 0:
		for choice in choices:
			if is_valid(choice):
				return true
				
	choices = ResourceManager.dialogues[dialogue_name].get('auto_choices',null)
	if choices != null and choices.size() > 0:
		for choice in choices:
			if is_valid(choice):
				return true
		

# Load a new dialogue from the json file by name.
func start_dialogue(dialogueName):
	print("Starting dialogue ", dialogueName);
	if not is_dialogue_valid(dialogueName):
		print('Dialogue not valid ' , dialogueName)
		return
	if getDialogueStates().size() == 0:
		clear_page()
	getDialogueStates().append({"page":0,"dialogueName":dialogueName});
	pushDialogueStateChanges();
	
	load_page()
	
	if not open:
		openDialogueWindow()
	
	if getDialogueData().get("pages",[]).size() == 0: # No pages
		displayChoices()
		return
	
	updatePage();

func hideChoices():
	for i in range(choiceButtons.size()):
		choiceButtons[i].hide()

func _priority_comparison(a,b):
	return a.get('priority',0) < b.get('priority',0)

func displayChoices():
	
	choiceButtonContainer.show()
	var _choiceData = getChoiceData()
	var dialogue_data = getDialogueData()
	var choiceData = []
	for cd in _choiceData:
		if is_valid(cd):
			choiceData.append(cd)
	
	if(choiceData.size() == 0):
		return auto_choose()
	else :
		var auto_choices = getAutoChoiceData()
		for cd in auto_choices:
			if is_valid(cd) and cd.get("label",false): # Not all auto choies have labels. Those that don't can't be displayed
				choiceData.append(cd)
		if dialogue_data.get("back_button",false):
			choiceData.append({"label":dialogue_data.get("back_button"),"priority":-1})
	
	choiceData.sort_custom(Callable(self,"_priority_comparison"))
	
	while choiceButtons.size() < choiceData.size(): # make sure enough buttons exists
		#var scene = get_tree().get_edited_scene_root() if Engine.is_editor_hint() else self
		var newchoice = choiceButton.duplicate()
		choiceButtons.append(newchoice)
		choiceButtonContainer.add_child(newchoice)
		newchoice.set_owner(choiceButtonContainer)
		
	var viewport_size = get_viewport().size
	var button_offset = choiceButton.size.y + 16
	var y = viewport_size.y/2 - choiceData.size() * button_offset / 2
	var x = viewport_size.x/2
	for i in range(choiceData.size()):
		var button = choiceButtons[i]
		var choice = choiceData[i]
		button.show()
		button._set_choice(choice)
		button.position.y = y + i * button_offset
		button.position.x = x - button.size.x/2
		
	return choiceData.size()>0
		
		
func is_valid(choice):
	if choice.has('requirements') and not Helper.run_script(choice.requirements):
		return false
	if choice.has('flag_requirements'):
		for flag in choice.flag_requirements:
			if not GameData.get_data(flag) or GameData.get_data(flag) <= 0 :
				return false 
		
	return true

# Returns true if an auto choice was triggered, false otherwise.
func auto_choose():
	var choices = getAutoChoiceData()
	
	if not choices:
		return false
		
	var valid_choices = []
	var priority = -(1<<30) # Negative infinity is not defined in godot
	# sort by priority and requirements fulfilled
	for choice in choices:
		if choice.get('priority',0) >= priority and is_valid(choice):
			if choice.get('priority',0) > priority:
				valid_choices = []
				priority = choice.get('priority',0)
			valid_choices.append(choice)
			
	if valid_choices.size() == 0 :
		return false
			
	var choice = valid_choices[floor(randf_range(0,1) * valid_choices.size())]
	_on_ChoiceButton_pressed(choice)
	return true

func finishDialogue():
	if not displayChoices():
		getDialogueStates().pop_back();
		pushDialogueStateChanges();
	else:
		return
	
	if getDialogueStates().size() == 0 :
		closeDialogueWindow();
	else:
		updatePage();

func closeDialogueWindow():
	if not open:
		return
	print('CLOSE')
	GameData.set_temp("player_movement_blocked",GameData.get_temp("player_movement_blocked")-1)
	hide();
	open = false;

func openDialogueWindow():
	if open :
		return
	print('OPEN')
	GameData.set_temp("player_movement_blocked",GameData.get_temp("player_movement_blocked")+1)
	show();
	updatePage()
	update_choices()
	open = true;
	

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
	
func get_actor_color():
	var color = getDialoguePageData().get("color")
	return color if color else 0xffffffff
	
	
func _try_assign_pose(comps,char_target,pose,expression,camera):
	var body_comp = comps[pose]
	if body_comp and expression:
		#print('expression is ' , expression)
		body_comp = body_comp.get(expression,null) 
		
		if body_comp: 
			if camera == null:
				camera = body_comp.keys()[0];
			if body_comp.get(camera):
				char_target._assign_layers(body_comp.get(camera))
				#print('assigned ', expression)
			else:
				print('expression ' , expression , ' not found ' , camera)
	
func _load_composition(target:JSON_Sprite,pageData):
	var character = pageData.get("name") 
	if character:
		var charData:CharacterData = ResourceManager.characters.get(character) # Constant data for character, such as default pose, name etc
		if charData != null and charData.compositions != null :
			var pose = pageData.get("pose")
			if not pose or not charData.compositions.has(pose):
				pose = charData.default_pose if charData.default_pose != '' else "Default"# Fallback to 'DefaultExpression, which GameData auto assigns if not existing', to the first expression that comes along
			
			var expression = pageData.get("expression")
			if not expression:
				expression = charData.default_expression if charData.default_expression else "DefaultExpression"# Fallback to 'DefaultExpression, which GameData auto assigns if not existing', to the first expression that comes along
			
			print('expression is ', expression)
			
			var camera = pageData.get("camera")
			if not camera:
				camera = "Default"# Fallback to 'DefaultExpression, which GameData auto assigns if not existing', to the first expression that comes along
			
			if target.has_meta('target_character') and target.get_meta('target_character') == character and target.has_meta('target_pose') and target.get_meta('target_pose') == pose and target.has_meta('target_expression') and target.get_meta('target_expression') == expression and target.has_meta('target_camera') and target.get_meta('target_camera') == camera:
				return # Skip unless something changed
				
			target.set_meta('target_character',character)
			target.set_meta('target_pose',pose)
			target.set_meta('target_expression',expression)
			target.set_meta('target_camera',camera)
			
			target._clear_layers()
				
			_try_assign_pose(charData.compositions,target,pose,expression,camera)
		else:
			print('NO CHAR DATA')
	else:
		print('NO CHARACTER')

func clear_page():
	character_left_transition.hide()
	character_right_transition.hide()
	centered_image_transition.hide()	
	textLabel.resized_text = ""
	nameLabel.text = ""
	pass;

func update_choices():
	
	if getDialogueState()["page" ] < (getDialogueData().get("pages",[]).size())-1 :
		hideChoices()
		return
		
	if getChoiceData().size() > 0:
		displayChoices()
	else :
		hideChoices()

func updatePageText():
	if getDialogueStates().size() > 0 and getDialogueData().get("pages",[]).size() != 0:
		var _pageData = getDialoguePageData()
		#textLabel.resized_text = Helper.parse_text(pageData.get("text"));
		textLabel.set_visible_characters(visibleCharacters);

# Show text, character image and choices
# Does NOT need to update each time visible_characters changes 
func updatePage():
	if getDialogueStates().size() > 0 and getDialogueData().get("pages",[]).size() != 0:
		var pageData = getDialoguePageData()
		character_left_transition.hide()
		character_right_transition.hide()
	
		if not pageData.get('keep_centered'):
			#centered_image.hide()
			centered_image_transition.hide()	
		textLabel.resized_text = Helper.parse_text(pageData.get("text")); # Parse {{{...}}} insert tags (code fragments), eg {{{return str(2-1)}}}
		textLabel.set_visible_characters(visibleCharacters);
		
		
		
		if 'centered_composition' in pageData:
			centered_image.show()
			centered_image_transition.show()				
			var comp = pageData['centered_composition']
			_load_composition(centered_image,comp)
		
		textLabel.modulate =  get_actor_color();
		var character = pageData.get("name")
		nameLabel.text = str(character) 
		if character:
			# Only do this checked changing page
			var char_target
			var char_target_transition
			if character == 'Lily' or character == 'MC' or character == 'You':
				char_target = character_left
				char_target_transition = character_left_transition
			else:
				char_target = character_right
				char_target_transition = character_right_transition
				
				
			
				
			var charData:CharacterData = ResourceManager.characters.get(character) # Constant data for character, such as default pose, name etc
			if not charData:
				return;
			var comps = ResourceManager.characters.get(charData.pose_name)
			if comps:
				comps = comps.compositions
			else:
				comps = charData.compositions
			
			if charData and comps :
				char_target_transition.show()
				
				var pose = pageData.get("pose")
				if not pose or not comps.has(pose):
					pose = charData.default_pose if charData.default_pose != '' else "Default"# Fallback to 'DefaultExpression, which GameData auto assigns if not existing', to the first expression that comes along
				
				var expression = pageData.get("expression")
				if not expression:
					expression = charData.default_expression if charData.default_expression else "DefaultExpression"# Fallback to 'DefaultExpression, which GameData auto assigns if not existing', to the first expression that comes along

				var body = pageData.get("body")
				if not body:
					body = charData.default_body if charData.default_body else "DefaultBody"# Fallback to 'DefaultExpression, which GameData auto assigns if not existing', to the first expression that comes along
					
				var camera = pageData.get("camera")
				if not camera:
					camera = "Default"# Fallback to 'DefaultExpression, which GameData auto assigns if not existing', to the first expression that comes along
				
				var equipments = GameData.get_data('characters/'+charData.name+'/equipment',[])
				
				if char_target.has_meta('equipments') and char_target.get_meta("equipments") == str(equipments) and char_target.get_meta('target_character') == character and char_target.get_meta('target_pose') == pose and char_target.get_meta('target_expression') == expression and char_target.get_meta('target_camera') == camera:
					update_choices()
					return # Skip unless something changed
					
					
				char_target.set_meta('target_character',character)
				char_target.set_meta('target_pose',pose)
				char_target.set_meta('target_expression',expression)
				char_target.set_meta('target_camera',camera)
				char_target.set_meta('equipments', str(equipments))
				
				char_target._clear_layers()
				
				
				print('assigning ',pose,body,camera)
				_try_assign_pose(comps,char_target,pose,body,camera)
			
				if equipments:
					for slot in equipments:
						for item in equipments[slot]:
							var equipment = ResourceManager.items[item]
							# TODO : Camera3D
							_try_assign_pose(comps,char_target,pose,equipment.get_variation(slot).equipment_composition_name,camera)
#				var clothes_comp = comps[pose].get("Swimsuit")
#				if clothes_comp:
#					char_target._assign_layers(clothes_comp)
					
				_try_assign_pose(comps,char_target,pose,expression,camera)
			#GameData.characters[character].
			
		
	else:
		character_left_transition.hide()
		character_right_transition.hide()
		centered_image_transition.hide()
		print("0 SIZE")
		
	update_choices()
	
func set_page_read():
	var dialogueState = getDialogueState();	
	GameData.set_global("has_read_"+dialogueState["dialogueName"]+"_"+str(dialogueState["page"]),true)
	
func is_page_read():
	var dialogueState = getDialogueState();
	return GameData.get_global("has_read_"+dialogueState["dialogueName"]+"_"+str(dialogueState["page"]))
	
func load_page(forced=false):
	var pageData = getDialoguePageData();
	if pageData.has("eval"):
		Helper.run_script(pageData["eval"])
		if not open or getDialogueState() == null or getDialogueState().size() == 0:
			return # Eval closed this dialogue
	if not is_page_read():
		if pageData.has("flags"):
			for k in pageData['flags']:
				GameData.set_data(k,GameData.get_data(k,0)+1)
	visibleCharacters = pageData["text"].length() if forced else 0;
	character_delta_overhead = 0
	
	
	
	
	#if(dialogueState["page"] >= dialogueData.get("pages",[]).size()-1):
	#	displayChoices()
	pushDialogueStateChanges();
	
	updatePage();
	
func nextPage(forced=timer_letter.is_stopped()):
	set_page_read() # Previous page
	
	var dialogueState = getDialogueState();
	var dialogueData = getDialogueData()
	
	if dialogueData == null or dialogueData.size() == 0:
		return false
	
	var scroll = textLabel.get_v_scroll()
		
	if dialogueData.get("pages",[]).size() >= 1 and scroll and (scroll.value + scroll.page) < scroll.max_value:
		scroll.value += scroll.page
		return true
	elif dialogueState["page" ] < (dialogueData.get("pages",[]).size())-1:
		dialogueState["page"] += 1;
		scroll.value = 0
		print('loading page ',dialogueState["page"]);
		load_page(forced)
		
		return true
	elif getChoiceData().size() > 0 or getAutoChoiceData().size() > 0:
		displayChoices()
		return true
	return false
	
func prevPage():
	var scroll = textLabel.get_v_scroll()
	if scroll:
		scroll.value = 0
	hideChoices()
	var dialogueState = getDialogueState();
	if dialogueState["page"] > 0:
		var pageData = getDialoguePageData();
		if pageData.has("eval_undo"):
			Helper.run_script(pageData.eval_undo)
		dialogueState["page"] -= 1;
		visibleCharacters = getDialoguePageData()["text"].length();
		pushDialogueStateChanges();
		updatePage();
		return true
	return false
	
func showFullDialogue():
	visibleCharacters = getDialoguePageData()["text"].length();
	updatePage();


# Called checked click or enter. May show next page. May completely show current page instead
func consider_next_page():
	print('considering next page')
	if getDialogueState() == null:  # No possible dialogue if the box is in the process of hiding
		return
	if visibleCharacters < getDialoguePageData()["text"].length() :
			showFullDialogue();
	elif not nextPage() and getChoiceData().size() == 0:
		finishDialogue();

		

func _on_Timer_Skip_timeout():
	if(!open) :
		return;
	if Input.is_action_pressed("shift") and not GameData.get_temp('UI').any_menu_open():
		if(GameData.get_global('skip_unread') or is_page_read()):
			nextPage(true); 


func _on_ChoiceButton_pressed(choice):
	
	hideChoices()
	getDialogueStates().pop_back();
	pushDialogueStateChanges();
	
	if(choice.has("eval")):
		Helper.run_script(choice.eval)
	if choice.has("flags"):
		for k in choice['flags']:
			GameData.set_data(k,GameData.get_data(k,0)+1)
	
	if(choice.has("next") and choice.next and is_dialogue_valid(choice.next)):
		start_dialogue(choice.next)
	elif getDialogueStates().size() == 0 :
		closeDialogueWindow();
	else:
		updatePage();
	pass # Replace with function body.

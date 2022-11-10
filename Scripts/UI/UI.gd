extends CanvasLayer
class_name UI

@onready var interaction_message = $InteractionMessage
@onready var dialogue_system:DialogueBox = $DialogueSystem
@onready var escape_menu = $EscapeMenu
@onready var save_menu = $SaveMenu
@onready var quest_menu = $QuestMenu
@onready var skill_menu = $SkillMenu
@onready var inventory_menu = $InventoryMenu
@onready var context_menu = $ContextMenu
@onready var options_menu = $OptionsMenu
@onready var crafting_menu = $CraftingMenu
@onready var status_menu = $StatusMenu
@onready var notification_system = $NotificationSystem
@onready var wait_menu = $WaitMenu


@onready var menus = [inventory_menu,escape_menu,options_menu,save_menu] #,quest_menu,crafting_menu,status_menu,skill_menu,wait_menu

var is_paused = false # Game Time is frozen.
var controls_locked = 0


func _ready():
	Global.UI = self
	interaction_message.hide()
	notification_system.show() # Hidden in editor so it doesn't get in the way
	
	
func back():
	close_top()

func lock_controls():
	controls_locked += 1
	
	
func unlock_controls():
	controls_locked -= 1

func show_interaction_message(subject,index,count):
	interaction_message.text = "[center]" + (("[" + str(index+1) + '/' + str(count) + ']') if count > 1 else '') + subject.get_interaction_message() + "[/center]";
	interaction_message.show();
	
func hide_interaction_message():
	interaction_message.hide()
	
func reset():
	resume()
	dialogue_system.reset()
	save_menu.hide()
	escape_menu.hide()

func is_menu_on_top(menu):
	var children = get_children()
	var index = -1
	var last_menu_index = -1
	for i in range(children.size()):
		if children[i] == menu:
			index = i
		if children[i] in menus and children[i].visible:
			last_menu_index = i
			
	return last_menu_index == index

# Move the menu to the top layer by moving it's location in the parent's child array.
func move_menu_on_top(menu):
	var children = get_children()
	var last_menu_index = -1
	for i in range(children.size()):
		if children[i] in menus:
			last_menu_index = i
			
	move_child(menu,last_menu_index)

func toggle_menu(menu,paused=true):
	print("Toggling " + str(menu.name))
	if menu.visible:
		if not is_menu_on_top(menu):
			move_menu_on_top(menu)
			print("Not on top")
		else:
			menu.hide()
			print("Hide")
			if paused:
				consider_resume()
	else :
		if paused:
			pause()
		menu.show()
		move_menu_on_top(menu)
	
func toggle_main_menu():
	toggle_menu(escape_menu)
		
func toggle_save_menu():
	toggle_menu(save_menu)
		
func toggle_quest_menu():
	toggle_menu(quest_menu)
		
func toggle_inventory():
	toggle_menu(inventory_menu)
		
func toggle_options_menu():
	toggle_menu(options_menu)
		
func toggle_crafting_menu():
	toggle_menu(crafting_menu)
	
func toggle_status_menu():
	toggle_menu(status_menu)
	
func toggle_skill_menu():
	toggle_menu(skill_menu)
		
func any_menu_open():
	for v in menus:
		if v.visible :
			return true
	return false

func pause():
	#get_tree().get_root().get_node("World3D/World3D/").get_tree().paused = true # This pauses everything,including Singletons...
	pass
	
func resume():
	#get_tree().get_root().get_node("World3D/World3D/").get_tree().paused = false
	pass

func consider_resume():
	if not any_menu_open():
		resume()

func close_all():
	if not any_menu_open():
		return
	
	resume()
	for v in menus:
		v.hide()
		
func close_top():
	var inverKeys = range(menus.size())
	inverKeys.reverse()
	for k in inverKeys:
		if menus[k] == null:
			continue
		if menus[k].visible:
			menus[k].hide()
			consider_resume()
			return
		
func _process(_delta):
	if controls_locked > 0:
		return
	
	#Save/Load
	if Input.is_action_just_pressed("quicksave") :
		GameData.save()
		print("quicksave")
	if Input.is_action_just_pressed("quickload") :
		GameData.load()
		print(GameData._data[0][1])
		print("quickload")
		
		#GameData.set_data('scene_data/House1_Inside|Father',null) # scene_data/House1_Inside|Father/position
	
	
	if Input.is_action_just_pressed("ui_quest_menu") :
		toggle_quest_menu()
	if Input.is_action_just_pressed("ui_inventory_menu") :
		toggle_inventory()
	if Input.is_action_just_pressed("ui_crafting_menu") :
		toggle_crafting_menu()
	if Input.is_action_just_pressed("ui_status_menu") :
		toggle_status_menu()
	if Input.is_action_just_pressed("ui_wait_menu") :
		toggle_menu(wait_menu)
	if Input.is_action_just_pressed("sneak") :
		var player = GameData.get_temp("Player");
		player.toggle_sneaking();

func _input(event): 
	if controls_locked:
		return
		
	#if not is_visible_in_tree():
	#	return
	#if Input.is_action_just_pressed("menu") :
		
#	if (event is InputEventKey and event.pressed):
#		match event.scancode :
#			Input.get_:
	if event.is_action_pressed('ui_menu'):
		if any_menu_open():
			close_top()
		else:
			toggle_main_menu()
		interaction_message.accept_event() # Use anything to accept it with.
				
		
func _physics_process(delta):
	pass
	#var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	#var result = space_state.intersect_ray(Vector2(0, 0), Vector2(50, 100))
	
func quit_game():
	get_tree().quit()



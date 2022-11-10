extends Character
class_name Player

@onready var camera:Camera2D = $Camera2D
@onready var sprite_handler = $PlayerSprite

var active_entered_body
var enteredBodies_rejected : Dictionary = {} # Requirements for interaction not fulfilled
var enteredBodies : Dictionary = {}
var interaction_index = 0;

func _init():
	GameData.player = self;

func _process(_delta):
	for body in enteredBodies:
		if not can_interact(body):
			enteredBodies.erase(body)
			enteredBodies_rejected[body] = true
			update_interaction_message()
	
	for body in enteredBodies_rejected:
		if can_interact(body):
			enteredBodies[body] = true
			enteredBodies_rejected.erase(body)
			update_interaction_message()
	
	is_running = Input.is_action_pressed("sprint");
	
	velocity.x = Input.get_action_strength("go_right") - Input.get_action_strength("go_left");
	velocity.y = Input.get_action_strength("go_down") - Input.get_action_strength("go_up");
	velocity = velocity.normalized();
	velocity *= RUNSPEED if is_running else MOVEMENTSPEED;
	
	#Actions
	if Input.is_action_just_pressed("interact") and enteredBodies.size() > 0:
		enteredBodies.keys()[interaction_index].interact()		
	if Input.is_action_just_pressed("select_next_interactible") and enteredBodies.size() > 0:
		interaction_index += 1
		update_interaction_message()
	
	
	super._process(_delta);


func _on_trespass_start(): # Whether a player trespasses affects ui and ingame visuals such as if permission areas should be shown.
	GameData.set_temp("is_trespassing",true);
	
func _on_trespass_end():
	GameData.set_temp("is_trespassing",false);

func can_interact(body:Interactible):
	return body.is_visible_in_tree() and ( body._is_active() or body.allow_fail )

func update_interaction_message():
	
	if active_entered_body:
		var root = active_entered_body.get_node(active_entered_body.root)
		root.modulate.r /= 1.5
		root.modulate.g /= 1.5
		root.modulate.b /= 1.5
	
	var UI = Global.UI
	if enteredBodies.size() > 0:
		interaction_index = interaction_index % enteredBodies.size()
		active_entered_body = enteredBodies.keys()[interaction_index]
		UI.show_interaction_message(active_entered_body,interaction_index,enteredBodies.size())
	else:
		UI.hide_interaction_message()
		active_entered_body = null
		
	if active_entered_body:
		var root = active_entered_body.get_node(active_entered_body.root)
		root.modulate.r *= 1.5
		root.modulate.g *= 1.5
		root.modulate.b *= 1.5
	

func toggle_sneaking():
	var is_sneaking = GameData.get_data('is_sneaking',false);
	var visual_sneak_multiplier = GameData.get_data("sneak_vision_multiplier");
	var audio_sneak_multiplier = GameData.get_data("sneak_sound_multiplier");
	print("Found ", visual_sneak_multiplier, " and ", audio_sneak_multiplier)
	if is_sneaking:
		GameData.set_data("sneak_vision_multiplier",visual_sneak_multiplier*2);
		GameData.set_data("sneak_sound_multiplier",audio_sneak_multiplier*2);
	else:
		GameData.set_data("sneak_sound_multiplier",visual_sneak_multiplier/2);
		GameData.set_data("sneak_vision_multiplier",audio_sneak_multiplier/2);
		
	GameData.set_data('is_sneaking',not is_sneaking)

#func _unhandled_input(event):
#	# This is called BEFORE Interactibles receive the event.
#	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
#		var space_state = get_world_2d().direct_space_state
#		var results = space_state.intersect_point(get_global_mouse_position(),32,[],0x7FFFFFFF,true,true)
#		print(results)
#
#		for v in results:
#			if v.collider is Interactible:
#				return; # Interactibles handle movement themselves
#
#		move_to(get_global_mouse_position())
#	pass
#


func _on_interaction_area_area_entered(body):
	print("Entered area")
	if body is Interactible :
		if can_interact(body):
			enteredBodies[body] = true
			body.interact_auto(self)
		else:
			enteredBodies_rejected[body] = true			
		update_interaction_message()


func _on_interaction_area_area_exited(body):
	if body is Interactible:
		enteredBodies.erase(body)
		enteredBodies_rejected.erase(body)
		update_interaction_message()

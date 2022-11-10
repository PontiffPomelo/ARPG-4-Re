extends Area2D
class_name Interactible


@export var label: String = "Object"
@export var is_auto: bool = true
@export var is_active: bool = true
@export var allow_fail: bool = false # if false, won't allow interaction if requirements not fulfilled
@export var root: String = '../'
var _collision_layer:int = 1
var _collision_mask:int = 1
@export var requirements = "" # (String,MULTILINE)

@export var failure_dialogue: String
@export var success_dialogue: String
@export var _failure_sound:Array # (Array,AudioStream)
@export var _interact_sound:Array # (Array,AudioStream)

signal on_interact()
signal on_fail()

var audio_stream_player:AudioStreamPlayer;

func get_class():
	return "Interactible"

func get_interaction_message():
	return "Press [color=green][E][/color] to interact with " + label;

func _is_active():
	return is_active and (requirements == ""  or Helper.run_script(requirements))

func _init():
	collision_layer|= 1<<19
	collision_mask|= 1<<19
	_collision_layer = collision_layer
	_collision_mask = collision_mask
	
	connect("mouse_entered",Callable(self,"_on_mouse_entered"))
	connect("mouse_exited",Callable(self,"_on_mouse_exited"))
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if not audio_stream_player:
		audio_stream_player = AudioStreamPlayer.new()
		self.add_child(audio_stream_player)
	
	
	init_children(get_node(root));
	
	pass # Replace with function body.

# Register all Sprite2D children so clicking checked them will trigger interaction
func init_children(parent:Node):
	# TODO 
	#if parent is TilesetSprite:
	#	if not parent.is_connected("mouse_down",Callable(self,"on_click")):
	#		parent.connect("mouse_down",Callable(self,"on_click"))
	#	if not parent.is_connected("mouse_enter",Callable(self,"_on_mouse_entered")):
	#		parent.connect("mouse_enter",Callable(self,"_on_mouse_entered")) # for mouse cursor change
	#	if not parent.is_connected("mouse_enter",Callable(self,"_on_mouse_entered")):
	#		parent.connect("mouse_enter",Callable(self,"_on_mouse_entered"))
	
	for child in parent.get_children():
		init_children(child);

func set_active(v):
	if(v):
		collision_layer = _collision_layer
		collision_mask = _collision_mask
	else:
		if is_active:
			_collision_layer = collision_layer
			_collision_mask = collision_mask
		collision_layer = 0
		collision_mask = 0
		
	is_active = v
	
var _mouse_enter_count = 0;
func _on_mouse_entered():
	Input.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
	_mouse_enter_count += 1;

func _on_mouse_exited():
	_mouse_enter_count -= 1;
	if _mouse_enter_count <= 0:
		Input.set_default_cursor_shape(Control.CURSOR_ARROW)
	
func _input_event(_viewport,event,_shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		get_tree().set_input_as_handled()
		
		on_click(event)
			
			#walk_action.connect("on_finish",Callable(self,"interact"));
		
func on_click(_event):
	if not try_interact(): # If not close enough, walk first
		var player = GameData.get_temp("Player");
		player.action_interact(self) # Check all tiles covered by interactibility-area, choose one with shortest path
		

# Returns true if it could interact (if it's in proximity). This function ignores visibility.
func try_interact() ->bool:
	var player = GameData.get_temp("Player");
	for body in player.enteredBodies:
		if body == self:
			interact()
			return true
		
	return false

func interact():
	if not is_visible_in_tree():
		return
	if(_is_active()):
		self.emit_signal("on_interact")
		if success_dialogue:
			GameData.get_temp('DialogueBox').start_dialogue(success_dialogue)
		if _interact_sound:
			audio_stream_player.stream = _interact_sound[floor(randf_range(0,_interact_sound.size()))];
			audio_stream_player.play();
	else:
		if failure_dialogue:
			GameData.get_temp('DialogueBox').start_dialogue(failure_dialogue)
		self.emit_signal("on_fail")
		if _failure_sound:
			audio_stream_player.stream = _failure_sound[floor(randf_range(0,_failure_sound.size()))];
			audio_stream_player.play();
	
func interact_auto(_body):
	if is_auto:
		interact()

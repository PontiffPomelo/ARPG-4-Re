extends Node2D
class_name Character

@export var data : CharacterData

@export var MOVEMENTSPEED: float = 50;
@export var RUNSPEED: float = 150;

@onready var animation_tree = $AnimationTree;
@onready var animation_state = animation_tree.get('parameters/playback');

@onready var movement_noise_player:AudioStreamPlayer2D = $MovementNoisePlayer;

@onready var kinematicBody2d : CharacterBody2D = $CharacterBody2D;
@onready var navigationAgent : NavigationAgent2D = $NavigationAgent2D;

var is_running : bool = false;
var velocity = Vector2(0,0);
var is_ready = false




func _ready():
	navigationAgent.target_location = Vector2(0,0)
	is_ready = true
	

func _process(delta):
	handle_movement();	

func handle_movement():
	if not is_ready:
		return;
		
	#velocity /= 1.1;
	#print(navigationAgent.get_next_location())
	#velocity = navigationAgent.get_next_location() - position
		
	kinematicBody2d.velocity = velocity;
	#.set_velocity(velocity)
	kinematicBody2d.move_and_slide()
		
	if abs(kinematicBody2d.position.x) > 0.01 or abs(kinematicBody2d.position.y) > 0.01:
		# Transfer movement to this instead of kinematicBody2d so it serializes
		var remainder = Vector2(fmod(kinematicBody2d.position.x,1.0), fmod(kinematicBody2d.position.y , 1.0))
		
		set('position',position + kinematicBody2d.position - remainder) # serialize
		kinematicBody2d.position = remainder
	
	update_animations()


func update_animations():
	if(velocity != Vector2.ZERO):
			animation_tree.set('parameters/Idle/blend_position',velocity)
			animation_tree.set('parameters/Run/blend_position',velocity)
			animation_state.travel('Run');
			movement_noise_player.pitch_scale = 1 if is_running else 0.75
			if not movement_noise_player.playing:
				movement_noise_player.play()
	else:
		animation_state.travel('Idle');
		if movement_noise_player.playing:
			movement_noise_player.stop()
		#movement_noise_player.playing = false
	

extends Interactible
class_name Door

@onready var area : CollisionShape2D = $Area3D
@onready var target : Node2D = $Target

@export var permissionArea: NodePath;

	
func get_permission_area()->PermissionArea:
	print("PA ", permissionArea)
	return get_node(permissionArea) as PermissionArea if permissionArea.get_concatenated_names() != "" else null;
	
func get_interaction_message():
	var perm_area = get_permission_area();
	var legal = perm_area == null or perm_area.is_allowed(GameData.get_temp("Player"));
	return ("Press [color=white][E][/color] to interact with " if legal else "Press [color=red][E][/color] to interact with ")  + label;
	
func get_class():
	return "Door"

func interact():
	if(_is_active()):
		var player : Node2D = GameData.player;
		player.set_global_position(target.global_position)
	super.interact()


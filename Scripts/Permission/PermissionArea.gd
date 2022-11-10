extends Area2D
class_name PermissionArea

@export var area_name: String = 'Unnamed Area3D'
@export var default_permission = 'true' # If player neither in forbidden nor allowed group, fall back to this code. Takes character and area as argument. # (String,MULTILINE)
@export var allowed_groups = [] # If player not in forbidden group, and in one of these, allow entry # (Array,PermissionGroup)
@export var forbidden_groups = [] # If character is in any of these groups, forbid entry # (Array,PermissionGroup)
@export var severity: float = 0.5 # Higher values causes NPCs to flip out sooner when they see a trespasser


func _ready():
	connect("body_entered",Callable(self,"_body_entered"))
	connect("body_exited",Callable(self,"_body_exited"))

func _area_entered():
	pass
	
func _body_entered(body):
	if body is CharacterBody2D:
		var character : Character = Helper.find_closest_parent_of_type(body,"Character");
		if character != null:
			character.enter_permission_area(self)
				
func _body_exited(body):
	if body is CharacterBody2D:
		if body.get_parent() == GameData.get_temp('Player'):
			GameData.get_temp("Player").leave_permission_area(self)
	
# Is the character responsible for trespassers in this area? In some cases, does the character want actively ignore trespassers? 
# This result should be immutible
func is_responsible(character,target):
	return character != GameData.get_temp("Player") #&& is_allowed(character) # By default, if the character is allowed in, he should be responsible.
	
	
# Is the NPC allowed in this area?
func is_allowed(character)->bool:
	
	for group in character.permission_groups:
		if forbidden_groups.has(group):
			return false;
			
	for group in character.permission_groups:
		if allowed_groups.has(group):
			return true;
	return Helper.run_script(default_permission,{"character":character,"area":self});
# If in area, check when seen.
# If seen, check when entering area
# If heard, try to look at it, only trigger crime if seen
# 


# Areas have default, but characters have overrides for areas. Eg cook in the kitchen is not fooled by costume.

extends Interactible
class_name Portal

@export var path : = "res://Scenes/HouseScene1.tscn"
@export var target : = "/EntryPoint"

func get_class():
	return "Node3D"

func interact():
	if not is_visible_in_tree():
		return
	print('triggered '+ str(name))
	if(_is_active()):
		call_deferred("do_teleport")
	super.interact()

func do_teleport():
	GameData.get_temp("sceneManager").load_scene(path,target)
	

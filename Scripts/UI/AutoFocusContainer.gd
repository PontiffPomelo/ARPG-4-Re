extends Control
class_name AutoFocusContainer

@export var depth_first: bool = false
var last_focused_control:Control # Remember the last control that was focused, before this one was opened, and return to that checked hide
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if visible:
		show()
	pass # Replace with function body.
	
	
func show():
	#print('show')
	#print_stack()
	
	last_focused_control = get_viewport().gui_get_focus_owner()
	
	var children = get_children()
	show_children(children)
	super.show()

func hide():
	super.hide()
	if last_focused_control != null:
		last_focused_control.grab_focus()
	

func show_children(children):
	for child in children:
		if(child is Button or child is UI_SaveMenuElement or child.has_method('can_focus') and child.can_focus()):
			child.grab_focus()
			#print_debug('set focus to ', child.name)
			return true;
		var children2 = child.get_children()
		if not depth_first:
			for child2 in children2:
				children.append(child2)
		else :
			for child2 in children2:
				if show_children([child2]):
					return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

extends NinePatchRect
class_name FocusPanel

@export var focus_color: Color = Color(1,1,1,1)
@export var focus_color_self: Color = Color(1,1,1,1)
var normal_color:Color
var normal_color_self:Color
var is_focused = false

func can_focus():
	return true
	
func _ready():
	connect("focus_entered",Callable(self,"_focus_entered"))
	connect("focus_exited",Callable(self,"_focus_exited"))
	normal_color = modulate
	normal_color_self = self_modulate


func _gui_input(event):
	if not is_visible_in_tree():
		return
	#._gui_input(event)
	
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		print_debug('clicking checked ' + str(name))
		accept_event()
		grab_focus()
		

func update_colors():
	self_modulate = focus_color_self if is_focused else normal_color_self
	#modulate = focus_color if is_focused else normal_color
			
# these need hooks
func _focus_entered():
	is_focused = true
	update_colors()

func _focus_exited():
	
	is_focused = false
	update_colors()

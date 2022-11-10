extends Button
class_name ContextMenuButton

var _action
var _context

func set_action(action,context):
	_action = action
	_context = context
	text = action.label

func _ready():
	connect("pressed",Callable(self,"on_press"))
	
func on_press():
	_action.run(_context)
	Global.UI.context_menu.hide()

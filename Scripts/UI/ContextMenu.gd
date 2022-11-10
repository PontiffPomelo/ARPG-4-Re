extends AutoFocusContainer
class_name ContextMenu

var buttons = []
	
@onready var container = $PanelContainer/VBoxContainer

	
func set_actions(actions:Array,context):
	
	var buttons_size = buttons.size()
	var actions_size = actions.size()
	for i in range(max(actions_size,buttons_size)):
		if i >= actions_size:
			buttons[i].hide()
		else:
			if(i>= buttons_size):
				var button = ContextMenuButton.new()
				container.add_child(button)
				button.set_owner(container)
				buttons.append(button)
			var action = actions[i]
			var button : ContextMenuButton = buttons[i]
			
			button.set_action(action,context)
			button.show()


func _input(event): 
	if not is_visible_in_tree():
		return
	
	if (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		print('event is ', event)
		accept_event()
		hide()

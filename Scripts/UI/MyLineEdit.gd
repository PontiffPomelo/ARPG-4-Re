extends LineEdit
class_name MyLineEdit
	
func _ready():
	connect("focus_entered",Callable(self,"_focus_entered"))
	connect("focus_exited",Callable(self,"_focus_exited"))
			
# these need hooks
func _focus_entered():
	Global.UI.lock_controls()

func _focus_exited():
		Global.UI.unlock_controls()


extends AutoFocusContainer



@onready var save_load_button = $EscapeMenu/VBoxContainer/SaveLoad

func show():
	super.show()
	save_load_button.hide() if Global.UI.controls_locked else save_load_button.show()
		

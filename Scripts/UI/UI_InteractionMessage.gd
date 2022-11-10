extends RichTextLabel

func _ready():
	connect("resized",Callable(self,'resized'))
	pass

func resized():
	var aspect = get_viewport().size.x / ProjectSettings.get_setting("display/window/size/width")
	
	get('custom_fonts/normal_font').size = 10 + 5 * aspect
	offset_left = 0
	offset_right = 0
	print('resized')

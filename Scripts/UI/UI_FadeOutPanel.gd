extends Panel
class_name UI_FadeOutPanel

var target_opacity :
	get:
		return target_opacity # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_opacity
var target_color : Color :
	get:
		return target_color # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_color
var speed = 1

signal on_hide # called when fade is done
signal on_show
signal on_finish
	
func _ready():
	target_color = modulate
	

func set_opacity(v):
	target_color.a = v
	set_process(true)
	
func set_color(v):
	target_color = v
	set_process(true)

func _process(delta):
	if Helper.compare(modulate,target_color):
		set_process(false)
		if target_color.a == 0:
			#.hide()
			emit_signal("on_hide")
		elif target_color.a == 1:
			emit_signal("on_show")
		emit_signal("on_finish")
		return
		
	if modulate.r < target_color.r:
		modulate.r = min(target_color.r,modulate.r + speed * delta)
	else:
		modulate.r = max(target_color.r,modulate.r - speed * delta)
	
	if modulate.g < target_color.g:
		modulate.g = min(target_color.g,modulate.g + speed * delta)
	else:
		modulate.g = max(target_color.g,modulate.g - speed * delta)
	
	if modulate.b < target_color.b:
		modulate.b = min(target_color.b,modulate.b + speed * delta)
	else:
		modulate.b = max(target_color.b,modulate.b - speed * delta)
		
	if modulate.a < target_color.a:
		modulate.a = min(target_color.a,modulate.a + speed * delta)
	else:
		modulate.a = max(target_color.a,modulate.a - speed * delta)
		
		
	pass

func hide():
	target_color.a = 0
	set_process(true)
	pass
	
func show():
	#.show()
	target_color.a = 1
	set_process(true)
	pass

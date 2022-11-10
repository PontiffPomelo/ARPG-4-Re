extends FocusPanel
class_name UI_SaveMenuElement

@export var expanded: bool = false
@export var expanded_size: float = 400
@export var collapsed_size: float = 100
@export var expand_time: float = .5
@onready var name_label = $Name
@onready var date_label = $Date
@onready var screenshot = $Screenshot

var path : String
var save_menu

var coroutineCounter = 0


func _ready():
	super._ready()
	if(expanded):
		expand()
	else:
		collapse()

func toggle():
	expanded = !expanded
	expand() if expanded else collapse()
	

func expand():
	_target(expanded_size)
		
func collapse():
	_target(collapsed_size)
	
func _target(targetSize):
	var _couroutine_id = ++coroutineCounter
	var startSize = get_rect().size.y
	var startTime = Time.get_ticks_msec()
	var delta = 0
	while(_couroutine_id == coroutineCounter and delta < 1):
		delta = min(1,(Time.get_ticks_msec() - startTime)/(1000*expand_time))
		#minimum_size.y = delta * targetSize + (1-delta) * startSize 
		await RenderingServer.frame_pre_draw
		

		
func _focus_entered():
	super._focus_entered()
	save_menu.set_path(path)
	expand()


func _focus_exited():
	super._focus_exited()
	collapse()

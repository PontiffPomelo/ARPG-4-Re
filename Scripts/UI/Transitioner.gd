extends Control
class_name Transitioner

@export var targets : Array[TransitionerTarget]
@export var transition_time: float = 2
@export var funcion: String = 'return x'

@export var current_value: float = 0
var target_value = 0

var callback_object
var callback_method = ""
var callback_params = []

func _ready():
	update_targets()

func _process(delta):
	
	if target_value == current_value:
		if current_value == 0:
			super.hide()
		set_process(false)
		if callback_object != null:
			callback_object.callv(callback_method,callback_params)
		return
	
	delta /= transition_time
	if target_value < current_value:
		current_value = max(target_value,current_value - delta)
	else:
		current_value = min(target_value,current_value + delta)
		
	update_targets()
		
func update_targets():
	var actual_current_value = Helper.run_script(funcion,{'x':current_value})
	for target in targets:
		target.call_deferred("evaluate_over_time",self,actual_current_value)

func run(value, _callback_object=null,_callback_method="",_callback_params=[]):
	target_value = value
	self.callback_object = _callback_object
	self.callback_params = _callback_params
	self.callback_method = _callback_method
	
	set_process(true)

#func show():	
#	run(1)
#	pass
#
#func hide():
#	run(0)
#	pass

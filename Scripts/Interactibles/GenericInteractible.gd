extends Interactible
class_name GenericInteractible

@export_multiline var interaction_code : String # (String,MULTILINE)
@export_multiline var failure_code : String # (String,MULTILINE)

func get_class():
	return "GenericInteractible"

# This way changes in interaction_code will apply at runtime
func run_interact_code():
	Helper.run_script(interaction_code,{"node":self})
	
func run_fail_code():
	Helper.run_script(failure_code,{"node":self})
	

func _ready():
	connect("on_interact",Callable(self,"run_interact_code"))
	connect("on_fail",Callable(self,"run_fail_code"))
	pass

extends Resource
class_name MenuAction
# @tool

@export var label: String = "use"
@export_multiline var code # takes PickupItem "context" as input # (String,MULTILINE)

func run(context):
	return Helper.run_script(code,{"context":context})

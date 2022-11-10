extends Resource
class_name MenuActionGeneric
# @tool

var label = "use"
var target
var function # takes PickupItem "context" as input
var params = []

func run(_context):
	return target.callv(function,params)

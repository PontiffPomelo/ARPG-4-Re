extends Resource
class_name TransitionerTarget

@export var target: NodePath
@export var variable_name: String
@export var value_hidden: float 
@export var value_shown: float

func evaluate_over_time(node:Node,time):
	var target_node = node.get_node(target)
	var value = value_shown * time + (1-time) * value_hidden
	Helper.set_node_property(target_node,variable_name,value)

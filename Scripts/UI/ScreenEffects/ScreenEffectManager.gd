extends Node

	
func activate(name):
	var child = find_child(name)
	child.show()
	
	
func deactivate(name):
	var child = find_child(name)
	child.hide()
	

extends PanelContainer

# Called when the node enters the scene tree for the first time.
#func _ready():
#	for child in get_children():
#		child.connect('changed',Callable(self,"_content_changed"))
#	pass
#
#func add_child(node:Node,legible_unique_name=true):
#	super.add_child(node,legible_unique_name)
#	node.connect('changed',Callable(self,"_content_changed"))
#	pass
	
func _content_changed():
	grow_vertical = grow_vertical# just forces an update, don't know what function to call to do it manually
	pass

func _process(_delta):
	_content_changed() # brute force updates, since vboxcontainer won't signal change if children update

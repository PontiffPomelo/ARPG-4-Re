extends Container
class_name ScaleChildrenToFitContainer
#@tool

@export var centered: bool = false :
	get:
		return centered # TODOConverter40 Non existent get function 
	set(v):
		centered = v
		scale_children()

	

func _ready():
	await RenderingServer.frame_post_draw
	scale_children()
	
func scale_children():
	if get_rect().size.x == 0 or get_rect().size.y == 0:
			print('rect is 0')
			return
	for c in get_children():
		var factor = c.get_rect().size.x * abs(c.scale.x) / get_rect().size.x * abs(scale.x)
		factor = max(c.get_rect().size.y * abs(c.scale.y) / get_rect().size.y * abs(scale.y),factor)
		c.set('scale',Vector2(c.scale.x/ factor,c.scale.y/ factor))
		c.position = Vector2.ZERO
		
		if centered:
			c.position.y = (abs(scale.y) * size.y - abs(c.scale.y) * c.size.y)/2.0
			c.position.x = (abs(scale.x) * size.x - abs(c.scale.x) * c.size.x)/2.0
		
		queue_redraw()
		
		pass
		


func _notification(what):
	if (what==50): # NOTIFICATION_SORT_CHILDREN
		scale_children()
	pass
	#if (what==NOTIFICATION_SORT_CHILDREN):
	#	print('sorting')
	# Must re-sort the children
	#


			# Fit to own size
			#print(size)
			#print(c.size)
			#fit_child_in_rect( c, Rect2( Vector2(), size ) )


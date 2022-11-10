extends Container
class_name EnvelopeContainer
#@tool

func _notification(what):
	if get_children().size() == 0:
		return
		
	
		
	var max_rect:Rect2 = Rect2(0,0,0,0)
	if (what==50):
		# Must re-sort the children
		for c in get_children():
			if max_rect.size.x == 0 or max_rect.size.y == 0:
				max_rect = c.get_rect()
			else:
				max_rect = max_rect.merge(c.get_rect())
			
		set_size(Vector2(0.1,0.1))
		position = max_rect.position
		size = max_rect.size
		get_parent().notification(what,true)

extends FocusPanel
class_name UI_ContainerItem

var item : LootEntry :
	set(v):
		item = v
		if item != null:
			$Label.text = v.item.name + ' (' + str(v.count) + ')' if v.count > 1 else v.item.name
		else:
			$Label.text = ""

func _focus_entered():
	$Label.modulate = Color.BLACK
	%TransferMenu.set_active_item(self)
	super._focus_entered()
	
func _focus_exited():
	
	pass

# called by inventory when some other object becomes the active slot
func set_inactive():
	$Label.modulate = Color.WHITE	
	super._focus_exited()

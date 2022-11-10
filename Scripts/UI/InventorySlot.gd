extends FocusPanel
class_name InventorySlot

const COLOR_EQUIPPED = Color(0.15,0.25,.7)
const COLOR_UNEQUIPPED = Color(.1,.1,.1,1)

var item : LootEntry :
	set(v):
		item = v
		if item == null :
			get_node('./VBoxContainer/Label').hide()
			get_node('./VBoxContainer/TextureRect').hide()
		else:
			get_node('./VBoxContainer/Label').show()
			get_node('./VBoxContainer/TextureRect').show()
			get_node('./VBoxContainer/Label').text = item.item.label + (" x"+str(item.count) if item.count > 1 else "")
			get_node('./VBoxContainer/TextureRect').texture = item.item.sprite
		update_colors()


func _ready():
	update_colors()
	#._ready()

func show():
	update_colors()
	super.show()

func update_colors():
	normal_color_self = COLOR_EQUIPPED if is_equipped() else COLOR_UNEQUIPPED
	super.update_colors()


func is_equipped():
	return item != null and item.item is EquipmentItem and item.item.is_equipped()
		
func _gui_input(event):
	if item == null:
		return 
	if not is_visible_in_tree():
		return
	#._gui_input(event)
	if (event is InputEventMouseButton and event.pressed and event.button_index == 2) or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
		accept_event()
		#grab_focus()
		var context_menu:Control = Global.UI.context_menu
		context_menu.position = get_viewport().get_mouse_position() if event is InputEventMouseButton else (get_global_rect().position + get_global_rect().size)
		context_menu.set_actions(item.item.get_actions(),item.item)
		context_menu.show()



func _focus_entered():
	#self_modulate = focus_color_self
	Global.Inventory.set_active_slot(self)
	super._focus_entered()
	$VBoxContainer/Label.modulate = Color.BLACK
	
func _focus_exited():
	#update_colors()
	super._focus_exited()
	#print('is equipped ',is_equipped())
	#self_modulate = COLOR_EQUIPPED if is_equipped() else  (normal_color_self if not GameData.get_temp("Inventory").active_slot == self else focus_color_self)
	
# called by inventory when some other object becomes the active slot
func set_inactive():
	$VBoxContainer/Label.modulate = Color.WHITE
	
	super._focus_exited()
	#self_modulate = COLOR_EQUIPPED if is_equipped() else  normal_color_self
	
func _hover_entered():
	if item == null:
		return
	
	Global.Inventory.show_tooltip(self)

func _hover_exited():
	Global.Inventory.hide_tooltip()
#	tooltip.hide()
	

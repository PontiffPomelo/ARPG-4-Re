extends AutoFocusContainer
class_name InventoryMenu

var page = 0

var elements = []

var active_slot
var inventory_ignore_next = false
var inventory_changed = true
var inventory_cache = {}


var is_ready = false

@onready var tooltip_left = $Panel/Tooltip_L
@onready var tooltip_right = $Panel/Tooltip_R
@onready var slot_container:GridContainer = $Panel/Inventory/GridContainer

func inventory(character : CharacterData = GameData.player.data):
	return character.inventory

func _ready():
	Global.Inventory = self
	GameData.player.data.inventory.changed.connect(self.trigger_change)
	#GameData.register_set_data_hook('characters/Lily/equipment',self,"update_equipment")
	for child in get_node("./Panel/Inventory/GridContainer").get_children():
		if child is InventorySlot:
			elements.append(child)
	super._ready()
	is_ready = true
	update_page()

func trigger_change(_path=null):
	print("UI CHANGE")
	if inventory_ignore_next:
		inventory_ignore_next = false
	else :
		inventory_changed = true
	
	update_page()
	
func update_equipment(path=null):
	var char_target = $Panel/Equipment/Character
	var charData = ResourceManager.characters.get('Lily') # Constant data for character, such as default pose, name etc
	if charData and charData.compositions :
		char_target._clear_layers()
		
		var pose = "Frontal"
		
		var expression = "DefaultExpression"
		var camera = "Default"
		
		var body_comp = charData.compositions[pose].get("Body")
		if body_comp:
			char_target._assign_layers(body_comp.get(camera))
		
		var equipments = GameData.get_data('characters/Lily/equipment')
		if equipments:
			for slot in equipments:
				for item in equipments[slot]:
					var equipment = ResourceManager.items[item]
					var clothes_comp = charData.compositions[pose].get(equipment.get_variation(slot).equipment_composition_name)
					if clothes_comp:
						char_target._assign_layers(clothes_comp.get(camera))
			
		var expression_comp = charData.compositions[pose].get(expression)
		if expression_comp:
			char_target._assign_layers(expression_comp.get(camera))
	
	trigger_change(path)


func show():
	%TransferMenu.hide() # will be shown again after inventory opens if intended
	update_equipment()
	update_page()
	super.show()
	
func hide():
	var context_menu:Control = Global.UI.context_menu
	context_menu.hide()
	super.hide()
	
func show_tooltip(slot:InventorySlot):
	var index = slot.get_index()
	var columns = slot_container.columns
	var tooltip = tooltip_right if (index % columns) < floor(columns/2) else tooltip_left
	
	tooltip.get_node('Title').text = slot.item.item.label
	tooltip.get_node('Description').text = slot.item.item.description
	tooltip.show()

func hide_tooltip():
	tooltip_left.hide()
	tooltip_right.hide()

func page_count():
	var elements_per_page = elements.size()
	#print('invenotry is ',inventory())
	return ceil(float(inventory().get_number_of_different_items()) / float(elements_per_page))

func next_page():
	page = min(page_count()-1,page)
	update_page()
	
func prev_page():
	page = max(0,page-1)
	update_page()
	
func update_page():
	if not is_ready:
		return
	
	$Panel/Inventory/PageNumber.text = str(page+1) + ' / ' + str(page_count())
		
	var elements_per_page = elements.size()
	var inventory = inventory()
	
	var items = inventory.items
	var length = items.size()

	page = clamp(page,0,page_count()-1)
	
	var offset = page * elements_per_page
	
	for i in range(elements_per_page):
		var element:InventorySlot = elements[offset + i]
		if i < length:
			element.item = items[i]
		else:
			element.item = null

func set_active_slot(item):
	if active_slot:
		active_slot.set_inactive()
	active_slot = item
	print("Active slot is " + str(item))

func drop_item(item,count=1,character:Character = GameData.player) -> PickupItemInstance:
	inventory(character.data).remove_item(item,count)
	var pos = Vector2(character.position.x/character.scale.x,character.position.y/character.scale.y)
	return item.spawn(pos)

func show_transfer(inventory : Inventory):
	show()
	%TransferMenu.show()
	%TransferMenu.assign_container(inventory,"What goes in this label?")

# Get equipment as Array(String), obfuscating slots
#func get_equipped(character:CharacterData = GameData.player.data)->Array:
#	var slots = GameData.get_data('characters/'+character+'/equipment')
#	var results = []
#	for k in slots:
#		var items = slots[k].keys()
#		for i in range(items.size()):
#			results.append(items[i])
#	return results
	
#func count_equipment(character="Lily")->int:
#	return get_equipped(character).size()
	
	

extends Panel
class_name UI_ContainerTransfer

const list_item = preload('res://Prefabs/UI/UI_InventoryTransferItem.tscn')

var active_item:UI_ContainerItem

var inventory : Inventory

func set_active_item(item:UI_ContainerItem):
	if active_item:
		active_item.set_inactive()
	active_item = item

func assign_container(inventory:Inventory,label = 'Container'):
	self.inventory = inventory
	$Label.text = label
	
	var list = $Panel/ScrollContainer/VBoxContainer
	
	var list_items = list.get_children()
	
	# clear list items
	for child in list_items:
		child.hide()
		child.item = null
	
	var items = inventory.items
	
	for _i in range(items.size() - list_items.size()):
		var child = list_item.instantiate()
		list.add_child(child)
		child.set_owner(list)
		list_items.append(child)
		print("Added " + str(_i))
	
	var i = 0;
	for entry in items:
		list_items[i].item = entry # TODO : This will hide variations though!
		list_items[i].show()
		i = i + 1

func transfer_to_inventory():
	if active_item == null or active_item.item == null:
		print('not active item' , active_item)
		return
	
	var all = Input.is_action_pressed("shift")
	var transfer_count = (active_item.count if all else 1)
	var player_inventory = GameData.player.data.inventory
	var active_entry = active_item.item
	active_entry = active_entry.clone(transfer_count) 
	player_inventory.add_entry(active_entry)
	inventory.remove_entry(active_entry)
	assign_container(inventory)
	
func transfer_from_inventory():
	var active_slot:InventorySlot = Global.Inventory.active_slot
	
	if active_slot == null or active_slot.item == null or active_slot.item.count <= 0:
		print("ESC " + str(active_item))
		return
	
	var all = Input.is_action_pressed("shift")
	var transfer_count = (active_slot.count if all else 1)
	var player_inventory = GameData.player.data.inventory
	var active_entry = active_slot.item
	active_entry = active_entry.clone(transfer_count) 
	#print("Split " + str(active_entry.count)  + "/" + )
	#print("Active entry is " + str(active_entry.count))
	inventory.add_entry(active_entry)
	player_inventory.remove_entry(active_entry)
	assign_container(inventory)

func transfer_all():
	var player_inventory = GameData.player.data.inventory
	var items = inventory.items
	for entry in items:
		player_inventory.add_entry(entry)
		inventory.remove_entry(entry)
	assign_container(inventory)
	
	Global.Inventory.hide()
	
func show():
	super.show()
	pass

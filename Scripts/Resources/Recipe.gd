extends Resource
class_name Recipe

@export var name: String
@export var label: String
@export var components : Array[RecipeComponent] # (Array,RecipeComponent)
@export var products: Array[RecipeComponent] # (Array,RecipeComponent)
@export_multiline var requirements # (String,MULTILINE)
@export_multiline var description # (String,MULTILINE)

func can_craft():
	if requirements and not Helper.run_script(requirements):
		return false
		
	var inventory:InventoryMenu = GameData.get_temp("Inventory")
	for component in components:
		var item = ResourceManager.items[component.item]
		var count = component.count
		if item is EquipmentItem:
			count += item.get_equip_count()
		if not inventory.has_item(component.item,count):
			return false
	
	return true
	
func craft():
	if not can_craft():
		print('check before crafting. Cannot craft! ',name)
		return
	
	var inventory:InventoryMenu = GameData.get_temp("Inventory")
	
	for component in components:
		inventory.remove_item(component.item, component.count)
	
	for product in products:
		inventory.add_item(product.item, product.count)
	
func is_known():
	return GameData.get_global('known_recipes',[]).find(name) != -1
	
func learn():
	if is_known():
		return
	
	var known_recipes = GameData.get_global('known_recipes',[])
	known_recipes.append(name)
	GameData.set_global('known_recipes',known_recipes)
	
	#var notification_system:NotificationSystem = %NotificationSystem
	#notification_system.push_notification('New Recipe Learned',label)
	

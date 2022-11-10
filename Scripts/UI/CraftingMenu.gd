extends AutoFocusContainer
class_name CraftingMenu

@onready var recipe_selection_panel : Control = $BackgroundPanel/RecipeSelectionPanel
@onready var recipe_variation_selection_panel : Control = $BackgroundPanel/RecipeVariationSelectionPanel
@onready var details_title : Label = $BackgroundPanel/Details/RecipeTitle
@onready var details_description : RichTextLabel = $BackgroundPanel/Details/Description
@onready var details_component_list : ItemList = $BackgroundPanel/Details/Components/ItemList
@onready var craft_button : Button = $BackgroundPanel/Details/CraftButton

var variation : Recipe
var recipe_label

var is_loaded = false;

func _ready():
	is_loaded = true;
	recipe_selection_panel.connect('on_select',Callable(self,"update_recipe_label"))
	recipe_variation_selection_panel.connect('on_select',Callable(self,"update_variation"))	
	GameData.register_set_data_hook('characters/Lily/inventory',self,"update_recipe_labels")
	GameData.register_set_data_hook('characters/Lily/equipment',self,"update_recipe_labels")
	craft_button.connect("pressed",Callable(self,"do_craft"))
	update_recipe_labels()
	craft_button.disabled = not variation or not variation.can_craft()
	


func do_craft():
	variation.craft()
	SoundManager.play_sound(preload('res://Assets/Sounds/MySounds/crafting1.wav'),222,{"bus":"FX"});
	update_recipe_details()

func update_recipe_label(data,_path=null):
	recipe_label = data['label']
	update_recipe_variations()
	
func update_variation(vari,_path=null):
	variation = vari['recipe']
	update_recipe_details()
	
func update_recipe_labels(_path=null):
	var recipes = GameData.get_global('known_recipes')
	var items:Dictionary = {}
	for recipe in recipes:
		items[ResourceManager.recipes[recipe].label] = ({'label':ResourceManager.recipes[recipe].label})
	recipe_selection_panel.update_items(items.values())
	
	update_recipe_variations()
	
func update_recipe_variations():
	var recipes = GameData.get_global('known_recipes')
	
	if recipes.size() == 0:
		return
	
	var items = []
	for recipe in recipes:
		recipe = ResourceManager.recipes[recipe]
		if recipe.label == recipe_label:
			var label = ''
			for i in range(0,recipe.components.size()):
				var comp:RecipeComponent = recipe.components[i]
				label += str(comp.count) + 'x ' + comp.get_label()
				if i < recipe.components.size()-1:
					label += ','
			label += ' => '
			for i in range(0,recipe.products.size()):
				var comp:RecipeComponent = recipe.products[i]
				label += str(comp.count) + 'x ' + comp.get_label()
				if i < recipe.products.size()-1:
					label += ','
					
			items.append({'label':label,'recipe':recipe})
	
	if items.size() > 0:
		print(items[items.size()-1])
	recipe_variation_selection_panel.update_items(items)
	
	
	variation = ResourceManager.recipes[recipes[0]]
	update_recipe_details()
	
func update_recipe_details(): # TODO : Show eq x n or just eq if one. Don't allow crafting with those.
	details_title.text = variation.label
	details_description.text = variation.description
	details_component_list.clear()
	for component in variation.components:
		var is_equipped = ResourceManager.items[component.item] is EquipmentItem and ResourceManager.items[component.item].is_equipped()
		var equip_count = ResourceManager.items[component.item].get_equip_count() if is_equipped else 0
		details_component_list.add_item(component.get_label() + (' (eq)' if is_equipped else '' ) + ' ( ' + str(GameData.get_data('characters/Lily/inventory/' + component.item,0) - equip_count) + ' / ' + str(component.count) + ' )' ,null,false) 
	craft_button.disabled = not variation.can_craft()
	pass
	
func on_load():
	if is_loaded:
		update_recipe_labels()
	
	

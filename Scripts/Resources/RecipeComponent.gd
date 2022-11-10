extends Resource
class_name RecipeComponent

@export var item: String
@export var count: int

func get_label():
	return ResourceManager.items[item].label

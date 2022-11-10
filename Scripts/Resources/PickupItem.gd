extends Resource
class_name PickupItem
# @tool

# Unique name! Inventory will group by this!
@export var name: String
@export var label: String
@export_multiline var description : String # (String,MULTILINE)
@export var sprite: Texture2D = null:
	set(v):
		if v == sprite:
			return
		if sprite :
			sprite.changed.disconnect(self._inherit_changed)
		sprite = v
		sprite.changed.connect(self._inherit_changed)
		#emit_signal("changed")
@export var actions : Array[MenuAction] = []:
	set(v): 
		_set_actions(v) # (Array,MenuAction)

# Return the full name. If an item has identifying parameters, such as an expiry date,
# This string must change accordingly
func get_full_name():
	return name

func _init():
	if sprite:
		sprite.changed.connect(self._inherit_changed)
	
func _set_actions(v):
	actions = v
	for k in range(actions.size()):
		if(actions[k] == null):
			actions[k] = MenuAction.new()
	
func get_actions():
	var drop_action = MenuActionGeneric.new()
	drop_action.target = self
	drop_action.function = "drop_action"
	drop_action.label = "Drop"
	return actions + [drop_action]

func drop_action():
	GameData.player.data.inventory.remove_item_categorically(self,1)
	return spawn(GameData.player.global_position,1)
	

func spawn(position,count = 1, owner = null):
	var instance = load('res://Prefabs/Interactibles/PickupItem/PickupItem.tscn').instantiate()
	instance.item = create_loot_entry(count, owner)
	instance.name = name + str(randi())# THis should auto correct if name already taken
	#instance.add_to_group('Persist')
	#if instance.name.left(0) == '@':
	#instance.name = 'a'+instance.name # @ would not serialize due to possible duplication bug checked scene load
	var scene = SceneManager.get_scene()
	scene.add_child(instance)
	instance.position = position
	
	#SceneManager.add_node(instance,scene)
	
	#SceneManager.set_node_property(instance,'position',position)
	return instance
	

func _inherit_changed():
	emit_signal("changed")
	
func can_Pickup():
	return true

func can_Use():
	return false # may be evaluated at runtime, eg health potion can only be used if health not maxed, etc
	
func use():
	pass

# Overwrite this to create a more specialized loot entry
func create_loot_entry(count, owner = null):
	var results = LootEntry.new()
	results.item = self
	results.count = count
	results.owner = owner
	return results;


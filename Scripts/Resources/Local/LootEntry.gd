extends Resource
class_name LootEntry

# Essentially a PickupItemInstance, but a resource, not a node

@export var item : PickupItem = null
@export var count : int = 1
@export var owner : CharacterData = null


func pickup(character:CharacterData = GameData.player.data): # called from the PickupItemInstance Node in the scene
	character.inventory.add_entry(self)

func drop(character:Character= GameData.player):
	return character.inventory.drop_item(item,count,character)

func get_full_name() -> String:
	return item.get_full_name() + ((":" + owner.name) if owner != null else "")

func split(split_count:int) -> LootEntry:
	var split_entry = LootEntry.new()
	split_entry.item = item
	split_entry.count = split_count
	split_entry.owner = owner
	count -= split_count
	return split_entry

func clone(split_count:int) -> LootEntry:
	var split_entry = LootEntry.new()
	split_entry.item = item
	split_entry.count = split_count
	split_entry.owner = owner
	return split_entry

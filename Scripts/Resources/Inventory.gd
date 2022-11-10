extends Resource
class_name Inventory

@export var items : Array[LootEntry]

func resolve_item(item_or_name) -> PickupItem:
	if item_or_name == null:
		print('CANNOT ADD ITEM Null')
		return
	if item_or_name is String:
		item_or_name = ResourceManager.items[item_or_name]
	return item_or_name
	

func resolve_name(item_or_name) -> String:
	if not item_or_name is String:
		item_or_name = item_or_name.name
	return item_or_name
	

func resolve_full_name(item_or_name) -> String:
	var item = resolve_item(item_or_name)
	return item.get_full_name()

#func find_entries(item_or_name) -> Array[LootEntry]:
#	var item = resolve_item(item_or_name)
#	var full_name = resolve_full_name(item_or_name)
#	for _item in items:
#		if _item.get_full_name() == full_name:
#			return _item
#	return null;
	
func find_all(item_or_name) -> Array[LootEntry]:
	var result : Array[LootEntry] = [];
	var name = resolve_name(item_or_name)
	for _item in items:
		if _item.item.name == name:
			result.push_back(_item)
	return result;

# Count all items with the same name and identifying properties
#func count(item_or_name,fallback:int = 0) -> int :
#	var entry = find_entry(item_or_name)
#	return entry.count if entry != null else fallback

# Count all items with the same name
func count_all(item_or_name,fallback:int = 0) -> int :
	var items = find_all(item_or_name)
	
	var count = 0;
	for _item in items:
		count += _item.count
	return count

#func add_item(item_or_name,count:int):
#	#var name = resolve_name(item_or_name)
#	var item = resolve_item(item_or_name)
#	var matching_variation = find_entry(item_or_name)
#	if matching_variation != null:
#		matching_variation.count += count
#	else:
#		var entry = LootEntry.new()
#		entry.count = count;
#		entry.item = item
#		items.push_back(entry)
#	changed.emit()
	

# Finds the equivalent Loot entry if it exists.
func find_entry(entry:LootEntry)->LootEntry:
	for item in items:
		if item.get_full_name() == entry.get_full_name():
			return item
	return null
	

func add_entry(entry:LootEntry):
	var matching_variation = find_entry(entry)
	if matching_variation != null:
		matching_variation.count += entry.count
	else:
		items.push_back(entry)
	changed.emit()

func remove_entry(entry:LootEntry):
	var matching_variation = find_entry(entry)
	if matching_variation != null:
		matching_variation.count -= entry.count
		if matching_variation.count <= 0:
			items.erase(matching_variation)
	
	changed.emit()

# Remove [count] items that match the base item
func remove_item_categorically(item_or_name,count=1):
	var item = resolve_item(item_or_name)
	var real_count = count_all(item_or_name)
	if real_count < count:
		print('CANNOT Remove ' + str(count) + " " + item.name + ". You only have " + str(real_count))
	
	var variations = find_all(item_or_name)
	for variation in variations:
		if variation.count <= count:
			count -= variation.count
			items.erase(variation)
		else:
			variation.count -= count
			break
	
	changed.emit()

func has_item(item,count=1)->bool:
	return count_all(item,0) >= count

func get_number_of_different_items():
	return get_items().size()

func get_items() -> Array[PickupItem] :
	var individual_items = {}
	for entry in items:
		individual_items[entry.item] = entry.item
	return individual_items.keys()

# Returns a PickupItem -> count dictionary
func get_counts() -> Dictionary:
	var results = {}
	for item in items:
		if item.item in results:
			results += item.count
		else:
			results[item.item] = item.count
	return results;

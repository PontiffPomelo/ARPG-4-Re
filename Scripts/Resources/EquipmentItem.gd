extends PickupItem
class_name EquipmentItem


@export var variations : Array[EquipmentItemSlotVariation] # (Array,EquipmentItemSlotVariation)
@export var equip_sounds : Array[AudioStreamWAV] # (Array,AudioStreamWAV)
@export var unequip_sounds : Array[AudioStreamWAV] # (Array,AudioStreamWAV)

func get_class():
	return "EquipmentItem"

func get_variation(slot):
	for vari in variations:
		if vari.slot == slot:
			return vari
			
	return null

func get_equip_data(slot):
	var equipments = GameData.get_data('characters/Lily/equipment')
	if not equipments.get(slot) != null:
			equipments[slot] = {}
	return equipments[slot].get(name,null)
	
func get_equip_count(character='Lily'):
	var equipments = GameData.get_data('characters/'+ character + '/equipment')
	
	var count = 0

	for vari in variations:
		if equipments.get(vari.slot) != null and equipments[vari.slot].get(name) != null:
			count += 1
						
	return count
	
func is_equipped(character='Lily',slot=null):
	var equipments = GameData.get_data('characters/'+ character + '/equipment')
	
	if slot == null:
		for vari in variations:
			if equipments.get(vari.slot) != null and equipments[vari.slot].get(name) != null:
				return true
	else:
		return equipments.get(slot,{}).get(name,null) != null
	return false
			

func equip(slot=null,character='Lily'):
	var equipments = GameData.get_data('characters/'+ character + '/equipment')
	
	if slot:
		if get_equip_data(slot) != null:
			print('already equipped')
			return;
	else :
		for variation in variations:
			if get_equip_data(variation.slot) == null :
				slot = variation.slot
				break
	
	if not equipments.has(slot):
		equipments[slot] = {}
	
	equipments[slot][name] = {}
	if equip_sounds.size() != 0:
		var sound = Helper.get_random(equip_sounds)
		if sound != null:
			SoundManager.play_sound(sound,-1,{"bus":"FX"})
	GameData.set_data('characters/Lily/equipment',equipments)	
	

func can_drop(character='Lily'):
	var eq_count = get_equip_count(character)
	var count = GameData.get_data("characters/"+character+"/inventory/"+name,0)
	print(eq_count,' vs ', count)
	return eq_count < count

func unequip(slot=null,character='Lily'):
	var equipments:Dictionary = GameData.get_data('characters/'+ character + '/equipment')
	if slot : 
		if equipments.get(slot,[]).get(name) != null:
			equipments[slot].erase(name)
		else:
			print("ERROR, slot not found ", slot,character,name)
	else:
		for vari in variations:
			if equipments.get(vari.slot,[]).get(name) != null:
				equipments[vari.slot].erase(name)
		
	GameData.set_data('characters/Lily/equipment',equipments)
	if unequip_sounds.size() != 0:
		var sound = Helper.get_random(unequip_sounds)
		if sound != null:
			SoundManager.play_sound(sound,-1,{"bus":"FX"})
	print('setting data to ', equipments)

func get_actions():
	
	var equip_actions = []
	
	var inventory = GameData.get_data('characters/Lily/inventory')
	var owned_count = inventory.get(name,0)
	
	for vari in variations:
		
		
		var equipped = is_equipped('Lily',vari.slot)
		
		if equipped or get_equip_count() < owned_count: # cannot equip more than you own
			var equip_action = MenuActionGeneric.new()
			equip_action.target = self
			equip_action.function = "unequip" if equipped else "equip"
			equip_action.params = [vari.slot,'Lily']
			equip_action.label = equip_action.function + " " + vari.slot
			equip_actions.append(equip_action)
	
	return (equip_actions + super.get_actions()) if can_drop() else (equip_actions + actions)

func equip_sprite(playerSprite:PlayerSprite,variation):
	if variation is String:
		variation = get_variation(variation);
	var equipment = EquipmentSprite.new();
	equipment.set_name(name);
	equipment.priority = variation.sprite_priority;
	playerSprite.add_child(equipment,true);
	#equipment.set_owner(playerSprite) # Let it get destroyed checked serialization events
	equipment.atlas = variation.equipment_sprite_atlas;
	equipment.position = playerSprite.get_node('BodySprite').position;
	
	var index = 0;
	for child in playerSprite.get_children():
		if child is EquipmentSprite and child.priority > variation.sprite_priority:
			break;
		index+=1;
	
	print('equipped at index ', index)
	playerSprite.move_child(equipment,index)
	
	
	return equipment
	

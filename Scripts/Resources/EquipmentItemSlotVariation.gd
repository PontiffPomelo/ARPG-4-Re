extends Resource
class_name EquipmentItemSlotVariation

@export var slot: String
@export var equipment_composition_name: String 
@export var equipment_sprite_atlas: String
@export var sprite_priority: int = 0

@export var groups: Dictionary = {} # Name -> Prct.
# What about composite groups? Like Weird + Naked = Witch, or 300% Covered = Weird ?


extends Interactible
class_name LootableContainer
@export var inventory: Inventory  = Inventory.new()

func _ready():
	on_interact.connect(self.open)
	
func open():
	Global.Inventory.show_transfer(inventory)

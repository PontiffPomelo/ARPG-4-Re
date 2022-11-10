extends Interactible
class_name Harvestable

@export var sprite_harvestable: Texture2D
@export var modulate_harvestable: Color = Color(1,1,1,1)
@export var sprite_harvested: Texture2D
@export var modulate_harvested: Color = Color(1,1,1,1)
@export var text_harvested: String = "Harvested bush"


@export var cooldown: float = 5


@onready var sprite : Sprite2D = $Sprite2D
var message:FloatingLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if(not is_active):
		harvest()
	
func interact():
	if(is_active):
		spawn_message()
		harvest()
	super.interact()

func spawn_message():
	message = FloatingLabel.new()
	message.text = text_harvested
	var player = GameData.get_temp("Player")
	player.add_child(message)
	message.set_owner(player)
	message.position.x = -message.size.x/2#player.size.x
	message.position.y = -64



func harvest():
	sprite.texture = sprite_harvested
	sprite.modulate = modulate_harvested
	set_active(false)
	await get_tree().create_timer(cooldown).timeout
	sprite.texture = sprite_harvestable
	sprite.modulate = modulate_harvestable
	set_active(true)

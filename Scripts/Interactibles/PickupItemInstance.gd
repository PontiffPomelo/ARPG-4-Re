extends Interactible
class_name PickupItemInstance
@tool

@export var item: LootEntry :
	set(v):
		if item != null:
			item.item.disconnect("changed",self.update_sprite)
		item = v
		if item != null:
			#label = item.label
			item.item.connect("changed",self.update_sprite)
		update_sprite()

var _sprite : Sprite2D

var is_ready : bool = false

func _ready():
	connect("on_interact",self.pickup)
	is_ready = true
	if item != null:
		item.item.connect("changed",self.update_sprite)
	super._ready()


func sprite() -> Sprite2D:
	if not is_ready:
		return null
	if not _sprite:
		if has_node("Sprite2D"):
			_sprite = $Sprite2D
		else :
			_sprite = Sprite2D.new()
			_sprite.set_name('Sprite2D')
			add_child(_sprite,true)
			_sprite.set_owner(self)
			_sprite.yOffset = 0
			_sprite.yOffsetPixel = 0
	return _sprite

func update_sprite():
	if not is_ready :
		return
	if item == null :
		return
	_sprite = sprite()
	var sp = item.item.sprite
	_sprite.texture = sp;



func pickup():
	item.pickup(GameData.player.data)
	get_parent().remove_child(self)

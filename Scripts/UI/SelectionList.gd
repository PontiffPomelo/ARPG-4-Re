extends Panel
class_name SelectionList

var elements = []
@onready var list = $ScrollContainer/VBoxContainer
@onready var default_element = preload("res://Prefabs/UI/UI_SelectionList_Element.tscn")

signal on_select(value)

func add_element():
	var newele = default_element.instantiate()
	elements.append(newele)
	list.add_child(newele)
	newele.set_owner(list)
	newele.connect("focus_entered",Callable(self,"on_element_focus").bind(newele))

func on_element_focus(element):
	var value = element.get_meta('value')
	emit_signal('on_select',value)

func update_items(items):
	var quest_size = items.size()
	while elements.size() < quest_size: # make sure enough buttons exists
		add_element()
		
	var _i = 0
	for i in range(items.size()):
		if _i < quest_size:
			var button = elements[_i]
			var item = items[i]
			button.get_node('./Label').text = item['label']
			button.set_meta('value', item)
			button.show()
		else: # hide excess buttons
			elements[_i].hide()
		_i+=1
	super.show()
	pass

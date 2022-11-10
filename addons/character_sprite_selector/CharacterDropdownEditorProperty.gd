# MyIntEditor.gd
extends EditorProperty
class_name CharacterDropdownEditorProperty

var plugin
var object
var path
var control = VBoxContainer.new()
var options = OptionButton.new()
var searchbar = LineEdit.new()


func _init():
	options.text = "Hi"
	control.add_child(options)
	control.add_child(searchbar)
	add_child(control)
	
	
	options.connect("item_selected", self.option_changed) # THis doesn't trigger if there is only one element in list, which filter may do without selecting it.
	options.connect("focus_exited", self.option_changed_flat) # This triggers whenever. Try using model+exit instead
	searchbar.connect("text_changed", self.search_changed)
	
	
func __init():
	object.connect("__array_selector_"+path+"_changed",self._update_property)
	var items = get_filtered_items()
	#var value = get_edited_object()[get_edited_property()]
	reset(items)
	

	

func reset(items):
	options.clear()
	for path in items:
		options.add_item(path)
	options.selected = items.find(object[path])
	

func get_filtered_items():
	var items = object.get("__array_selector_"+str(path))
#	filter()
	var new_items = []
	var needle = searchbar.text
	if needle == '' :
		return items
	for item in items:
		if item.find(needle) != -1 :
			new_items.append(item)
	return new_items

func option_changed_flat():
	var items = get_filtered_items()
	var index = options.selected if options.selected != -1 else 0
	object.set(path,items[index])
	emit_changed(path, items[index])
	queue_redraw()

func option_changed(selection):
	var items = get_filtered_items()
	var index = options.selected if options.selected != -1 else 0
	object.set(path,items[index])
	emit_changed(path, items[index])
	queue_redraw()
	
func search_changed(selection):
	var items = get_filtered_items()
	reset(items)
	


func _update_property():
	print("Up " + path)
	reset(get_filtered_items())
	#var items = get_filtered_items()
	#options.selected = items.find(object[path])
	
	
#	spin.set_value(new_value.x)
#	spin2.set_value(new_value.y)

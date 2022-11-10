extends ScrollContainer
class_name ScrollableTable

@onready var columns = $HBoxContainer

var labels_container
var values_containers = []
var values_containers_separators = [] # stored just so they can be removed elegantly
var column_separators = [] # stored just so they can be removed elegantly

var cached_labels = []
var cached_separators = []

func _ready():
	if columns == null:
		columns = HBoxContainer.new()
		columns.set_owner(self)
		add_child(columns)
	
	var children = columns.get_children()
	if children.size() <= 0 :
		labels_container = VBoxContainer.new()
	else:
		labels_container = children.pop_front()
	
	values_containers = children

func get_label(container)->Label:
	if container.get_child_count() > 0:
		get_separator(container)
	var label : Label = cached_labels.pop_back() if cached_labels.size() > 0 else Label.new()
	container.add_child(label)
	label.set_owner(self)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal |= SIZE_EXPAND
	label.custom_minimum_size.y = 30	
	label.text = ""
	return label
	
func get_separator(container)->HSeparator:
	var separator:HSeparator = cached_separators.pop_back() if cached_separators.size() > 0 else HSeparator.new()
	separator.self_modulate = Color(0.443137, 0.443137, 0.443137)
	container.add_child(separator)
	separator.set_owner(self)
	return separator

func clear(): # TODO : SEPARATORS ARE NOT REMOVED PROPERLY?
	_clear_container(labels_container)
	for container in values_containers:
		_clear_container(container)
		columns.remove_child(container)
	values_containers = []
	for child in values_containers_separators:
		columns.remove_child(child)
	for child in column_separators:
		columns.remove_child(child)
	values_containers_separators = []
	column_separators = []
	pass
	
func _clear_container(container):
	for child in container.get_children():
		if not child.visible:
			continue
		if child is HSeparator:
			cached_separators.append(child)
		else:
			cached_labels.append(child)
		container.remove_child(child)
	
func _get_values_container(index):
	if index < values_containers.size():
		return values_containers[index]
	
	var column_separator = VSeparator.new()
	column_separators.append(column_separator)
	columns.add_child(column_separator)
	column_separator.set_owner(self)
	
	var value_container = VBoxContainer.new()
	value_container.size_flags_horizontal |= SIZE_EXPAND
	value_container.size_flags_vertical |= SIZE_EXPAND
	values_containers.append(value_container)
	columns.add_child(value_container)
	value_container.set_owner(self)
	
	
	
	
	var empty_rows = ceil((labels_container.get_child_count())/2.0)
	while(empty_rows > 0):
		get_label(value_container)
		if empty_rows > 1:
			get_separator(value_container)
		empty_rows -= 1
	
	return value_container
	
func add(label,value):
	if not value is Array:
		value = [value]
		
	for i in range(max(value.size(),values_containers.size())):
		var val = value[i] if i < value.size() else ""
		var value_container = _get_values_container(i)
		var value_node = get_label(value_container)
		value_node.text = (val if val is String else str(val))
		value_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	var label_node = get_label(labels_container)
	label_node.text = label
	label_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	
	

func set_items(items:Dictionary,clear=true):
	if clear:
		clear()
	for k in items:
		add(k,items[k])

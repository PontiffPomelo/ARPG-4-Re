extends AutoFocusContainer


func show_all():
	for child in $AutoFocusContainer/Content/VBoxContainer/ScrollContainer/VSplitContainer2.get_children():
		child.show()

func show_category(category_name:String):
	for child in $AutoFocusContainer/Content/VBoxContainer/ScrollContainer/VSplitContainer2.get_children():
		child.hide() if child.name != category_name else child.show()

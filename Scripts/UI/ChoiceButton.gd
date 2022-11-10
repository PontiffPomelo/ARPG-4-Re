extends Button

var choice : 
	set(v):
		_set_choice(v)# Will be assigned by dialogue system

func _pressed():
	get_node("../..")._on_ChoiceButton_pressed(choice)

func _set_choice(v):
	choice = v
	
	
	text = choice["label"]
	
	#size.x = get_node("Label").size.x + 16
	

extends Label
class_name FloatingLabel

const speed = 25
const duration = 1

var age = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	age += delta
	
	position.y -= delta * speed
	
	if age >= duration :
		queue_free()

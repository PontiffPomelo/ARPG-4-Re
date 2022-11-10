extends Control
class_name NotificationSystem

@onready var _prompt = preload("res://Prefabs/UI/UI_NotificationPrompt.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const NOTIFICATION_DURATION = 3
const MAX_NOTIFICATIONS = 3

var active_notifications = []
var semi_inactive_notifications = []
var inactive_notifications = []
var time_since_last_notification_change = 0
var notification_stack = [] # only show one at a time


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	time_since_last_notification_change += delta
	if notification_stack.size() > 0 and time_since_last_notification_change >= NOTIFICATION_DURATION:
		time_since_last_notification_change = 0
		display_next()
		
	elif notification_stack.size() == 0 and active_notifications.size() > 0 and time_since_last_notification_change >= NOTIFICATION_DURATION * (MAX_NOTIFICATIONS - active_notifications.size()):
		pop_notification()
		
	for i in range(active_notifications.size()):
		var prompt = active_notifications[i]
		var target_position = Vector2(prompt.get_rect().position.x,prompt.get_rect().size.y*(i))
		move_prompt(prompt,target_position,delta)
	
	for prompt in semi_inactive_notifications:
		if prompt.visible:
			prompt.modulate.a = max(0,prompt.modulate.a - delta*3)
			if prompt.modulate.a == 0:
				prompt.hide()
				semi_inactive_notifications.remove_at(semi_inactive_notifications.find(prompt))
				inactive_notifications.append(prompt)
				prompt.modulate.a = 1
	
func move_prompt(prompt:NotificationPrompt,target:Vector2,delta:float):
	delta = min(delta,1)
	prompt.set_position(Vector2(
		ceil((1 - delta) * prompt.get_rect().position.x + delta * target.x), # pixel perfect
		ceil((1 - delta) * prompt.get_rect().position.y + delta * target.y )
	))
	
	
# This will not necessarily display the notification immediately, but rather queue it up
func push_notification(title:String,description:String):
	notification_stack.append({"title":title,"description":description})
	
# Hide the oldest active notification
func pop_notification():
	var prompt = active_notifications.pop_back()
	
	semi_inactive_notifications.push_front(prompt)
	
	pass
	
func get_free_notifation_prompt():
	if inactive_notifications.size() > 0:
		var prompt = inactive_notifications.pop_back()
		prompt.show()
		return prompt
		
	var prompt = _prompt.instantiate()
	add_child(prompt)
	prompt.set_owner(self)
	return prompt
	
	
# This gets triggered by timer
func display_next():
	if notification_stack.size() <= 0:
		return
	
	var prompt_data = notification_stack.pop_front()
	
	if MAX_NOTIFICATIONS <= active_notifications.size():
		pop_notification()
	
	var prompt = get_free_notifation_prompt()
	
	active_notifications.push_front(prompt)
	prompt.set_data(prompt_data.title,prompt_data.description)
	prompt.get_parent().move_child(prompt,0) # Show behind all others
	prompt.set_position(Vector2(prompt.get_rect().position.x,-prompt.get_rect().size.y)) # Start out of bounds. Notification System will move it to right position checked screen by itself
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

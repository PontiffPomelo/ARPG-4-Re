extends AutoFocusContainer
class_name WaitMenu

@onready var slider:HSlider = $FocusPanel/Control/HSlider
@onready var edit_hour:LineEdit = $FocusPanel/Control/HBoxContainer/EditHour
@onready var edit_minute:LineEdit = $FocusPanel/Control/HBoxContainer/EditMinute
@onready var edit_second:LineEdit = $FocusPanel/Control/HBoxContainer/EditSecond
@onready var button_confirm:Button = $FocusPanel/Control/Button

func _ready():
	super._ready()
	slider.connect('value_changed',Callable(self,"slider_changed"))
	edit_hour.connect('text_changed',Callable(self,"line_edit_changed"))
	edit_minute.connect('text_changed',Callable(self,"line_edit_changed"))
	edit_second.connect('text_changed',Callable(self,"line_edit_changed"))
	edit_second.connect('text_changed',Callable(self,"line_edit_changed"))
	button_confirm.connect("pressed",Callable(self,"do_wait"))
	
func slider_changed(value):
	var date = Date.new()
	date.set_timestamp(int(value))
	edit_hour.text = str(date.hour)
	edit_minute.text = str(date.minute)
	edit_second.text = str(date.second)
	
func line_edit_changed(new_text=null):
	slider.value = edit_second.text.to_int() + edit_minute.text.to_int() * 60 + edit_hour.text.to_int() * 3600

func do_wait():
	GameData.advance_time(slider.value)

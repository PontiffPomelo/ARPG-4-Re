#
# >> PoorTextLabel <<
#
# GDScript proof of concept to enable font size to be set via bbcode in RichTextLabel.
#
# Example text: "[color=#ff00ff]hello [font size=32]there[/font][/color] Godot"
#
# Limitations of this implementation include:
#
#  * Need to set the text via e.g. `$"PoorTextLabel".set_bbcode(...)`
#
#  * Sized text can't be between other bbcode open/close tag pairs.
#    (But you can work around this by duplicating the tags before/inside/after
#    the `[font size=]` tag pair--or sometimes by just not closing a tag.)
#    (This is because `append_bbcode()` function doesn't appear to like bbcode fragments.)
#
#  * Strikethrough lines may not be drawn at correct height. (Appears to be Godot bug.)
#
#  * Only applies to "normal" text currently.
#
#  * Not robust against errors.
#
#  Brought to you in 2019 by RancidBacon.com with an MIT License.
#

#@tool
extends RichTextLabel

class_name PoorTextLabel
@export var font_path: String = "res://Assets/Fonts/godot/new_dynamicfont.tres"
@export var resized_text:String :
	get:
		return resized_text # TODOConverter40 Copy here content of get_resized_text
	set(mod_value):
		set_bbcode(mod_value)  # TODOConverter40 Copy here content of set_bbcode # (String,MULTILINE)

func get_resized_text():
	return text;
	

func _ready():
	set_bbcode(text)

func _handle_next_font_size_tag(value: String) -> String:

	var head: String
	var tail: String

	var result = value.split("[font size=", true, 1)

	print('found tag')

	head = result[0]
	tail = result[1]

	result = tail.split("]", true, 1)

	var font_size: int = result[0].to_int()
	tail = result[1]

	result = tail.split("[/font]", true, 1)

	var middle: String = result[0]

	tail = result[1]

	
	#var base_font: FontFile =  theme.default_font if theme.default_font is FontFile else (get_font("normal_font") if get_font("normal_font") is FontFile else load(font_path))
	#var new_font = base_font.duplicate()
	#new_font.size = font_size


	# warning-ignore:return_value_discarded
	#super.append_bbcode(head)
	#super.push_font(new_font)
	# warning-ignore:return_value_discarded
	#super.append_bbcode(middle)
	super.pop()

	return tail



# Alas, we can't override setters AFAICT...
func set_bbcode(value: String):
	
	var tail: String

	tail = value

	super.clear()

	while (tail.find("[font size=") != -1):
		
		tail = self._handle_next_font_size_tag(tail)

	# warning-ignore:return_value_discarded
	#super.append_bbcode(tail)

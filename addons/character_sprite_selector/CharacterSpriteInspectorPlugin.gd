extends EditorInspectorPlugin
class_name CharacterSpriteInspectorPlugin

func _init():
	pass

func _can_handle(object):
	# Here you can specify which object types (classes) should be handled by
	# this plugin. For example if the plugin is specific to your player
	# class defined with `class_name MyPlayer`, you can do:
	# `return object is MyPlayer`
	# In this example we'll support all objects, so:
	return true


func _parse_property ( object : Object, type : int, name:String, hint_type:int, hint_string:String, usage_flags:int, wide:bool ):
	# Check if the individual property should be handled
	if name.find("__array_selector_") == 0:
		print(name)
		return true # Ignore the selector it needs to be exported to serialize, nothing more
	
	elif object != null and ('__array_selector_' + str(name)) in object: # Bug string in Object randomly throws errors
		# Register *an instance* of the custom property editor that we'll define next.
		var editor = CharacterDropdownEditorProperty.new()
		editor.plugin = self
		editor.object = object # Just so it's immediately available
		editor.path = name
		editor.__init()
		add_property_editor(name, editor)
		# We return `true` to notify the inspector that we'll be handling
		# this integer property, so it doesn't need to parse other plugins
		# (including built-in ones) for an appropriate editor.
		return true
	else:
		return false

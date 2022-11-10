@tool
extends EditorPlugin

var plugin: EditorInspectorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	# EditorInspectorPlugin is a resource, so we use `new()` instead of `instance()`.
	plugin = load("res://addons/character_sprite_selector/CharacterSpriteInspectorPlugin.gd").new()
	add_inspector_plugin(plugin)


func _exit_tree():
	# Clean-up of the plugin goes here
	remove_inspector_plugin(plugin)
	pass

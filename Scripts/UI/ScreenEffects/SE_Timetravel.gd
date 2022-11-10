extends ColorRect

func _process(_delta):
	var player_pos = GameData.player.get_global_transform_with_canvas().origin;
	#var pos = get_viewport().get_mouse_position()
	player_pos.x /= get_viewport().size.x;
	player_pos.y = 1 - player_pos.y/get_viewport().size.y;
	#print(pos)
	
	material.set_shader_parameter('position',player_pos)

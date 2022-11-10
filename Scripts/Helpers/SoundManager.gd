extends Node

const MIN_INT = -9223372036854775808; # According to Godot wiki, all ints are 64 bit, https://docs.godotengine.org/en/stable/classes/class_int.html

var available_sound = [];
var active_sound = [];

var free_channels = []; # These have no audio left to play, might as well be reused elsewhere then
var active_channels = {}; # layernumber (int) to array of {sound:string,volume:float} by name
var channel_to_player = {}; # layernumber (int) to AudioStreamPlayer

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	#GameData.register_set_global_hook("master_volume",self,"update_master_volume");
	#GameData.register_set_global_hook("music_volume",self,"update_music_volume");
	#GameData.register_set_global_hook("fx_volume",self,"update_fx_volume");
	pass;


func update_master_volume(_path=null):
	var volume = GameData.get_global('master_volume')
	AudioServer.set_bus_volume_db ( AudioServer.get_bus_index("Master"), linear_to_db(volume) );
	
func update_fx_volume(_path=null):
	var volume = GameData.get_global('fx_volume')	
	AudioServer.set_bus_volume_db ( AudioServer.get_bus_index("FX"), linear_to_db(volume) );
	
func update_music_volume(_path=null):
	var volume = GameData.get_global('music_volume')	
	AudioServer.set_bus_volume_db ( AudioServer.get_bus_index("Music"), linear_to_db(volume) );

# Play sound immediately if channel is free, otherwise queue it up to play right after current sound is done.
# If channel == -1 will create a new channel with negative id between -1 and MIN INT
func play_sound(sound_stream:AudioStream,channel=-1,properties = {"bus":"Master"}):
	print('STARTING')
	if channel == -1:
		channel = ceil( randf_range(0,1) * (MIN_INT+2) ) - 2; # random negative channel
		
	var channel_state = active_channels.get(channel);
	
	var is_active = true;
	
	if not channel_state:
		print('couldn\'t find channel',channel);
		channel_state = {"queue":[]};
		active_channels[channel] = channel_state;
		is_active = false;
	
	var channel_array:Array = channel_state.queue;
		
	var sound_data = {"sound":sound_stream};
	for key in properties.keys():
		sound_data[key] = properties[key];
		
	if not is_active:
		_play_sound(channel,sound_data)
	else:
		channel_array.append(sound_data);	
		
	return channel;
	
# Get Audio Player by either getting the one assigned to the channel, getting one from the pool and assigning it to the channel or creating a new one.
func _get_audio_player(channel) -> AudioStreamPlayer: 
	var result = channel_to_player.get(channel);
	if not result:
		var pool_available = free_channels.size() > 0;
		result = AudioStreamPlayer.new() if not pool_available else free_channels.pop_back(); # doesn't even need to be appended
		if not pool_available:
			print('attached')
			add_child(result);
			result.connect("finished",Callable(self,"finish_sound").bind(result));
		result.set_meta("channel",channel);
		channel_to_player[channel] = result;
	return result;
	
func finish_sound(player:AudioStreamPlayer):
	print('finished')
	var channel = player.get_meta("channel");
	var channel_data = active_channels[channel];
	var queue:Array = channel_data["queue"];
	if queue.size() <= 0:
		active_channels.erase(channel);
		channel_to_player.erase(channel);
		free_channels.append(player);
	else:
		var next_sound = queue.pop_front();
		_play_sound(channel,next_sound);
		print("Playing next");
	
# Overrides currently played sound checked channel regardless of whether it's finished or not.
func _play_sound(channel,sound_data):
	print('playing sound')
	var player:AudioStreamPlayer = _get_audio_player(channel);
	
	player.stream = sound_data["sound"];
	if sound_data.get("bus"):
		player.bus = sound_data["bus"];
	player.play();
	
	
			
			

extends Resource
class_name Skill

@export var name : String;
@export var display_name : String;
@export var description : String ;#(PropertyHint.MultilineText)
@export var evolves_into : String; # If set, will render after the dependency in the skill meun
@export var rank_descriptions : Array[String] = [];

@export var test : String;

func get_skill_path() -> String:
	return "skills/"+name;
	
func get_skill_evolution() -> Skill:
	return ResourceManager.skills[evolves_into] if (evolves_into != null && evolves_into != "") else null;

func get_skill_instance() -> Dictionary:
	return GameData.get_global(get_skill_path());

func get_skill_progress() -> float :
	return GameData.get_global(get_skill_path()+"/progress",0);

func get_skill_rank() -> int :
	return GameData.get_global(get_skill_path()+"/rank",0);

func has_skill() -> bool:
	return get_skill_instance() != null;

func learn_skill():
	GameData.set_global(get_skill_path(),{"progress":0,"rank":1});

func gain_progress(value : float) :
	value = get_skill_progress()+value;
	if (value >= 1) :
		var rank = get_skill_rank();
		var max_rank = rank_descriptions.size();
		var advancements = minf(max_rank-rank,floor(value));
		GameData.set_global(get_skill_path()+"/rank",rank+advancements);
		value -= advancements;

	GameData.set_global(get_skill_path()+"/progress",value);
	

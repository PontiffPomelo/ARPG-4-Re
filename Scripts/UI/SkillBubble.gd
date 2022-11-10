extends Control
class_name SkillBubble

@export var skill : Skill;
var rank_label : Label;
var progress_label : Label;
var progress : Control;
var highlight : Control;

func _ready():
	rank_label = get_node("RankLabel") as Label;
	progress_label = get_node("ProgressLabel");
	progress = get_node("Progress");
	highlight = get_node("Highlight");

	on_skill_change();
	super._ready();

func _EnterTree():
	GameData.register_set_global_hook(skill.get_skill_path(),self,"on_skill_change");
	
	
func _ExitTree():
	GameData.remove_set_global_hook(skill.get_skill_path(),self,"on_skill_change");
	
func on_skill_change( _path =null):
	var prog = skill.get_skill_progress();
	rank_label.Text = skill.get_skill_rank();
	progress_label.Text = prog.ToString() + "%";
	(progress.Material as ShaderMaterial).SetShaderParameter("progress",prog);

func _focus_entered():
	highlight.Show();
	GameData.get_temp("SkillMenu").set_active_skill(self);

func _focus_exited():
	highlight.Hide();



extends Control
class_name SkillMenu

var skill_bubble = preload("res://Prefabs/UI/UI_SkillBubble.tscn")
var skill_tree = preload("res://Prefabs/UI/UI_SkillTree.tscn")

@onready var skill_list = $Panel/Page/SkillList/VBoxContainer
@onready var title = $Panel/Page/Details/VBoxContainer/Label
@onready var description = $Panel/Page/Details/VBoxContainer/RichTextLabel

func _ready():
	update_skills()

func show():
	super.show()
	
func set_active_skill(bubble:SkillBubble):
	description.text = bubble.skill.description + '\n\n' + bubble.skill.rank_descriptions[bubble.skill.get_skill_rank()]
	title.text = bubble.skill.display_name
	
func update_skills():
	var skills = ResourceManager.skills
	
	#var frontier = {}
	
	var first = true
	
	for skill_name in skills:
		#print('ADDING SKILL ', skill_name)
		var skill : Skill = skills[skill_name]
		
		var container = HBoxContainer.new()
		container.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var skill_bubble_instance = skill_bubble.instantiate() 
		skill_bubble_instance.skill = skill
		var skill_tree_instance = skill_tree.instantiate() 
		skill_list.add_child(container)
		container.add_child(skill_tree_instance)
		skill_tree_instance.add_child(skill_bubble_instance)

		if first:
			first = false
			skill_bubble_instance.grab_focus()


		# TODO : Use evolves_into to chain bubbles. Remember the chained ones in a dictionary to not add them twice

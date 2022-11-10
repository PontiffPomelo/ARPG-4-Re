extends Resource
class_name CharacterData
# @tool

enum Gender
{
	Male,
	Female
}

@export var gender : Gender # (String,"Male","Female")
@export var name: String = ""
@export var pose_name: String
@export var default_pose: String
@export var default_expression: String
@export var default_body: String
@export var default_camera: String
@export var text_color: Color
@export var text_speed: float = 1
@export var default_dialogue: String
@export var daily_rhythm = []; # (Array,AI_Routine_Point)
@export var inventory : Inventory
var compositions : Dictionary # Assigned at runtime, stores poses as collections of individual images, their order, their offsets , etc

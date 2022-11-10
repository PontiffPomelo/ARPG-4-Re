extends Panel
class_name SaveMenu

const save_menu_element = preload("res://Prefabs/UI/UI_SaveMenuElement.tscn")

@onready var list:VBoxContainer = $AutoFocusContainer/ScrollContainer/VBoxContainer
@onready var path_input:LineEdit = $AutoFocusContainer/Header/PathInput


var elements = []
var savegames = []

func _ready():
	elements = list.get_children()
	if visible:
		show()


func sort_files(a,b):
	return a['date'] >= b['date']

func loadSavegames():
	var savegame_files = Helper.list_files_in_directory("user://",".save");
	savegames = []
	var files_by_date = []
	for path in savegame_files:
		var file = FileAccess.open(path,FileAccess.READ);
		var date = file.get_modified_time(path)
		files_by_date.append({"date":date,"file":file,"path":path})
	
	
	files_by_date.sort_custom(Callable(self,"sort_files"))
	
	for f in files_by_date:
		var date = f['date']
		var file = f['file']
		var path = f['path']
		path = path.replace(".save","")
		var screenshot = Helper.load_image(path+".png")
		print(path+".png")
		print(screenshot)
		savegames.append({"path":path,"screenshot":screenshot,"date":date})
		file.close()
	pass

func show():
	loadSavegames()
	while elements.size() < savegames.size(): # make sure enough buttons exists
		var newele = save_menu_element.instantiate()
		elements.append(newele)
		list.add_child(newele)
		newele.set_owner(list)
		
	for i in range(elements.size()):
		if(i < savegames.size()):
			var button : UI_SaveMenuElement = elements[i]
			var savegame = savegames[i]
			button.show()
			button.path = savegame.path
			var date = Time.get_datetime_string_from_datetime_dict(savegame.date, false)
			button.date_label.text = str(date.day).pad_zeros(2) + "." + str(date.month).pad_zeros(2) + "." + str(date.year) + " " + str(date.hour).pad_zeros(2) + ":" + str(date.minute).pad_zeros(2)
			button.name_label.text = savegame.path.split("/",false)[-1]
			print(savegame.screenshot)
			button.screenshot.texture = savegame.screenshot
			button.save_menu = self
		else: # hide excess buttons
			elements[i].hide()
	super.show()
	$AutoFocusContainer.show()# otherwise focus won't be set correctly
	pass
	
func set_path(v):
	path_input.text = v
	
func load():
	GameData.load(path_input.text)
	
	
func save():
	var UI = Global.UI
	UI.close_all()
	await RenderingServer.frame_post_draw
	
	var root_node = $"..";
	var scene = PackedScene.new()
	scene.pack(root_node)
	ResourceSaver.save(scene,"res://test.tscn")
	
	#GameData.save(path_input.text)
	#UI.toggle_main_menu()
	

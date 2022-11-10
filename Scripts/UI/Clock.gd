extends Label

func _ready():
	GameData.date.connect('changed',self.update_time)
	
func update_time(path=null):
	var minutes = str(GameData.date.minute)
	var hours = str(GameData.date.hour)
	if minutes.length() < 2 :
		minutes = '0'+minutes
	if hours.length() < 2 :
		hours = '0'+hours
	self.text = hours + ':' + minutes

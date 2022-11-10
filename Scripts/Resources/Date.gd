extends Resource
class_name Date

const MINUTE = 60
const HOUR = 60 * MINUTE
const DAY = 24 * HOUR
const WEEK = 10 * DAY
const MONTH = 3 * WEEK
const YEAR = 10 * MONTH 

const WEEKDAYS = ["Manday","Duesday","Witnessday","","Freeday","","Sonday","Fatherday","Grandfatherday","Godfatherday"]




@export var _timestamp:int = 0 
@export var year : int = 0 : 
	get:
		return _timestamp / YEAR
	set(v): 
		_timestamp += (v - year)*YEAR

@export var month : int = 0 : 
	get:
		return (_timestamp % YEAR) / MONTH
	set(v): 
		_timestamp += (v - month)*MONTH
@export var day : int = 0 : 
	get:
		return (_timestamp % MONTH) / DAY
	set(v): 
		_timestamp += (v - day)*DAY
		
@export var day_prct : float = 0 : 
	get:
		return (_timestamp % DAY) / float(DAY)
	set(v): 
		_timestamp += (v - year)*YEAR
@export var hour : int = 0 : 
	get:
		return (_timestamp % DAY) / HOUR
	set(v): 
		_timestamp += (v - hour)*HOUR
@export var minute : int = 0 : 
	get:
		return (_timestamp % HOUR) / MINUTE
	set(v): 
		_timestamp += (v - minute)*MINUTE
@export var second : int = 0 : 
	get:
		return _timestamp % MINUTE
	set(v): 
		_timestamp += v - second

func _init(params={}):
	if params.has('year'):
		year = params['year']
	if params.has('month'):
		month = params['month']
	if params.has('day'):
		day = params['day']
	if params.has('hour'):
		hour = params['hour']
	if params.has('minute'):
		minute = params['minute']
	if params.has('second'):
		second = params['second']
	if params.has('timestamp'):
		_timestamp = params['timestamp']


func set_timestamp(v:int):
	_timestamp = v

func year_setter(v:int):
	_timestamp += (v - year)*YEAR

func month_setter(v:int):
	_timestamp += (v - month)*MONTH

func day_setter(v:int):
	_timestamp += (v - day)*DAY

func hour_setter(v:int):
	_timestamp += (v - hour)*HOUR
	
func minute_setter(v:int):
	_timestamp += (v - minute)*MINUTE
	
func second_setter(v:int):
	_timestamp += v - second
	
	
func year_getter()->int:
	return _timestamp / YEAR

func month_getter()->int:
	return (_timestamp % YEAR) / MONTH

func day_getter()->int:
	return (_timestamp % MONTH) / DAY

# Returns progress of daytime in normalized range. 0 or 1 is midnight, 0.5 is midday.
func day_prct_getter() -> float:
	return (_timestamp % DAY) / float(DAY)

func get_weekday()->String:
	return WEEKDAYS[(_timestamp % WEEK) / DAY]

func hour_getter()->int:
	return (_timestamp % DAY) / HOUR
	
func minute_getter()->int:
	return (_timestamp % HOUR) / MINUTE
	
func second_getter()->int:
	return _timestamp % MINUTE


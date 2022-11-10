extends Node
# @tool

const DEVMODE = true
const TIMESTEP = 0.1 # Smallest undo step (determines (inversely) how smooth timetravel looks, but also how fast savegame size grows)

var player
var active_scene : String
var date : Date = Date.new()

var dialogue_states = {}
signal dialogue_states_changed

var quests := {}
signal quests_changed;

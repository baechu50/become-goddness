extends Node

var is_game_paused := false
var event_timer: Timer
var current_event: Dictionary = {}

var events_by_type = {
	"normal": [],
	"special": [],
	"miracle": []
}

signal event_started(event_data: Dictionary)

func _ready() -> void:
	load_events()
	create_timer()

func load_events():
	var file = FileAccess.open("res://data/event.json", FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	
	for event in parsed:
		var type = event["type"]
		events_by_type[type].append(event)

func create_timer():
	event_timer = Timer.new()
	event_timer.wait_time = Constants.EVENT_INTERVAL
	event_timer.timeout.connect(next_event)
	add_child(event_timer)
	
func start_game():
	event_timer.start()	
	
func next_event():
	get_tree().paused = true 
	current_event = get_random_event()
	event_started.emit(current_event)

func get_random_event() -> Dictionary:
	var chance = randi_range(1, 100)
	var event_type = get_event_type(chance)
	var pool = events_by_type[event_type]
	return pool[randi() % pool.size()]

func get_event_type(chance: int) -> String:
	var year = ParameterManager.year
	
	if year <= 20:  # 안정기
		if chance <= 85: return "normal"
		elif chance <= 95: return "special"
		else: return "miracle"
	elif year <= 60:  # 혼란기
		if chance <= 70: return "normal"
		elif chance <= 90: return "special" 
		else: return "miracle"
	else:  # 종말기
		if chance <= 50: return "normal"
		elif chance <= 85: return "special"
		else: return "miracle"
		
func choose(choice_index: int):
	var choice = current_event.choices[choice_index]
	apply_effects(choice.effects)
	ParameterManager.increase_year()
	get_tree().paused = false

func apply_effects(effects: Dictionary):
	for type in effects:
		var amount = effects[type]
		match type:
			"faith": ParameterManager.change_faith(amount)
			"food": ParameterManager.change_food(amount)
			"population": ParameterManager.change_population(amount)

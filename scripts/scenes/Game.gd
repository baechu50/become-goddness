extends Control

@onready var year_label: Label = $UI/TopBar/YearLabel
@onready var faith_label: Label = $UI/TopBar/FaithLabel
@onready var food_label: Label = $UI/TopBar/FoodLabel
@onready var population_label: Label = $UI/TopBar/PopulationLabel

@onready var event_popup: PopupPanel = $UI/EventPopup
@onready var event_title: Label = $UI/EventPopup/VBox/EventTitle
@onready var event_description: Label = $UI/EventPopup/VBox/EventDescription
@onready var choice_buttons_container: VBoxContainer = $UI/EventPopup/VBox/ChoiceButtons

var current_event_data: Dictionary = {}

func _ready():
	clear_all_humans()
	spawn_initial_population()
	ParameterManager.init_parameter()
	
	ParameterManager.parameter_changed.connect(_on_parameter_changed)
	ParameterManager.year_changed.connect(_on_year_changed)
	ParameterManager.game_over.connect(_on_game_over)
	EventManager.event_started.connect(_on_event_started)
	
	update_all_ui()
	EventManager.start_game()
	event_popup.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
func update_all_ui():
	year_label.text = "연도: %d년" % ParameterManager.year
	faith_label.text = "신앙: %d" % ParameterManager.faith
	food_label.text = "식량: %d" % ParameterManager.food
	population_label.text = "인구: %d명" % ParameterManager.population

func create_human(spawn_position):
	var human = Human.new(spawn_position)
	
	var color_rect = ColorRect.new()
	color_rect.name = "ColorRect"
	color_rect.size = Vector2(30, 30)
	color_rect.color = Color.BLUE
	color_rect.position = Vector2(-15, -15)
	human.add_child(color_rect)
	
	var health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.size = Vector2(40, 8)
	health_bar.position = Vector2(-20, -25)
	health_bar.max_value = Constants.HUMAN_MAX_HEALTH
	health_bar.value = Constants.HUMAN_MAX_HEALTH
	human.add_child(health_bar)
	
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(30, 30)
	collision_shape.shape = shape
	human.add_child(collision_shape)
	
	$Units.add_child(human)
	
	var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	human.global_position = spawn_position + offset
	
	return human

func spawn_initial_population():
	var target_population = ParameterManager.population
	var residence = $Facilities/Residence/CollisionShape2D
	
	var spawn_position = residence.global_position
	
	for i in range(target_population):
		create_human(spawn_position)
	
	print("인구 %d명이 생성되었습니다." % target_population)

func clear_all_humans():
	var units_group = $Units
	for child in units_group.get_children():
		if child is Human:
			child.queue_free()

func _on_parameter_changed(param_name: String, new_value: int):
	match param_name:
		"faith":
			faith_label.text = "신앙: %d" % new_value
		"food":
			food_label.text = "식량: %d" % new_value
		"population":
			population_label.text = "인구: %d명" % new_value
			
func _on_year_changed(new_year: int):
	year_label.text = "연도: %d년" % new_year
	
func _on_event_started(event_data: Dictionary):
	current_event_data = event_data
	show_event_popup(event_data)
	
func show_event_popup(event_data: Dictionary):
	event_title.text = event_data.get("title")
	event_description.text = event_data.get("text")
	clear_choice_buttons()
	create_choice_buttons(event_data.get("options", []))
	event_popup.popup_centered()

func clear_choice_buttons():
	for child in choice_buttons_container.get_children():
		child.queue_free()

func create_choice_buttons(options: Array):
	for i in range(options.size()):
		var option = options[i]
		var button = Button.new()
		
		var label = option.get("label", "")
		var cost = option.get("cost", {})
		
		var costs = []
		var can_afford = true
		
		for type in cost:
			if cost[type] < 0:
				costs.append(format_resource_text(type, cost[type]))
				if ParameterManager.get(type) < abs(cost[type]):
					can_afford = false
		
		button.text = label if costs.size() == 0 else "%s (%s)" % [label, " ".join(costs)]
		button.pressed.connect(_on_choice_selected.bind(i))
		button.add_theme_font_size_override("font_size", 36)
		button.disabled = !can_afford
		choice_buttons_container.add_child(button)

func format_resource_text(type: String, amount: int) -> String:
	var resource_sign = "+" if amount > 0 else ""
	match type:
		"faith": return "신앙 %s%d" % [resource_sign, amount]
		"food": return "식량 %s%d" % [resource_sign, amount]
		"population": return "인구 %s%d" % [resource_sign, amount]
		_: return ""

func _on_choice_selected(choice_index: int):
	var result = EventManager.choose(choice_index)
	show_result(result.result_text, result.reward)

func show_result(result_text: String, reward: Dictionary):
	for button in choice_buttons_container.get_children():
		button.queue_free()
	
	var full_text = result_text
	if not reward.is_empty():
		for type in reward:
			var amount = reward[type]
			full_text += "\n" + format_resource_text(type, amount)
			
	event_description.text = full_text
	create_next_buttons()
	
func create_next_buttons():
	var button = Button.new()
	button.text = "다음"
	button.pressed.connect(_on_next_pressed)
	button.add_theme_font_size_override("font_size", 36)
	choice_buttons_container.add_child(button)
	
func _on_next_pressed():
	ParameterManager.increase_year()
	event_popup.hide()
	EventManager.resume_events()

func _on_game_over(reason: String):
	ParameterManager.game_over_reason = reason
	EventManager.event_timer.stop()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/GameOver.tscn")

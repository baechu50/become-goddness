extends Control

@onready var year_label: Label = $UI/TopBar/YearLabel
@onready var faith_label: Label = $UI/TopBar/FaithLabel
@onready var food_label: Label = $UI/TopBar/FoodLabel
@onready var population_label: Label = $UI/TopBar/PopulationLabel

@onready var event_popup: AcceptDialog = $UI/EventPopup
@onready var event_title: Label = $UI/EventPopup/VBox/EventTitle
@onready var event_description: Label = $UI/EventPopup/VBox/EventDescription
@onready var choice_buttons_container: VBoxContainer = $UI/EventPopup/VBox/ChoiceButtons

var current_event_data: Dictionary = {}

func _ready():
	ParameterManager.parameter_changed.connect(_on_parameter_changed)
	ParameterManager.year_changed.connect(_on_year_changed)
	ParameterManager.game_over.connect(_on_game_over)
	EventManager.event_started.connect(_on_event_started)
	update_all_ui()
	EventManager.start_game()
	
func update_all_ui():
	year_label.text = "연도: %d년" % ParameterManager.year
	faith_label.text = "신앙: %d" % ParameterManager.faith
	food_label.text = "식량: %d" % ParameterManager.food
	population_label.text = "인구: %d명" % ParameterManager.population

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
	event_title.text = event_data.get("title", "이벤트")
	event_description.text = event_data.get("description", "설명 없음")
	clear_choice_buttons()
	create_choice_buttons(event_data.get("choices", []))
	event_popup.popup_centered()

func clear_choice_buttons():
	for child in choice_buttons_container.get_children():
		child.queue_free()

func create_choice_buttons(choices: Array):
	for i in range(choices.size()):
		var choice = choices[i]
		var button = Button.new()
		button.text = choice.get("text", "선택지 %d" % (i + 1))
		button.pressed.connect(_on_choice_selected.bind(i))
		choice_buttons_container.add_child(button)

func _on_choice_selected(choice_index: int):
	EventManager.choose(choice_index)
	event_popup.hide()

func _on_game_over(reason: String):
	show_game_over(reason)

func show_game_over(reason: String):
	var game_over_popup = AcceptDialog.new()
	game_over_popup.dialog_text = "게임 오버!\n\n사유: %s\n생존 년수: %d년" % [reason, ParameterManager.year]
	game_over_popup.title = "게임 종료"
	add_child(game_over_popup)
	game_over_popup.popup_centered()
	EventManager.event_timer.stop()

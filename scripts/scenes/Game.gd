extends Control

@onready var event_system = $EventSystem
@onready var parameter_system = $ParameterSystem
@onready var state_system = $StateSystem

var current_event: Dictionary
var pending_reward: Dictionary = {}
var pending_result_text: String = ""
var stage: String = "choice"
var reward_success: bool = true

func _ready():
	event_system.load_events()
	parameter_system.reset()
	show_next_event()

func show_next_event():
	state_system.check_states()
	current_event = event_system.get_random_event(Parameter.year)
	show_event(current_event)
	update_header()

func show_event(event: Dictionary):
	$EventArea/TitleText.text = event["title"]
	$EventArea/EventText.text = event["text"]

	for i in range(3):
		var btn = $EventArea.get_node_or_null("Choice%dButton" % (i + 1))
		if btn == null:
			print("❗버튼이 없습니다: Choice%dButton" % (i + 1))
		if btn:
			if i < event["options"].size():
				var option = event["options"][i]
				var label = option["label"]
				var cost_dict = option.get("cost", {})
				var cost_text = get_cost_text(cost_dict)
				btn.text = label + ("\n[비용] " + cost_text if cost_text != "" else "")
				btn.visible = true
				btn.disabled = not can_afford(cost_dict)
			else:
				btn.visible = false

	$EventArea/NextButton.visible = false
	stage = "choice"

func can_afford(cost: Dictionary) -> bool:
	for key in cost.keys():
		if Parameter.get(key) < cost[key]:
			return false
	return true

func get_cost_text(cost: Dictionary) -> String:
	var parts = []
	for key in cost.keys():
		var value = cost[key]
		if value > 0:
			parts.append("%s -%d" % [get_label(key), value])
	return ", ".join(parts)

func get_label(key: String) -> String:
	match key:
		"faith": return "신앙"
		"food": return "식량"
		"population": return "인구"
		_: return key

func show_result_text(text: String):
	$EventArea/EventText.text = text
	for i in range(3):
		var btn = $EventArea.get_node_or_null("Choice%dButton" % (i + 1))
		if btn:
			btn.visible = false
	$EventArea/NextButton.visible = true

func get_reward_text(dict: Dictionary) -> String:
	var parts = []
	for k in dict.keys():
		var v = dict[k]
		if v != 0:
			parts.append("%s %+d" % [get_label(k), v])
	return ", ".join(parts)

func update_header():
	$Header/ParamBox/MarginContainer/PopulationLabel.text = "인구: %d" % Parameter.population
	$Header/ParamBox/MarginContainer3/FoodLabel.text = "식량: %d" % Parameter.food
	$Header/ParamBox/MarginContainer2/FaithLabel.text = "신앙: %d" % Parameter.faith

	var states = []
	if Parameter.famine: states.append("기근")
	if Parameter.distrust: states.append("불신")
	if Parameter.prosperity: states.append("번영")
	$Header/InfoBox/StateLabel.text = ", ".join(states) if states.size() > 0 else "정상 상태"
	$Header/InfoBox/YearLabel.text = "%d년" % Parameter.year

func _on_Choice1Button_pressed(): resolve_event(0)
func _on_Choice2Button_pressed(): resolve_event(1)
func _on_Choice3Button_pressed(): resolve_event(2)

func resolve_event(index: int):
	var option = current_event["options"][index]
	parameter_system.apply_cost(option.get("cost", {}))
	update_header()

	reward_success = randf() < option.get("success_rate", 1.0)
	pending_reward = option.get("success_reward", {}) if reward_success else option.get("failure_reward", {})
	var result_text = option.get("result_text_success", "") if reward_success else option.get("result_text_failure", "")
	
	var result = get_reward_text(pending_reward)

	stage = "result"
	show_result_text(result_text + (("\n[보상] " + result) if result != "" else ""))

func _on_NextButton_pressed():
	if stage == "result":
		parameter_system.apply_reward(pending_reward)
		update_header()
		stage="yearly"
	if stage == "yearly":
		var yearly_result = parameter_system.yearly_changes_text()
		show_result_text(yearly_result)
		stage = "next"
	elif stage == "next":
		parameter_system.apply_yearly_changes()
		update_header()
		parameter_system.next_year()
		if parameter_system.is_gameover():
			get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
		else:
			show_next_event()

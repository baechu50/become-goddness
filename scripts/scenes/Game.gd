extends Control

@onready var event_system = $EventSystem
@onready var parameter_system = $ParameterSystem
@onready var state_system = $StateSystem

var current_event: Dictionary

func _ready():
	event_system.load_events()
	parameter_system.reset()
	show_next_event()

func show_next_event():
	# 상태 갱신
	state_system.check_states()
	
	# 랜덤 이벤트 선택
	current_event = event_system.get_random_event(Parameter.year)
	
	# 이벤트 출력
	show_event(current_event)
	
	# 헤더 업데이트
	update_header()

func show_event(event: Dictionary):
	$EventArea/TitleText.text = event["title"]
	$EventArea/EventText.text = event["text"]

	# 선택지 버튼 세팅 (최대 3개)
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

				if cost_text != "":
					btn.text = label + "\n[비용] " + cost_text
				else:
					btn.text = label

				btn.visible = true
				btn.disabled = false
			else:
				btn.visible = false

	# 다음 버튼 숨기기
	$EventArea/NextButton.visible = false

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
	
	# 선택지 버튼 감추기
	for i in range(3):
		var btn = $EventArea.get_node_or_null("Choice%dButton" % (i + 1))
		if btn:
			btn.visible = false
	
	# 다음 버튼 보이기
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
	
	if states.size() > 0:
		$Header/InfoBox/StateLabel.text = ", ".join(states)
	else:
		$Header/InfoBox/StateLabel.text = "정상 상태"

	$Header/InfoBox/YearLabel.text = "%d년" % Parameter.year

func _on_Choice1Button_pressed(): resolve_event(0)
func _on_Choice2Button_pressed(): resolve_event(1)
func _on_Choice3Button_pressed(): resolve_event(2)

func resolve_event(index: int):
	var option = current_event["options"][index]
	parameter_system.apply_cost(option.get("cost", {}))

	var success_rate: float = option.get("success_rate", 1.0)
	var is_success: bool = randf() < success_rate

	var reward_text = ""
	if is_success:
		parameter_system.apply_reward(option.get("success_reward", {}))
		reward_text = get_reward_text(option.get("success_reward", {}))
		show_result_text(option.get("result_text_success", "") + "\n[보상] " + reward_text)
	else:
		parameter_system.apply_reward(option.get("failure_reward", {}))
		reward_text = get_reward_text(option.get("failure_reward", {}))
		show_result_text(option.get("result_text_failure", "") + "\n[보상] " + reward_text)

func _on_NextButton_pressed():
	parameter_system.next_year()
	if parameter_system.is_gameover():
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
	else:
		show_next_event()

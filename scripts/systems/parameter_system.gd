extends Node
class_name ParameterSystem

var allowed_keys = ["year", "faith", "food", "population"]

func reset():
	Parameter.year = 1
	Parameter.faith = 20
	Parameter.food = 20
	Parameter.population = 20

func apply_cost(cost: Dictionary):
	for k in cost:
		if k in allowed_keys:
			Parameter.set(k, max(0, Parameter.get(k) - cost[k]))

func apply_reward(reward: Dictionary):
	for k in reward:
		if k in allowed_keys:
			Parameter.set(k, Parameter.get(k) + reward[k])
			
func yearly_changes_text()-> String:
	var result_text = ""	
	var delta = max(1, int(Parameter.population / 20))
	var penalty = max(1, int(Parameter.population / 10))
	
	result_text="한 해가 지났습니다\n식량 -%d\n인구 +%d\n신앙 +%d\n" % [delta, delta, delta]
	if Parameter.famine:
		result_text+="기근 상태라 인구와 신앙이 감소합니다.\n인구 -%d\n신앙 -%d" % [penalty * 2, penalty]
	return result_text

func apply_yearly_changes() -> void:
	var delta = max(1, int(Parameter.population / 20))
	var penalty = max(1, int(Parameter.population / 10))
	
	Parameter.food = max(0, Parameter.food - delta)
	Parameter.population += delta
	Parameter.faith += delta
	
	if Parameter.famine:
		Parameter.population = max(0, Parameter.population - penalty)
		Parameter.faith = max(0, Parameter.faith - penalty)


func next_year() -> void:
	Parameter.year += 1

func is_gameover() -> bool:
	return Parameter.population <= 0 or Parameter.faith <= 0

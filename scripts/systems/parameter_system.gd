extends Node
class_name ParameterSystem

var allowed_keys = ["year", "faith", "food", "population"]

func reset():
	Parameter.year = 1
	Parameter.faith = 20
	Parameter.food = 20
	Parameter.population = 20

func next_year():
	Parameter.year += 1
	Parameter.food = max(0, Parameter.food - int(Parameter.population / 5))
	
	if Parameter.famine:
		Parameter.population = max(0, Parameter.population - 3)
		Parameter.faith = max(0, Parameter.faith - 3)

func apply_cost(cost: Dictionary):
	for k in cost:
		if k in allowed_keys:
			Parameter.set(k, max(0, Parameter.get(k) - cost[k]))

func apply_reward(reward: Dictionary):
	for k in reward:
		if k in allowed_keys:
			Parameter.set(k, Parameter.get(k) + reward[k])

func is_gameover() -> bool:
	return Parameter.faith <= 0 or Parameter.population <= 0

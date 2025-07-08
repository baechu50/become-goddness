extends Node
class_name StateSystem

func check_states():
	Parameter.famine = Parameter.food == 0
	Parameter.distrust = Parameter.faith == 0
	Parameter.prosperity = (Parameter.faith >= 100 and Parameter.food >= 100 and Parameter.population >= 100)

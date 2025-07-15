extends Node

var year := 1
var faith := 5
var food := 5
var population := 3

var famine = false
var distrust = false
var prosperity = false

var game_over_reason: String = ""

signal parameter_changed(param_name: String, new_value: int)
signal year_changed(new_year: int)
signal status_changed(status_name: String, active: bool)
signal game_over(reason: String)

func init_parameter()->void:
	year = 1
	faith = Constants.INITIAL_FAITH
	food = Constants.INITIAL_FOOD
	population = Constants.INITIAL_POPULATION

func change_faith(amount: int) -> void:
	faith += amount
	parameter_changed.emit("faith", faith)
	check_game_over()

func change_food(amount: int) -> void:
	food += amount
	parameter_changed.emit("food", food)
	check_game_over()

func change_population(amount: int) -> void:
	population += amount
	parameter_changed.emit("population", population)
	check_game_over()
	
func increase_year() -> void:
	year += 1
	year_changed.emit(year)
	
func set_famine(active: bool) -> void:
	famine = active
	status_changed.emit("famine", active)

func set_distrust(active: bool) -> void:
	distrust = active
	status_changed.emit("distrust", active)

func set_prosperity(active: bool) -> void:
	prosperity = active
	status_changed.emit("prosperity", active)

func check_game_over() -> void:
	if faith < 0:
		game_over.emit("신앙고갈")
	elif population <= 0:
		game_over.emit("인구고갈")

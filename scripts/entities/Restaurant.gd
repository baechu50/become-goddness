extends BaseFacility

var humans = []

func _ready():
	super._ready()
	humans = get_humans_in_area()

func facility_action():
	humans = get_humans_in_area()
	if (ParameterManager.food>0): 
		consumption()
		production()
	else:
		health_consumption()

func production(): 
	for human in humans:
		human.change_health(Constants.RESTAURANT_BASE_PRODUCTION * (Constants.RESTAURANT_PRODUCTION_MULTIPLIER ** (level - 1)))

func consumption():
	var food = humans.size() * Constants.RESTAURANT_BASE_CONSUMPTION * (Constants.RESTAURANT_CONSUMPTION_MULTIPLIER ** (level - 1))
	ParameterManager.change_food(-food)

func health_consumption():
	for human in humans:
		human.change_health(-Constants.RESIDENCE_BASE_CONSUMPTION)

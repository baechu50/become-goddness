extends BaseFacility

var humans = []

func _ready():
	super._ready()
	humans = get_humans_in_area()

func facility_action():
	humans = get_humans_in_area()
	consumption()
	production()

func consumption():   
	for human in humans:
		human.change_health(-Constants.FARM_BASE_CONSUMPTION * (Constants.FARM_CONSUMPTION_MULTIPLIER ** (level - 1)))

func production():
	var product = humans.size() * Constants.FARM_BASE_PRODUCTION * (Constants.FARM_PRODUCTION_MULTIPLIER ** (level - 1))
	ParameterManager.change_food(product)

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
		human.change_health(-Constants.TEMPLE_BASE_CONSUMPTION * (Constants.TEMPLE_CONSUMPTION_MULTIPLIER ** (level - 1)))

func production():
	var product = humans.size() * Constants.TEMPLE_BASE_PRODUCTION * (Constants.TEMPLE_PRODUCTION_MULTIPLIER ** (level - 1))
	ParameterManager.change_faith(product)

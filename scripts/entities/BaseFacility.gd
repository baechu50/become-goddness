extends Area2D
class_name BaseFacility

var timer: Timer
var level = 1
var upgrade_button: Button
var level_label: Label

signal level_changed(new_level: int)

func _ready():
	setup_timer()
	setup_ui()

func setup_timer():
	timer = Timer.new()
	timer.wait_time = Constants.FACILITY_UPDATE_INTERVAL
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
func setup_ui():
	level_label = get_node("LVLabel")
	upgrade_button = get_node("UpgradeButton")
	upgrade_button.pressed.connect(upgrade)
	level_changed.connect(_on_level_changed)
	ParameterManager.parameter_changed.connect(_on_parameter_changed)
	update_ui()
	
func _on_parameter_changed(param_name: String, new_value: int):
	if param_name == "faith":
		update_ui()

func _on_level_changed(new_level: int):
	update_ui()

func update_ui():
	level_label.text = "Lv." + str(level)
	
	if level >= Constants.MAX_UPGRADE_LEVEL:
		upgrade_button.text = "최대 레벨"
		upgrade_button.disabled = true
	else:
		var cost = get_upgrade_cost()
		upgrade_button.text = "업그레이드 (" + str(cost) + ")"
		upgrade_button.disabled = ParameterManager.faith < cost

func _on_timer_timeout():
	facility_action()

func facility_action():
	pass
	
func upgrade():
	if level >= Constants.MAX_UPGRADE_LEVEL:
		return
	
	var upgrade_cost = get_upgrade_cost()
	if ParameterManager.faith >= upgrade_cost:
		ParameterManager.faith -= upgrade_cost
		level += 1
		level_changed.emit(level)
		on_level_up()
	
func get_upgrade_cost():
	return Constants.COST_BASE_FAITH * (Constants.COST_MULTIPLIER ** (level - 1))

func on_level_up():
	pass
	
func get_humans_in_area():
	var overlapping_bodies = get_overlapping_bodies()
	var humans = []
	
	for body in overlapping_bodies:
		if body is Human:
			humans.append(body)
	
	return humans

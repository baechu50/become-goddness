extends BaseFacility

var humans = []
var counter = 0
var residence_spawn_time = 0

func _ready():
	super._ready()
	clear_all_humans()
	update_spawn_time()
	ParameterManager.population_increased.connect(spawn_multiple_human)
	spawn_multiple_human(ParameterManager.population)
	
func facility_action():
	humans = get_humans_in_area()
	counter += 1
	health_consumption()
	if (counter>=residence_spawn_time):
		ParameterManager.change_population(1)
		counter = 0

func clear_all_humans():
	var units_group = get_parent().get_parent().get_node("Units")
	for child in units_group.get_children():
		if child is Human:
			child.queue_free()

func spawn_multiple_human(amount: int):
	for i in amount:
		spawn_human(global_position)
		
func update_spawn_time():
	residence_spawn_time = Constants.RESIDENCE_BASE_TIME * (Constants.RESIDENT_MULTIPLIER ** (level - 1))

func health_consumption():
	for human in humans:
		human.change_health(-Constants.RESIDENCE_BASE_CONSUMPTION)

func on_level_up():
	update_spawn_time()
	counter = 0

func spawn_human(spawn_position):	
	var human = Human.new(spawn_position)
	
	human.collision_layer = 2 
	human.collision_mask = 1
	
	var color_rect = ColorRect.new()
	color_rect.name = "ColorRect"
	color_rect.size = Vector2(50, 80)  # 50x80으로 변경
	color_rect.color = Color.BLUE
	color_rect.position = Vector2(-25, -40)  # 중앙 정렬: -width/2, -height/2
	human.add_child(color_rect)
	
	var health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.size = Vector2(60, 10)  # 체력바도 좀 더 크게
	health_bar.position = Vector2(-30, -50)  # 사람 위쪽에 배치
	health_bar.max_value = Constants.HUMAN_MAX_HEALTH
	health_bar.value = Constants.HUMAN_MAX_HEALTH
	human.add_child(health_bar)
	
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(50, 80)  # 충돌 영역도 동일하게
	collision_shape.shape = shape
	human.add_child(collision_shape)
	
	get_parent().get_parent().get_node("Units").add_child(human)
	
	var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	human.global_position = global_position + offset
	
	return human

extends CharacterBody2D
class_name Human

var max_health: int = Constants.HUMAN_MAX_HEALTH
var current_health: int = Constants.HUMAN_MAX_HEALTH
var is_dragging: bool = false
var previous_position: Vector2 

@onready var sprite: ColorRect = $ColorRect
@onready var health_bar: ProgressBar = $HealthBar

signal health_changed(new_health: int)
signal unit_died(unit: Human)
signal drag_started(unit: Human)
signal drag_ended(unit: Human)

func _ready():
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	update_color()
	health_changed.connect(_on_health_changed)

func _init(spawn_position: Vector2 = Vector2.ZERO):
	max_health = Constants.HUMAN_MAX_HEALTH
	current_health = Constants.HUMAN_MAX_HEALTH
	is_dragging = false
	previous_position = spawn_position

func change_health(amount: int):
	current_health = clamp(current_health + amount, 0, max_health)
	health_changed.emit(current_health)
	if current_health <= 0: 
		die()

func _on_health_changed(new_health: int):
	if health_bar:
		health_bar.value = new_health
	update_color()

func die():
	unit_died.emit(self)
	queue_free() 
	ParameterManager.change_population(-1)

func update_color():
	if not sprite:
		return
	var health_percentage = float(current_health) / float(max_health)
	var color: Color
	
	if health_percentage > 0.66:
		color = Color.GREEN
	elif health_percentage > 0.33:
		color = Color.YELLOW
	else:
		color = Color.RED
	
	sprite.color = color

func start_drag():
	if not is_dragging:
		previous_position = global_position
		is_dragging = true
		drag_started.emit(self)

func end_drag():
	if is_dragging:
		is_dragging = false
		try_place_at_position(global_position)
		drag_ended.emit(self)

func return_to_previous_position():
	global_position = previous_position

func try_place_at_position(target_position: Vector2):
	var colliding_facility = get_colliding_facility(target_position)
	if colliding_facility:
		global_position = target_position
	else:
		return_to_previous_position()

func get_colliding_facility(pos: Vector2):
	var facilities = get_tree().current_scene.find_child("Facilities")
	if not facilities:
		return null
	
	for facility in facilities.get_children():
		if facility is Area2D:
			var collision_shape = facility.find_child("CollisionShape2D")
			if collision_shape and collision_shape.shape:
				var shape_rect = collision_shape.shape.get_rect()
				var world_rect = Rect2(
					collision_shape.global_position + shape_rect.position,
					shape_rect.size
				)
				
				if world_rect.has_point(pos):
					return facility
	
	return null


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var is_on_unit = mouse_pos.distance_to(global_position) < 30
		
		if event.pressed and is_on_unit:
			start_drag()
			get_viewport().set_input_as_handled()
		elif not event.pressed:
			end_drag()
	
	elif event is InputEventScreenTouch:
		var touch_pos = event.position
		var is_on_unit = touch_pos.distance_to(global_position) < 15
		
		if event.pressed and is_on_unit:
			start_drag()
			get_viewport().set_input_as_handled()
		elif not event.pressed:
			end_drag()
	
	elif event is InputEventMouseMotion and is_dragging:
		global_position = get_global_mouse_position()
	
	elif event is InputEventScreenDrag and is_dragging:
		global_position = event.position

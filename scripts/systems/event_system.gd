extends Node
class_name EventSystem

var current_event: Dictionary = {}

var events_by_type = {
	"normal": [],
	"special": [],
	"miracle": []
}

func load_events():
	var file = FileAccess.open("res://data/event.json", FileAccess.READ)
	var raw = file.get_as_text()
	var parsed = JSON.parse_string(raw)

	for event in parsed:
		if not event.has("type"):
			print("⚠️ 이벤트에 type이 없습니다. ID: %s" % str(event.get("id", "Unknown")))
			continue

		var type = event["type"]
		
		if events_by_type.has(type):
			events_by_type[type].append(event)
		else:
			print("⚠️ 알 수 없는 이벤트 타입: %s" % type)
			

func get_event_type(year: int, chance: int) -> String:
	var special_boost := 0
	var miracle_boost := 0

	if Parameter.distrust:
		special_boost = 5
	if Parameter.prosperity:
		miracle_boost = 5

	# ===== 안정기 (1~20년차) =====
	if year <= 20:
		var normal_cutoff = 85
		var special_cutoff = 95 + special_boost  # 기본 10% + 보정
		if chance <= normal_cutoff:
			return "normal"
		elif chance <= special_cutoff:
			return "special"
		else:
			return "miracle"

	# ===== 혼란기 (21~60년차) =====
	elif year <= 60:
		var normal_cutoff = 70
		var special_cutoff = 90 + special_boost  # 기본 20% + 보정
		if chance <= normal_cutoff:
			return "normal"
		elif chance <= special_cutoff:
			return "special"
		else:
			return "miracle"

	# ===== 종말기 (61년차 이상) =====
	else:
		var normal_cutoff = 50
		var special_cutoff = 85 + special_boost  # 기본 35% + 보정
		if chance <= normal_cutoff:
			return "normal"
		elif chance <= special_cutoff:
			return "special"
		else:
			return "miracle"

func get_random_event(year: int) -> Dictionary:
	var chance = randi_range(1, 100)
	var event_type = get_event_type(year, chance)
	var pool = events_by_type[event_type]
	return pool[randi() % pool.size()]

func next_event():
	current_event = get_random_event(Parameter.year)

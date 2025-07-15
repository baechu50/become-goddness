extends Control
@onready var gameover_text: Label = $UI/text
@onready var retry_button: Button = $UI/RetryButton

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	
	gameover_text.text = "당신이 이끌던 문명은 멸망의 길을 걷게 되었습니다.\n사유: %s\n생존 년수: %d년" % [ParameterManager.game_over_reason, ParameterManager.year]

func _on_retry_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Start.tscn")

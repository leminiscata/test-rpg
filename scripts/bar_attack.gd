extends TextureProgressBar
@onready var bar_attack = $"."
@onready var timer = $Timer

var bar_go_trip = true # boolean for timer/bar to go forward or backward

func _ready():
	timer.start()

func _process(_delta):
	if bar_go_trip:
		_on_timer_timeout(Global.bar_progress_speed_multiplier)
	elif bar_go_trip == false: #inverts the direction
		_on_timer_timeout(-Global.bar_progress_speed_multiplier)
	
	if bar_attack.value >= bar_attack.max_value:
		bar_go_trip = false
	elif bar_attack.value <= bar_attack.min_value:
		bar_go_trip = true

func _on_timer_timeout(bar_change):
	bar_attack.value += bar_change

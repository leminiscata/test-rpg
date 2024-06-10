class_name Player

var name: String
var level = 1
var experience_current = 0
var experience_max = 5
var health = 10
var power = 3
var defense = 1

func level_up():
	level += 1
	health += 5
	power += 1
	defense += 1
	experience_current -= experience_max
	experience_max += Global.experience_increment_for_lvup

func _ready():
	pass # Replace with function body.


func _process(delta):
	pass

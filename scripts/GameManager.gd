extends Node

@onready var tutorial_timer = $Tutorial_Timer

@onready var game_area = $GameArea

@onready var l_char_name = %L_Char_Name
@onready var l_char_level = %L_Char_Level
@onready var l_char_power = %L_Char_Power
@onready var l_char_exp = %L_Char_Exp

@onready var l_enemy_name = %L_Enemy_Name
@onready var l_enemy_health = %L_Enemy_Health
@onready var l_enemy_defense = %L_Enemy_Defense

@onready var b_attack = %B_Attack

@onready var bar_attack = %Bar_Attack
@onready var l_bar_result = %L_Bar_Result
@onready var l_bar_result_animator = %L_Bar_Result_Animator

@onready var l_progress = %L_Progress
@onready var l_hit = %L_Hit

@onready var enemyTexture = %enemy

@onready var l_announcement = %L_Announcement


##
var player = Player.new()
var enemy = Enemy.new()

var nameList = ["Odin", "Thor", "Freya", "Loki", "Frey", "Heimdall", "Tyr", "Balder", "Hodr", "Hermod", "Njord", "Skadi", "Ullr", "Hel", "Huginn", "Muninn", "Vidar", "Vali", "Ve", "Forseti", "Bragi", "Eir", "Gna", "Sif", "Sigyn", "Nanna", "Baldur", "Hoder", "Idun"]

func chooseName(): 
	nameList.shuffle()
	player.name = nameList[0]
	enemy.name = nameList[1]

func _ready():
	chooseName()
	announcement()
	#game_area.get_node("AnimationPlayer").play("appear")

func _process(delta):
	updateUI()
	
	if player.experience_current >= player.experience_max:
		player.level_up()

func _on_b_restart_pressed():
	get_tree().reload_current_scene()

func _on_b_attack_pressed():
	playerAttack()
	
func barResultLabelDisplay(region):
	l_bar_result.text = "[center]"
	match region:
		1:
			l_bar_result.text+="[b]AWESOME hug![/b]"
			l_bar_result_animator.play("region1")
		2: 
			l_bar_result.text+="[b]Nice hug[/b]"
			l_bar_result_animator.play("region2")
		3: 
			l_bar_result.text+="Regular hug..."
			l_bar_result_animator.play("region3")
		4: 
			l_bar_result.text+="Bad hug!"
			l_bar_result_animator.play("RESET")
	l_bar_result.text += "[/center]"

func barAssess(): 	#assess bar success
	var bar_max_half = bar_attack.max_value/2 # math trick to divide bar into two
	var bar_abs_difference = abs(bar_max_half - bar_attack.value) #finds the absolute difference between the current value and the half of the bar
	
	if bar_abs_difference <=5: #best region
		Global.bar_power_multiplier = 1
		barResultLabelDisplay(1)
	elif 6 <= bar_abs_difference && bar_abs_difference <= 20:
		Global.bar_power_multiplier = 0.75
		barResultLabelDisplay(2)
	elif 21 <= bar_abs_difference && bar_abs_difference <= 34:
		Global.bar_power_multiplier = 0.5
		barResultLabelDisplay(3)
	elif 35 <= bar_abs_difference && bar_abs_difference <= 50:
		Global.bar_power_multiplier = 0	
		barResultLabelDisplay(4)
		## Cheat sheet
		# 45-55 = 100% // with abs: 0-5
		# 30-44 , 56-70 = 75% // with abs: 6-20
		# 15-30 , 70-85 = 50% // with abs: 21-34
		# 0-15 , 85-100 = 0% // with abs: 35-50
		
func playerAttack():
	b_attack.get_node("AnimationPlayer").play("RESET")
	tutorial_timer.start(20)
	
	
	barAssess() #perform different actions depending on the bar result
	var enemyAnimator = enemyTexture.get_node("AnimationPlayer") #TODO fix and make this more global because I have to declare ti twice
	enemyAnimator.play("hugged")
	# hit logic
	var damage = (player.power * Global.bar_power_multiplier) - enemy.defense
	if damage <= 0:
		pass
	else:
		enemy.health -= damage
		
	l_hit.text = "bar: " + str(bar_attack.value) + "\n damage: " + str (damage) + "\n multiplier: " + str(Global.bar_power_multiplier)# debug log
	bar_attack.value = 0	#reset bar
	
	if enemy.health <= 0: #change enemy
		enemyChange()
		
func enemyChange():
	#changes enemy, stats
	enemy.level += 1
	enemy.health = 5 + 5 * enemy.level # health will be 10, 15, 20, etc
	enemy.defense = enemy.level
	
	Global.bar_progress_speed_multiplier += (enemy.level/3) #speeds up bar
	
	#changes enemy, visuals
	enemyTexture.frame = randi_range(0,8)
	var enemyAnimator = enemyTexture.get_node("AnimationPlayer")
	enemyAnimator.play("changeEnemy")
	enemy.name = nameList.pick_random()
	announcement() #play hug it out animation

	
	#grants exp
	player.experience_current += enemy.level * 3 #TODO balance
	
func announcement():
	l_announcement.text = "Hug it out with\n" + enemy.name
	l_announcement.get_node("AnimationPlayer").play("pop_up")
	
func updateUI():
	l_char_name.text = "Name: " + player.name
	l_char_level.text = "Level: " + str(player.level)
	l_char_power.text = "Hug Power: " + str(player.power)
	l_char_exp.text = "Exp: " + str(player.experience_current) + "/" + str(player.experience_max)
	l_progress.text = str(bar_attack.value)
	
	l_enemy_name.text = "Name: " + enemy.name
	l_enemy_health.text = "Hug Health: " + str(enemy.health)
	l_enemy_defense.text = "Hug Resistance: " + str(enemy.defense)

func _on_tutorial_timer_timeout():
	b_attack.get_node("AnimationPlayer").play("focus")

extends Node2D
class_name Root
var score := {ENUMS.SWORDSMAN.BLACK: 0, ENUMS.SWORDSMAN.BLUE: 0}
const RESET_PAUSE_TIME = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	connect_buttons_to_player_actions()
	$Restart.button_down.connect(restart_level)
	$Info.button_down.connect(show_info)

func show_info():
	get_tree().paused = not get_tree().paused
	$Credits.visible = not $Credits.visible

func connect_buttons_to_player_actions():
	#Utils.disconnect_all($Button1.button_down)
	#Utils.disconnect_all($Button2.button_down)
	$Button1.pressed.connect($Black.action)
	$Button2.pressed.connect($Blue.action)

func get_sword(item: ENUMS.HELD_ITEM) -> Sword: 
	if item == ENUMS.HELD_ITEM.SWORD_1:
		return $Sword1
	if item == ENUMS.HELD_ITEM.SWORD_2:
		return $Sword2
	assert(false)
	return null
func get_swords() -> Array:
	return [$Sword1, $Sword2]
func get_other_sword(item: ENUMS.HELD_ITEM) -> Sword:
	if item == ENUMS.HELD_ITEM.SWORD_1:
		return $Sword2
	if item == ENUMS.HELD_ITEM.SWORD_2:
		return $Sword1
	assert(false)
	return null

func get_swordsman(man: ENUMS.SWORDSMAN) -> Swordsman:
	if man == ENUMS.SWORDSMAN.BLACK:
		return $Black
	if man == ENUMS.SWORDSMAN.BLUE:
		return $Blue
	assert(false)
	return null
func get_swordsmen() -> Array:
	return [$Black, $Blue]
func get_other_swordsman(man: ENUMS.SWORDSMAN) -> Swordsman:
	if man == ENUMS.SWORDSMAN.BLACK:
		return $Blue
	if man == ENUMS.SWORDSMAN.BLUE:
		return $Black
	assert(false)
	return null
func get_other_swordsman_name(man: ENUMS.SWORDSMAN) -> ENUMS.SWORDSMAN:
	if man == ENUMS.SWORDSMAN.BLACK:
		return ENUMS.SWORDSMAN.BLUE
	if man == ENUMS.SWORDSMAN.BLUE:
		return ENUMS.SWORDSMAN.BLACK
	assert(false)
	return ENUMS.SWORDSMAN.BLUE

func died(man: ENUMS.SWORDSMAN):
	score[get_other_swordsman_name(man)] += 1
	update_ui()
	# If both players die within RESET_PAUSE_TIME,
	# we don't want reset to be called twice.
	if resetting: return
	if score[get_other_swordsman_name(man)] == ConstData.WIN_SCORE:
		get_tree().create_timer(RESET_PAUSE_TIME).timeout.connect(show_win_screen)
	else:
		get_tree().create_timer(RESET_PAUSE_TIME).timeout.connect(reset)
	resetting = true
func update_ui():
	$BlackScore.text = str(score[ENUMS.SWORDSMAN.BLACK])
	$BlueScore.text = str(score[ENUMS.SWORDSMAN.BLUE])
func randomize_spawns():
	var spawns = $Level/Spawns.get_children()
	var selected_spawn = Utils.select_random(spawns)
	#var selected_spawn = spawns[1]
	$Black.position = selected_spawn.get_node("Black").position
	$Blue.position = selected_spawn.get_node("Blue").position
var resetting := false
func reset():
	if has_node("Black"):
		$Black.free()
	if has_node("Blue"):
		$Blue.free()
	if has_node("Sword1"):
		$Sword1.free()
	if has_node("Sword2"):
		$Sword2.free()
	var black = load("res://Scenes/Components/Swordsman.tscn").instantiate().init(ENUMS.DIRECTION.RIGHT, ENUMS.SWORDSMAN.BLACK, ENUMS.HELD_ITEM.SWORD_1)
	var blue = load("res://Scenes/Components/Swordsman.tscn").instantiate().init(ENUMS.DIRECTION.LEFT, ENUMS.SWORDSMAN.BLUE, ENUMS.HELD_ITEM.SWORD_2)
	var sword1 = load("res://Scenes/Components/Sword.tscn").instantiate().init(ENUMS.DIRECTION.RIGHT, ENUMS.HELD_ITEM.SWORD_1, ENUMS.SWORD_STATE.HELD)
	var sword2 = load("res://Scenes/Components/Sword.tscn").instantiate().init(ENUMS.DIRECTION.LEFT, ENUMS.HELD_ITEM.SWORD_2, ENUMS.SWORD_STATE.HELD)
	add_child(sword1)
	add_child(sword2)
	add_child(black)
	add_child(blue)
	connect_buttons_to_player_actions()
	randomize_spawns()
	resetting = false
func show_win_screen():
	var black_wins = score[ENUMS.SWORDSMAN.BLACK] == ConstData.WIN_SCORE
	var blue_wins = score[ENUMS.SWORDSMAN.BLUE] == ConstData.WIN_SCORE
	if black_wins and blue_wins:
		$WinText.text = "It's a Draw"
	elif black_wins:
		$WinText.text = "Black Wins"
	elif blue_wins:
		$WinText.text = "Blue Wins"
	else:
		assert(false)
	$WinText.visible = true
	$Restart.visible = true
func restart_level():
	$WinText.visible = false
	$Restart.visible = false
	score[ENUMS.SWORDSMAN.BLACK] = 0
	score[ENUMS.SWORDSMAN.BLUE] = 0
	update_ui()
	reset()

extends Control
class_name Root
var score := {ENUMS.SWORDSMAN.BLACK: 0, ENUMS.SWORDSMAN.BLUE: 0}
const RESET_PAUSE_TIME = 3.0
var root: Root3

func set_level(node):
	$Level_Holder.add_child(node)

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	connect_buttons_to_player_actions()
	$Restart.button_down.connect(restart_level)
	$Info.button_down.connect(show_info)
	$Level_Holder/Level/HigherWalls.visible=true
	root = get_parent().get_parent()

func show_info():
	get_tree().paused = not get_tree().paused
	$Credits.visible = not $Credits.visible

func connect_buttons_to_player_actions():
	#Utils.disconnect_all($Button1.button_down)
	#Utils.disconnect_all($Button2.button_down)
	$Button1.pressed.connect($Black.action)
	$Button2.pressed.connect($Blue.action)

func get_button(man: ENUMS.SWORDSMAN) -> TouchScreenButton:
	if man == ENUMS.SWORDSMAN.BLACK:
		return $Button1
	if man == ENUMS.SWORDSMAN.BLUE:
		return $Button2
	assert(false)
	return null

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
	flash_score(man)
	make_sound()
	# If both players die within RESET_PAUSE_TIME,
	# we don't want reset to be called twice.
	if resetting: return
	if score[get_other_swordsman_name(man)] == ConstData.WIN_SCORE:
		get_tree().create_timer(RESET_PAUSE_TIME).timeout.connect(show_win_screen)
	else:
		get_tree().create_timer(RESET_PAUSE_TIME).timeout.connect(reset)
	resetting = true
func flash_score(man: ENUMS.SWORDSMAN):
	match man:
		ENUMS.SWORDSMAN.BLUE:
			flash_green($BlueScore)
		ENUMS.SWORDSMAN.BLACK:
			flash_green($BlackScore)
		_:
			assert(false)
func update_ui():
	$BlackScore.text = str(score[ENUMS.SWORDSMAN.BLACK])
	$BlueScore.text = str(score[ENUMS.SWORDSMAN.BLUE])
func make_sound():
	$AudioStreamPlayer2D.play()
func randomize_spawns():
	var spawns = $Level_Holder/Level/Spawns.get_children()
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
		$WinText.text = "Red Wins"
	elif blue_wins:
		$WinText.text = "Yellow Wins"
	else:
		assert(false)
	$WinText.visible = true
	$Restart.visible = true

func restart_level():
	var level_selector = load("res://Scenes/Level Selector.tscn").instantiate()
	root.put_in_container(level_selector)

func flash_green(node: Label):
	for i in range(5):
		node.add_theme_color_override("font_color", Color(0, 1, 0))
		await get_tree().create_timer(0.1).timeout
		node.add_theme_color_override("font_color", Color(1, 1, 1))
		await get_tree().create_timer(0.1).timeout

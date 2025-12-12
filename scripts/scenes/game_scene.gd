extends Node2D

const MINIMAP_PADDING := 0.5

@export var hud: HUD
@export var floor_name: String

@export var drop_point: Node2D
@export var pickup_scene: PackedScene
@export var pickup_configs: Array[PickupConfig]

# MINIMAP
@export var mini_map: TextureRect
@export var icons_root: Control
@export var minimap_icons: MinimapIconLibrary

# Icons created at runtime
var _player_icon: Sprite2D
var _lover_icons: Dictionary = {}

# Minimap bounds
var _min_x := 0.0
var _max_x := 0.0
var _min_y := 0.0
var _max_y := 0.0

var player: CharacterBody2D:
	get:
		return GlobalGameState.player

func _ready():
	_connect_game_manager()
	_setup_hud()

	_try_spawn_pickup()

	_calculate_minimap_bounds()
	_generate_minimap_background()
	_create_minimap_icons()

	LoverStateTracker.lover_state_changed.connect(_on_lover_state_changed)

	await get_tree().process_frame
	_refresh_all_icons()
	
	_connect_game_over_to_lovers()

func _process(delta):
	_update_player_icon()
	_update_lover_icons()

# --------------------------------------------------------------------------
# GAME MANAGER CONNECTIONS
# --------------------------------------------------------------------------

func _connect_game_manager():
	if not GameManager.updated_score.is_connected(hud.update_score):
		GameManager.updated_score.connect(hud.update_score)

	if not GameManager.updated_timer.is_connected(hud.update_timer):
		GameManager.updated_timer.connect(hud.update_timer)

	if not GameManager.updated_points.is_connected(hud.update_points):
		GameManager.updated_points.connect(hud.update_points)

	if not GameManager.game_over_signal.is_connected(hud.show_game_over):
		GameManager.game_over_signal.connect(hud.show_game_over)

	if not GameManager.game_over_signal.is_connected(player.on_game_over):
		GameManager.game_over_signal.connect(player.on_game_over)

	if not GameManager.click_bonus_over_signal.is_connected(hud.show_click_bonus_over):
		GameManager.click_bonus_over_signal.connect(hud.show_click_bonus_over)

func _connect_game_over_to_lovers():
	for lover in get_tree().get_nodes_in_group("lovers"):
		if GameManager.game_over_signal.is_connected(lover.on_game_over):
			continue
		GameManager.game_over_signal.connect(lover.on_game_over)

func _setup_hud():
	hud.update_points(GameManager.total_points)
	hud.update_score(GameManager.romanced_lovers, GameManager.total_lovers)
	hud.update_floor_name(floor_name)


# --------------------------------------------------------------------------
# PICKUP SPAWN
# --------------------------------------------------------------------------

func _try_spawn_pickup():
	var roll := randf()
	var sorted_configs := pickup_configs.duplicate()
	sorted_configs.sort_custom(_sort_by_chance)

	var cumulative := 0.0

	for config in sorted_configs:
		var next = cumulative + config.drop_chance

		if roll <= next:
			var item = pickup_scene.instantiate()
			item.config = config
			item.position = drop_point.position
			add_child(item)
			item.picked_up.connect(hud.show_pickup_popup)
			return

		cumulative = next


func _sort_by_chance(a, b) -> int:
	return int(a.drop_chance - b.drop_chance)


# --------------------------------------------------------------------------
# MINIMAP: BOUNDS
# --------------------------------------------------------------------------

func _calculate_minimap_bounds():
	var nodes = get_tree().get_nodes_in_group("lovers")

	var xs: Array[float] = []
	var ys: Array[float] = []

	for n in nodes:
		var p = n.global_position
		xs.append(p.x)
		ys.append(p.y)

	var raw_min_x = xs.min()
	var raw_max_x = xs.max()
	var raw_min_y = ys.min()
	var raw_max_y = ys.max()

	var width = raw_max_x - raw_min_x
	var height = raw_max_y - raw_min_y

	# Apply padding
	_min_x = raw_min_x - width * MINIMAP_PADDING
	_max_x = raw_max_x + width * MINIMAP_PADDING

	_min_y = raw_min_y - height * MINIMAP_PADDING
	_max_y = raw_max_y + height * MINIMAP_PADDING

func _world_to_minimap(pos: Vector2) -> Vector2:
	var nx: float = (pos.x - _min_x) / max(1.0, (_max_x - _min_x))
	var ny: float = (pos.y - _min_y) / max(1.0, (_max_y - _min_y))

	var w: float = mini_map.size.x
	var h: float = mini_map.size.y

	return Vector2(
		nx * w,
		ny * h
	)

# --------------------------------------------------------------------------
# MINIMAP: BACKGROUND
# --------------------------------------------------------------------------

func _generate_minimap_background():
	var w = int(mini_map.size.x)
	var h = int(mini_map.size.y)

	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color.BISQUE)

	var tex := ImageTexture.create_from_image(img)
	mini_map.texture = tex

# --------------------------------------------------------------------------
# MINIMAP: ICON CREATION
# --------------------------------------------------------------------------

func _create_minimap_icons():
	# PLAYER
	_player_icon = Sprite2D.new()
	_player_icon.texture = minimap_icons.player_icon
	_player_icon.centered = true
	icons_root.add_child(_player_icon)

	# LOVERS
	for lover in get_tree().get_nodes_in_group("lovers"):
		if not lover.has_meta("lover_id"):
			continue

		var id: String = lover.get_meta("lover_id")

		var status = LoverStateTracker.get_status(id)
		if status == LoverStateTracker.LoverStatus.SUCCEEDED:
			continue

		var icon := Sprite2D.new()
		icon.texture = minimap_icons.lover_default
		icon.centered = true

		icons_root.add_child(icon)
		_lover_icons[id] = icon

# --------------------------------------------------------------------------
# MINIMAP: UPDATE ICON POSITIONS
# --------------------------------------------------------------------------

func _update_player_icon():
	if _player_icon and is_instance_valid(player):
		_player_icon.position = _world_to_minimap(player.global_position)

func _update_lover_icons():
	for lover in get_tree().get_nodes_in_group("lovers"):
		if not lover.has_meta("lover_id"):
			continue

		var id: String = lover.get_meta("lover_id")
		var icon: Sprite2D = _lover_icons.get(id)

		if icon:
			icon.position = _world_to_minimap(lover.global_position)


# --------------------------------------------------------------------------
# MINIMAP: UPDATE ICON TEXTURES WHEN STATE CHANGES
# --------------------------------------------------------------------------

func _on_lover_state_changed(id: String):
	var icon: Sprite2D = _lover_icons.get(id)

	var status := LoverStateTracker.get_status(id)
	var can_click := LoverStateTracker.get_can_be_clicked(id)
	var expression := LoverStateTracker.get_expression(id)
	var partners := LoverStateTracker.get_partners(id)

	var lover := _find_lover_by_id(id)
	if lover == null:
		return

	# ---------------------------------------------------------
	# 1. SUCCESS → REMOVE ICON COMPLETELY
	# ---------------------------------------------------------
	if status == LoverStateTracker.LoverStatus.SUCCEEDED:
		if icon:
			icon.queue_free()
		_lover_icons.erase(id)
		return

	# ---------------------------------------------------------
	# 2. FAILED
	# ---------------------------------------------------------
	if status == LoverStateTracker.LoverStatus.FAILED:
		if icon:
			icon.texture = minimap_icons.lover_failed
		return

	# ---------------------------------------------------------
	# 3. BOSS LOGIC
	# ---------------------------------------------------------
	if lover.is_boss:
		icon.texture = minimap_icons.lover_boss
		return

	# ---------------------------------------------------------
	# 4. PARTNERED (NOT BOSS)
	# ---------------------------------------------------------
	if lover and lover.partner_manager.has_partners():
		icon.texture = minimap_icons.lover_partnered
		return

	# ---------------------------------------------------------
	# 5. SAD EXPRESSION
	# ---------------------------------------------------------
	if expression == "sad":
		icon.texture = minimap_icons.lover_sad
		return

	# ---------------------------------------------------------
	# 6. CLICK-BLOCKED (NOT BOSS, NOT PARTNERED, NOT FAILED)
	# ---------------------------------------------------------
	if !can_click:
		icon.texture = minimap_icons.lover_crush
		return

	# ---------------------------------------------------------
	# 7. FREE DEFAULT
	# ---------------------------------------------------------
	icon.texture = minimap_icons.lover_default


func _find_lover_by_id(id: String) -> Node:
	for lover in get_tree().get_nodes_in_group("lovers"):
		if lover.has_meta("lover_id") and lover.get_meta("lover_id") == id:
			return lover
	return null

func _refresh_all_icons():
	for id in _lover_icons.keys():
		_on_lover_state_changed(id)

@tool
extends Node2D

const SECTION_POINTS := 100
const POINT_SIZE := 100.0
const PLANE_FREQ := 7
const NITRO := preload("res://items/nitrous.tscn")
const COIN := preload("res://items/coin.tscn")
const MEDAL := preload("res://items/medal.tscn")

@export var noise_seed := -1 : set = _on_set_noise_seed
@export var lacunarity := 2.0 : set = _on_set_lacunarity
@export var scale_y := 2000.0 : set = _on_set_scale_y
@export var slope := 1.5 : set = _on_set_slope
@export var generate_items := true : set = _on_set_generate_items
@export_range(0, 1, 0.01) var dif_init := 0.2 : set = _on_set_dif_init
@export var texture_terrain: Texture2D : set = _on_set_texture_terrain
@export var texture_dirt: Texture2D : set = _on_set_texture_dirt

var _noise := FastNoiseLite.new()
var _section := 0
var _current_plane := 0
var _gold_medal := 0

@onready var _planes_preloader: ResourcePreloader = $PlanesPreloader
@onready var _rocks_preloader: ResourcePreloader = $RocksPreloader


func _ready() -> void:
	_gold_medal = 0
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	if noise_seed < 0:
		_noise.seed = randi()
	else:
		_noise.seed = noise_seed
	_noise.fractal_lacunarity = lacunarity
	_update_terrain()


func _process(_delta: float) -> void:
	var pos := 0.0
	if Engine.is_editor_hint():
		var trans := EditorInterface.get_editor_viewport_2d().global_canvas_transform
		pos = -trans.origin.x
		pos /= trans.get_scale().x
	else:
		pos = get_viewport().get_camera_2d().global_position.x
	var sec := floori(pos / (SECTION_POINTS * POINT_SIZE))
	if sec != _section:
		_section = sec
		_update_terrain()


func get_position_y(x : float):
	var sec : int = floori(x / (SECTION_POINTS * POINT_SIZE))
	var dif := minf(dif_init + (x / POINT_SIZE) * 0.001, 1.0)
	var plain := 1.0
	if generate_items and sec > 0 and sec % PLANE_FREQ == 0:
		var i := int((x - sec * SECTION_POINTS * POINT_SIZE) / float(POINT_SIZE))
		plain = maxf(cos(1.0 - absf((i - 50) / 50.0)) * 50 - 49, 0.1)
	var y := 800 + (_noise.get_noise_1d(x / POINT_SIZE) * scale_y * dif * plain) - (x / POINT_SIZE * slope)
	return y


func _create_terrain_section(sec : int) -> void:
	if has_node("Terrain" + str(sec)):
		return
	var points := PackedVector2Array()
	var points_line := PackedVector2Array()
	var height := sec * SECTION_POINTS * slope
	var dif := minf(dif_init + sec * SECTION_POINTS * 0.001, 1.0)
	var plain := 1.0 
	
	for i in SECTION_POINTS + 1:
		if generate_items and sec > 0 and sec % PLANE_FREQ == 0:
			plain = maxf(cos(1 - absf((i - 50) / 50.0)) * 50 - 49, 0.1)
		var np = Vector2((i + 1) * POINT_SIZE, get_position_y(((i + 1) * POINT_SIZE) + sec * SECTION_POINTS * POINT_SIZE) - 800)
		var point = Vector2(i * POINT_SIZE, _noise.get_noise_1d(i + sec * SECTION_POINTS) * scale_y * dif * plain - height)
		var angle = point.angle_to_point(np)
		points.append(point)
		points_line.append(point - Vector2.UP.rotated(angle) * 64)
		height += slope
		dif += 0.001
		dif = minf(dif, 1.0)
	
	# Colisión
	points.append(Vector2(SECTION_POINTS * POINT_SIZE, 10000 - height))
	points.append(Vector2(0, 10000 - height))
	var node_floor := StaticBody2D.new()
	var collision := CollisionPolygon2D.new()
	collision.visible = false
	node_floor.physics_material_override = PhysicsMaterial.new()
	node_floor.physics_material_override.friction = 1.0
	collision.polygon = points
	node_floor.add_child(collision)
	node_floor.name = "Terrain" + str(sec)
	add_child(node_floor)
	node_floor.position.y = 800
	node_floor.position.x = sec * SECTION_POINTS * POINT_SIZE
	
	# Línea de terreno
	var line := Line2D.new()
	line.texture = texture_terrain
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_NONE
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	line.width = 128
	line.points = points_line
	line.z_index = 2 # La línea siempre debe dibujarse arriba del polígono
	node_floor.add_child(line)
	
	# Polígono de terreno
	points_line[0].x = -5
	points_line[points_line.size() - 1].x = SECTION_POINTS * POINT_SIZE
	points_line.append(Vector2(SECTION_POINTS * POINT_SIZE, points_line[points_line.size() - 1].y + 10000))
	points_line.append(Vector2(-5, points_line[0].y + 10000))
	var poly := Polygon2D.new()
	poly.polygon = points_line
	poly.texture = texture_dirt
	poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	poly.texture_scale = Vector2(4.0, 4.0)
	poly.z_index = 1
	node_floor.add_child(poly)
	
	if Engine.is_editor_hint():
		return
	
	if generate_items and sec > 0 and sec % PLANE_FREQ == 0:
		var scene = _planes_preloader.get_resource(_planes_preloader.get_resource_list()[_current_plane]).instantiate()
		_current_plane = wrapi(_current_plane + 1, 0, _planes_preloader.get_resource_list().size())
		scene.position.x = 5000
		scene.position.y = get_position_y(5000 + sec * SECTION_POINTS * POINT_SIZE) - 800
		node_floor.add_child(scene)
		if scene.has_method(&"set_terrain"):
			scene.set_terrain(self)
		# Medallas
		if _gold_medal < 4:
			_gold_medal += 1
			var medal = MEDAL.instantiate()
			medal.position.x = 4000
			medal.position.y = get_position_y(medal.position.x + sec * SECTION_POINTS * POINT_SIZE) - 900
			node_floor.add_child(medal)
	
	# Puntos de nitro
	if generate_items and sec % 2:
		var nitro = NITRO.instantiate()
		nitro.position.x = 4890
		nitro.position.y = get_position_y(4890 + sec * SECTION_POINTS * POINT_SIZE) - 900
		node_floor.add_child(nitro)
	
	# Monedas
	if generate_items:
		for n in 7:
			var coin = COIN.instantiate()
			coin.position.x = 5000 + (n * 110)
			coin.position.y = get_position_y(coin.position.x + sec * SECTION_POINTS * POINT_SIZE) - 900
			node_floor.add_child(coin)
	
	# Rocas
	if generate_items and sec > 0 and sec % PLANE_FREQ != 0:
		var posx = randi() % int(SECTION_POINTS * POINT_SIZE)
		for n in 30:
			var rock = _rocks_preloader.get_resource(Array(_rocks_preloader.get_resource_list()).pick_random()).instantiate()
			rock.position.x = posx + randf_range(-50, 50)
			rock.position.y = get_position_y(rock.position.x + sec * SECTION_POINTS * POINT_SIZE) - 1000
			rock.resize(randf_range(0.2, 0.3))
			node_floor.add_child(rock)


func _update_terrain() -> void:
	if Engine.is_editor_hint():
		if noise_seed < 0:
			_noise.seed = randi()
		else:
			_noise.seed = noise_seed
		_noise.fractal_lacunarity = lacunarity
		for child in get_children():
			if child.name.begins_with("Terrain"):
				child.name += "free"
				child.queue_free()
	if has_node("Terrain" + str(_section - 2)):
		get_node("Terrain" + str(_section - 2)).queue_free()
	if has_node("Terrain" + str(_section + 2)):
		get_node("Terrain" + str(_section + 2)).queue_free()
	_create_terrain_section(_section - 1)
	_create_terrain_section(_section)
	_create_terrain_section(_section + 1)


func _on_set_noise_seed(value : int) -> void:
	noise_seed = value
	if Engine.is_editor_hint():
		_update_terrain()


func _on_set_lacunarity(value : float) -> void:
	lacunarity = value
	if Engine.is_editor_hint():
		_update_terrain()


func _on_set_scale_y(value : float) -> void:
	scale_y = value
	if Engine.is_editor_hint():
		_update_terrain()


func _on_set_slope(value : float) -> void:
	slope = value
	if Engine.is_editor_hint():
		_update_terrain()


func _on_set_generate_items(value : bool) -> void:
	generate_items = value
	if Engine.is_editor_hint():
		_update_terrain()


func _on_set_dif_init(value : float) -> void:
	dif_init = value
	if Engine.is_editor_hint():
		_update_terrain()


func _on_set_texture_terrain(value : Texture2D) -> void:
	texture_terrain = value
	if Engine.is_editor_hint():
		_update_terrain()


func _on_set_texture_dirt(value : Texture2D) -> void:
	texture_dirt = value
	if Engine.is_editor_hint():
		_update_terrain()

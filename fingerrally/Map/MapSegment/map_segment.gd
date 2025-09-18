extends Node2D

class_name MapSegment

const size = Vector2(2200, 5000)
const base_point = Vector2(1050, 2500)
const road_offset = 1460
const grid_y = 30
const grid_x = 15
const object_offset = 30
const breakables_ratio = 0.3
const sign_ratio = 0.1

const snow_tree_scene = preload("res://Map/MapSegment/Obstacles/Unbreakable/SnowTree.tscn")
const tree_scene = preload("res://Map/MapSegment/Obstacles/Unbreakable/Tree.tscn")
const stone_scene = preload("res://Map/MapSegment/Obstacles/Unbreakable/Stone.tscn")
const round_stone_scene = preload("res://Map/MapSegment/Obstacles/Unbreakable/RoundStone.tscn")
const sign_scene = preload("res://Map/MapSegment/Obstacles/Breakable/Sign.tscn")
const bush_scene = preload("res://Map/MapSegment/Obstacles/Breakable/Bush.tscn")
const cactus_scene = preload("res://Map/MapSegment/Obstacles/Breakable/Cactus.tscn")
const snowman_scene = preload("res://Map/MapSegment/Obstacles/Breakable/Snowman.tscn")

@onready var base_sprite = $BaseSprite
@onready var road_sprite = $RoadSprite
@onready var snow_effect = $Snow
@onready var rain_effect = $Rain

var config: MapSegmentConfig
var rng = RandomNumberGenerator.new()

var thread: Thread

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if base_sprites.has(config.base_description):
		base_sprite.texture = base_sprites[config.base_description]
	if road_sprites.has(config.road_description):
		road_sprite.texture = road_sprites[config.road_description]
	snow_effect.emitting = config.surface == Surface.TYPE.SNOW
	rain_effect.emitting = config.surface == Surface.TYPE.GRAVEL
	thread = Thread.new()
	thread.start(fill_objects.bind(road_sprite.texture))

func _exit_tree():
	thread.wait_to_finish()

func fill_objects(road_texture: CompressedTexture2D):
	var image: Image
	if road_texture != null:
		image = road_texture.get_image()
	else:
		image = null
	for i in range(grid_x):
		for j in range(grid_y):
			if rng.randf() < config.object_intencity:
				var x = size.x / grid_x * i
				var y = size.y / grid_y * j
				var pos = Vector2(x, y) - base_point
				var offset = Vector2(rng.randf_range(-object_offset, object_offset), rng.randf_range(-object_offset, object_offset))
				if MapSegment.is_pixel_transparent(image, x + road_offset, y):
					var brakable = rng.randf() < breakables_ratio
					var node = generate_breakable() if brakable else generate_unbreakable()
					node.position = pos + offset
					_add_child.call_deferred(node)

func _add_child(node_to_add: Node2D):
	add_child(node_to_add)

static func is_pixel_transparent(image: Image, x: int, y: int) -> bool:
	if image == null:
		return true
	else:
		return image.get_pixel(x, y).a == 0.0

func generate_breakable() -> Node2D:
	var is_sign = rng.randf() < sign_ratio
	if is_sign:
		return generate_sign()
	match config.surface:
		Surface.TYPE.ASPHALT:
			return Node2D.new()
		Surface.TYPE.DIRT:
			var type = rng.randi_range(1, 3)
			var node = bush_scene.instantiate()
			node.type = type
			return node
		Surface.TYPE.SNOW:
			var reversed = rng.randf() > 0.5
			var node = snowman_scene.instantiate()
			node.reversed = reversed
			return node
		Surface.TYPE.SAND:
			var reversed = rng.randf() > 0.5
			var node = cactus_scene.instantiate()
			node.reversed = reversed
			return node
		Surface.TYPE.GRAVEL:
			return Node2D.new()
		_:
			return Node2D.new()


func generate_sign() -> Node2D:
	var reversed = rng.randf() > 0.5
	var node = sign_scene.instantiate()
	node.reversed = reversed
	return node


func generate_unbreakable() -> Node2D:
	match config.surface:
		Surface.TYPE.ASPHALT:
			return Node2D.new()
		Surface.TYPE.DIRT:
			var i = rng.randi_range(1, 3)
			var sprite = unbreakable_sprites["D" + str(i)]
			if sprite != null:
				var random_scale = rng.randf_range(1.0, 2.0)
				var node = tree_scene.instantiate()
				node.texture = sprite
				node.scale = Vector2(random_scale, random_scale)
				return node
			else:
				return Node2D.new()
		Surface.TYPE.SNOW:
			var i = rng.randi_range(1, 3)
			var sprite = unbreakable_sprites["S" + str(i)]
			if sprite != null:
				var random_scale = rng.randf_range(1.0, 2.0)
				var node = snow_tree_scene.instantiate()
				node.texture = sprite
				node.scale = Vector2(random_scale, random_scale)
				return node
			else:
				return Node2D.new()
		Surface.TYPE.SAND:
			var i = rng.randi_range(1, 3)
			var sprite = unbreakable_sprites["Sa" + str(i)]
			if sprite != null:
				var random_scale = rng.randf_range(0.6, 1.5)
				var node = stone_scene.instantiate()
				node.texture = sprite
				node.scale = Vector2(random_scale, random_scale)
				return node
			else:
				return Node2D.new()
		Surface.TYPE.GRAVEL:
			var i = rng.randi_range(1, 3)
			var sprite = unbreakable_sprites["G" + str(i)]
			if sprite != null:
				var random_scale = rng.randf_range(0.6, 1)
				var random_rotation = rng.randf_range(0, 360)
				var node = round_stone_scene.instantiate()
				node.texture = sprite
				node.scale = Vector2(random_scale, random_scale)
				node.rotation_degrees = random_rotation
				return node
			else:
				return Node2D.new()
		_:
				return Node2D.new()


const base_sprites = {
	"S1": preload("res://Resourses/Assets/Maps/S1.png"),
	"S2": preload("res://Resourses/Assets/Maps/S2.png"),
	"S3": preload("res://Resourses/Assets/Maps/S3.png"),
	"S4": preload("res://Resourses/Assets/Maps/S4.png"),
	
	"T12": preload("res://Resourses/Assets/Maps/T12.png"),
	"T13": preload("res://Resourses/Assets/Maps/T13.png"),
	"T14": preload("res://Resourses/Assets/Maps/T14.png"),
	"T21": preload("res://Resourses/Assets/Maps/T21.png"),
	"T23": preload("res://Resourses/Assets/Maps/T23.png"),
	"T24": preload("res://Resourses/Assets/Maps/T24.png"),
	"T31": preload("res://Resourses/Assets/Maps/T31.png"),
	"T32": preload("res://Resourses/Assets/Maps/T32.png"),
	"T34": preload("res://Resourses/Assets/Maps/T34.png"),
	"T41": preload("res://Resourses/Assets/Maps/T41.png"),
	"T42": preload("res://Resourses/Assets/Maps/T42.png"),
	"T43": preload("res://Resourses/Assets/Maps/T43.png"),
}

const road_sprites = {
	"S11": preload("res://Resourses/Assets/Maps/S11.png"),
	"S12": preload("res://Resourses/Assets/Maps/S12.png"),
	"S13": preload("res://Resourses/Assets/Maps/S13.png"),
	"S14": preload("res://Resourses/Assets/Maps/S14.png"),
	"S15": preload("res://Resourses/Assets/Maps/S15.png"),
	"S16": preload("res://Resourses/Assets/Maps/S16.png"),
	"S17": preload("res://Resourses/Assets/Maps/S17.png"),
	"S18": preload("res://Resourses/Assets/Maps/S18.png"),
	"S19": preload("res://Resourses/Assets/Maps/S19.png"),
	"S110": preload("res://Resourses/Assets/Maps/S110.png"),

	"S21": preload("res://Resourses/Assets/Maps/S21.png"),
	"S22": preload("res://Resourses/Assets/Maps/S22.png"),
	"S23": preload("res://Resourses/Assets/Maps/S23.png"),
	"S24": preload("res://Resourses/Assets/Maps/S24.png"),
	"S25": preload("res://Resourses/Assets/Maps/S25.png"),
	"S26": preload("res://Resourses/Assets/Maps/S26.png"),
	"S27": preload("res://Resourses/Assets/Maps/S27.png"),
	"S28": preload("res://Resourses/Assets/Maps/S28.png"),
	"S29": preload("res://Resourses/Assets/Maps/S29.png"),
	"S210": preload("res://Resourses/Assets/Maps/S210.png"),

	"S31": preload("res://Resourses/Assets/Maps/S31.png"),
	"S32": preload("res://Resourses/Assets/Maps/S32.png"),
	"S33": preload("res://Resourses/Assets/Maps/S33.png"),
	"S34": preload("res://Resourses/Assets/Maps/S34.png"),
	"S35": preload("res://Resourses/Assets/Maps/S35.png"),
	"S36": preload("res://Resourses/Assets/Maps/S36.png"),
	"S37": preload("res://Resourses/Assets/Maps/S37.png"),
	"S38": preload("res://Resourses/Assets/Maps/S38.png"),
	"S39": preload("res://Resourses/Assets/Maps/S39.png"),
	"S310": preload("res://Resourses/Assets/Maps/S310.png"),

	"S41": preload("res://Resourses/Assets/Maps/S41.png"),
	"S42": preload("res://Resourses/Assets/Maps/S42.png"),
	"S43": preload("res://Resourses/Assets/Maps/S43.png"),
	"S44": preload("res://Resourses/Assets/Maps/S44.png"),
	"S45": preload("res://Resourses/Assets/Maps/S45.png"),
	"S46": preload("res://Resourses/Assets/Maps/S46.png"),
	"S47": preload("res://Resourses/Assets/Maps/S47.png"),
	"S48": preload("res://Resourses/Assets/Maps/S48.png"),
	"S49": preload("res://Resourses/Assets/Maps/S49.png"),
	"S410": preload("res://Resourses/Assets/Maps/S410.png"),
}

const unbreakable_sprites = {
	"D1": preload("res://Resourses/Assets/Maps/T1.png"),
	"D2": preload("res://Resourses/Assets/Maps/T2.png"),
	"D3": preload("res://Resourses/Assets/Maps/T3.png"),
	"S1": preload("res://Resourses/Assets/Maps/ST1.png"),
	"S2": preload("res://Resourses/Assets/Maps/ST2.png"),
	"S3": preload("res://Resourses/Assets/Maps/ST3.png"),
	"Sa1": preload("res://Resourses/Assets/Maps/Stone1.png"),
	"Sa2": preload("res://Resourses/Assets/Maps/Stone2.png"),
	"Sa3": preload("res://Resourses/Assets/Maps/Stone3.png"),
	"G1": preload("res://Resourses/Assets/Maps/RS1.png"),
	"G2": preload("res://Resourses/Assets/Maps/RS2.png"),
	"G3": preload("res://Resourses/Assets/Maps/RS3.png"),
}

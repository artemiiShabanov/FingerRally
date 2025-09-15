extends Node2D

class_name MapSegment

@onready var base_sprite = $BaseSprite
@onready var road_sprite = $RoadSprite

var config: MapSegmentConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if base_sprites.has(config.base_description):
		base_sprite.texture = base_sprites[config.base_description]
	if road_sprites.has(config.road_description):
		road_sprite.texture = road_sprites[config.road_description]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

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

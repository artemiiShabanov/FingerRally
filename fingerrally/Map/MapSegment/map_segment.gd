extends Node2D

class_name MapSegment

@onready var base_sprite = $BaseSprite

var config: MapSegmentConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clip_children = CanvasItem.CLIP_CHILDREN_MAX
	base_sprite.texture = biom_sprites[config.base_description]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

const biom_sprites = {
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

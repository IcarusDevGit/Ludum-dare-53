extends Control

@export var id = 0
@export var output = 0
@export var cost = 0
@export var upkeep = 0
@export var atlasPos = Vector2i(0,1)
@onready var player = get_tree().get_root().get_child(0).get_node("Player")


func _ready():
	setup()


func setup():
	$Cost.text = "Cost: " + str(cost)
	$Upkeep.text = "Upkeep: " + str(upkeep)
	$Output.text = "Output: " + str(output)


func _process(delta):
	if Input.is_action_just_pressed("lmb"):
		if get_global_rect().has_point(get_viewport().get_mouse_position()):
			player.OnBuildingSelectorClicked([id, cost, upkeep, output, atlasPos])


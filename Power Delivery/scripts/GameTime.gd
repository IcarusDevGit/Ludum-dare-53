extends Timer

@export var timeStep = 5.0

func _ready():
	start(timeStep)
	connect("timeout", OnTimeout)


func OnTimeout():
	get_parent().get_node("Player").TimeStep()
	get_parent().get_node("City").TimeStep()


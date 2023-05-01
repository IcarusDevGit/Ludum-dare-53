extends Node

var buildingSelected
var cellSize = Vector2i(32,32)

var money = 2000
var totalUpkeep = 0
var powerOutput = 0

@onready var map: TileMap = get_parent()


func _ready():
	UpdateLabels()


func _process(delta):
	if buildingSelected:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		$Preview.visible = true
		$Preview.frame = buildingSelected[0]
		$Preview.position = map.local_to_map(get_viewport().get_mouse_position()) * cellSize
		
		if Input.is_action_just_pressed("rmb"):
			buildingSelected = null
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	else:
		$Preview.visible = false
	
	if Input.is_action_just_pressed("lmb") and buildingSelected:
		var cellNeeded #Grass or water
		if buildingSelected[0] == 4 or buildingSelected[0] == 5 or buildingSelected[0] == 6:
			cellNeeded = Vector2i(0,0)
		else:
			cellNeeded = Vector2i(1,0)
		var cellSelected = map.local_to_map(get_viewport().get_mouse_position()) - Vector2i(3,3)
		if map.get_used_cells_by_id(0, 0, cellNeeded).has(cellSelected):
			if !map.get_used_cells_by_id(0, 0, buildingSelected[4]).has(cellSelected):
				Build(cellSelected)


func UpdateLabels():
	map.get_node("UI/PlayerMoney").text = "Money: " + str(money)
	map.get_node("UI/MonthlyExpenses").text = "Monthly Expenses: " + str(totalUpkeep)
	map.get_node("UI/PowerOutput").text = "Power Output: " + str(powerOutput) + " mW"


func Build(cell):
	if !money >= buildingSelected[1]:
		$InvalidSound.play()
		$NoMoney.visible = true
		await get_tree().create_timer(1).timeout
		$NoMoney.visible = false
		return
	
	$BuildSound.play()
	map.set_cell(0, cell, 0, buildingSelected[4])
	money -= buildingSelected[1]
	totalUpkeep += buildingSelected[2]
	powerOutput += buildingSelected[3]
	
	UpdateLabels()
	map.get_node("City").UpdatePowerDemand()


func TimeStep():
	var taxes = get_parent().get_node("City").totalTaxes
	var profit = taxes - totalUpkeep
	money += profit
	get_parent().get_node("UI/Profit").text = "Profit: " + str(profit)
	UpdateLabels()


func OnBuildingSelectorClicked(data):
	$SelectSound.play()
	buildingSelected = data
	Input.warp_mouse(map.map_to_local(Vector2i(4,4)))


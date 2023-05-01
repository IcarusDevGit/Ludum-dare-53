extends Node


var powerDemand
var totalTaxes
var developmentGrowth

@onready var map: TileMap = get_parent()
@onready var player = get_parent().get_node("Player")

@export var houseTiles = [
	Vector2i(5,5),
	Vector2i(5,6),
	Vector2i(5,7),
	Vector2i(6,5),
	Vector2i(6,6),
	Vector2i(6,7),
]
var highDensityTiles = []


func _ready():
	randomize()
	setupTiles()


func setupTiles():
	for house in houseTiles:
		map.set_cell(0, house, 0, Vector2i(2,0))
	UpdatePowerDemand()


func UpdatePowerDemand():
	powerDemand = 0
	totalTaxes = 0
	for house in houseTiles:
		powerDemand += 1
		totalTaxes += 6
	for building in highDensityTiles:
		powerDemand += 2
		totalTaxes += 20
	
	var powerOutput = player.powerOutput
	developmentGrowth = (powerOutput - powerDemand + (highDensityTiles.size() / 5.0)) / 2.0
	
	get_parent().get_node("UI/DevelopmentGrowth").text = "Development Growth: " + str(developmentGrowth)
	get_parent().get_node("UI/PowerDemand").text = "Power Demand: " + str(powerDemand) + " mW"
	get_parent().get_node("UI/Monthly Taxes").text = "Monthly Taxes: " + str(totalTaxes)


func TimeStep():
	var grassCells = map.get_used_cells_by_id(0, 0, Vector2i(0,0))
	var houseCellsQueue = []
	var highDensityCellsQueue = []
	for house in houseTiles:
		if !randf() < (developmentGrowth / 100.0):
			continue
		
		var NeighbourCells = [
		Vector2i(-1,-1) + house,
		Vector2i(0,-1) + house,
		Vector2i(1,-1) + house,
		Vector2i(-1,0) + house,
		Vector2i(1,0) + house,
		Vector2i(-1,1) + house,
		Vector2i(0,1) + house,
		Vector2i(1,1) + house,
		]
		
		var availableNeighbourCells = []
		for cell in NeighbourCells:
			if grassCells.has(cell) and !houseCellsQueue.has(cell):
				availableNeighbourCells.append(cell)
		
		if availableNeighbourCells == []:
			highDensityCellsQueue.append(house)
		else:
			var randomCell = availableNeighbourCells.pick_random()
			houseCellsQueue.append(randomCell)
	
	for houseSlot in max(int(developmentGrowth / 2.0), 2):
		if houseCellsQueue == []:
			break
		var house = houseCellsQueue.pick_random()
		houseCellsQueue.erase(house)
		houseTiles.append(house)
		map.set_cell(0, house, 0, Vector2i(2,0))
	
	for buildingSlot in max(int(developmentGrowth / 2.0), 2):
		if highDensityCellsQueue == []:
			break
		var building = highDensityCellsQueue.pick_random()
		highDensityCellsQueue.erase(building)
		highDensityTiles.append(building)
		houseCellsQueue.erase(building)
		developmentGrowth += 1
		map.set_cell(0, building, 0, Vector2i(3,0))
	
	UpdatePowerDemand()
	


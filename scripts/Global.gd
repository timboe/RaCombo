extends Node
tool

var last_pressed = null

var data = {
	"sol": {
		"name": "",
		"color": Color(0.0, 0.0, 0.0),
		"resource": false
	},
	"hydrogen": {
		"name": "H",
		"color": Color(1.0, 0.0, 0.0),
		"resource": false
	},
	"iron": {
		"name": "Ir",
		"color": Color(0.0, 0.0, 1.0),
		"resource": true
	},
	"copper": {
		"name": "Cu",
		"color": Color(1.0, 1.0, 0.0),
		"resource": true
	},
	"steel": {
		"name": "St",
		"color": Color(1.0, 0.5, 0.0),
		"resource": true
	},
	"silica": {
		"name": "Si",
		"color": Color(0.8, 0.8, 0.0),
		"resource": true
	},
	"glass": {
		"name": "G",
		"color": Color(0.6, 0.9, 0.6),
		"resource": false
	},
	"packed_hydrogen": {
		"name": "Hi",
		"color": Color(0.75, 0.0, 0.0),
		"resource": false
	},
	"cunife": {
		"name": "Cf",
		"color": Color(0.75, 0.0, 0.0),
		"resource": true
	},
	"tritium": {
		"name": "T",
		"color": Color(1.0, 1.0, 0.0),
		"resource": false
	},
	"packed_gas": {
		"name": "Bg",
		"color": Color(1.0, 0.0, 0.5),
		"resource": false
	},
	"metalic_tritium": {
		"name": "Mt",
		"color": Color(1.0, 0.5, 0.5),
		"resource": false
	},
	"xotic_a": {
		"name": "XA",
		"color": Color(1.0, 0.5, 0.5),
		"resource": true
	},
	"xotic_b": {
		"name": "XB",
		"color": Color(0.5, 1.5, 0.5),
		"resource": false
	},
	"xotic_c": {
		"name": "XC",
		"color": Color(0.5, 0.5, 1.0),
		"resource": false
	},
	"sw": {
		"name": "SW",
		"color": Color(0.2, 0.7, 0.4),
		"resource": true
	},
}

func _ready():
	print("Globals loaded")

extends Node
tool

var last_pressed = null
var last_pressed_paused = null

var level : int = 99
var rings : int = 10

var data = {
	"none": {
		"name": "",
		"color": Color(0.0, 0.0, 0.0),
		"mode": "extract",
	},
	"sol": {
		"name": "",
		"color": Color(0.0, 0.0, 0.0),
		"mode": "extract",
	},
	"hydrogen": {
		"name": "H",
		"color": Color(1.0, 0.0, 0.0),
		"mode": "extract",
	},
	"iron": {
		"name": "Ir",
		"color": Color(0.0, 0.0, 1.0),
		"mode": "insert"
	},
	"copper": {
		"name": "Cu",
		"color": Color(1.0, 1.0, 0.0),
		"mode": "insert"
	},
	"steel": {
		"name": "St",
		"color": Color(1.0, 0.5, 0.0),
		"mode": "insert"
	},
	"silica": {
		"name": "Si",
		"color": Color(0.8, 0.8, 0.0),
		"mode": "insert"
	},
	"glass": {
		"name": "G",
		"color": Color(0.6, 0.9, 0.6),
		"mode": "extract",
	},
	"packed_hydrogen": {
		"name": "Hi",
		"color": Color(0.75, 0.0, 0.0),
		"mode": "extract",
	},
	"cunife": {
		"name": "Cf",
		"color": Color(0.75, 0.0, 0.0),
		"mode": "insert"
	},
	"tritium": {
		"name": "T",
		"color": Color(1.0, 1.0, 0.0),
		"mode": "extract",
	},
	"packed_gas": {
		"name": "Bg",
		"color": Color(1.0, 0.0, 0.5),
		"mode": "extract",
	},
	"metalic_tritium": {
		"name": "Mt",
		"color": Color(1.0, 0.5, 0.5),
		"mode": "extract",
	},
	"xotic_a": {
		"name": "XA",
		"color": Color(1.0, 0.5, 0.5),
		"mode": "insert"
	},
	"xotic_b": {
		"name": "XB",
		"color": Color(0.5, 1.5, 0.5),
		"mode": "extract",
	},
	"xotic_c": {
		"name": "XC",
		"color": Color(0.5, 0.5, 1.0),
		"mode": "extract",
	},
	"cg": {
		"name": "CG",
		"color": Color(0.4, 0.3, 0.7),
		"mode": "extract"
	},
	"sw": {
		"name": "SW",
		"color": Color(0.2, 0.7, 0.4),
		"mode": "extract"
	},
}

var recipies = {
	"steel": {
		"level": 2,
		"time": 1.0,
		"amount_in": [1],
		"amount_out": 1,
		"input": ["iron"],
	},
	"packed_hydrogen": {
		"level": 2,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["hydrogen", "steel"],
	},
	"cunife": {
		"level": 3,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["iron", "copper"],
	},
	"tritium": { # Note: Not a factory recipy
		"level": 3,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["cunife", "sol"],
	},
	"packed_gas": {
		"level": 3,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["hydrogen", "tritium"],
	},
	"metalic_tritium": {
		"level": 4,
		"time": 1.0,
		"amount_in": [1, 1, 1],
		"amount_out": 1,
		"input": ["copper", "steel", "tritium"],
	},
	"xotic_a": {
		"level": 5,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["hydrogen", "cunife"],
	},
	"xotic_b": {
		"level": 5,
		"time": 1.0,
		"amount_in": [1],
		"amount_out": 1,
		"input": ["xotic_a"],
	},
	"xotic_c": {
		"level": 5,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["xotic_b", "copper"],
	},
	"glass": {
		"level": 6,
		"time": 1.0,
		"amount_in": [1],
		"amount_out": 1,
		"input": ["silica"],
	},
	"cg": {
		"level": 6,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["packed_gas", "copper"],
	},
	"sw": {
		"level": 6,
		"time": 1.0,
		"amount_in": [1, 1, 1],
		"amount_out": 1,
		"input": ["iron", "cg", "glass"],
	},
}

func _ready():
	print("Globals loaded")

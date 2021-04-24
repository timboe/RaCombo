extends Node
tool

# Constants
const M_SOL := 80
const INSERTER_RADIUS_MOD = 0.2
const MAX_STORAGE := 49

enum {BUILDING_UNSET, BUILDING_EXTRACTOR, BUILDING_INSERTER, BUILDING_FACTORY}
enum {OUTWARDS, INWARDS}

# Helper globals
var last_pressed = null

# Current level & configuration globals
var level : int = 99
var rings : int = 10

# Game data
var data = {
	"none": {
		"name": "",
		"color": Color(0.0, 0.0, 0.0),
		"mode": "extract",
		"shape": "circle",
		"builtin": true,
	},
	"sol": {
		"name": "",
		"color": Color(0.0, 0.0, 0.0),
		"mode": "extract",
		"shape": "triangle",
		"builtin": true,
	},
	"hydrogen": {
		"name": "H",
		"color": Color(1.0, 0.0, 0.0),
		"mode": "extract",
		"shape": "diamond",
		"builtin": true,
	},
	"iron": {
		"name": "Ir",
		"color": Color(0.0, 0.0, 1.0),
		"mode": "insert",
		"shape": "trapezoid",
		"builtin": true,
	},
	"copper": {
		"name": "Cu",
		"color": Color(1.0, 1.0, 0.0),
		"mode": "insert",
		"shape": "circle",
		"builtin": true,
	},
	"steel": {
		"name": "St",
		"color": Color(1.0, 0.5, 0.0),
		"mode": "insert",
		"shape": "triangle",
		"builtin": true,
	},
	"silica": {
		"name": "Si",
		"color": Color(0.8, 0.8, 0.0),
		"mode": "insert",
		"shape": "diamond",
		"builtin": true,
	},
	"glass": {
		"name": "G",
		"color": Color(0.6, 0.9, 0.6),
		"mode": "extract",
		"shape": "trapezoid",
		"builtin": true,
	},
	"packed_hydrogen": {
		"name": "Hi",
		"color": Color(0.75, 0.0, 0.0),
		"mode": "extract",
		"shape": "circle",
		"builtin": true,
	},
	"cunife": {
		"name": "Cf",
		"color": Color(0.75, 0.0, 0.8),
		"mode": "insert",
		"shape": "triangle",
		"builtin": true,
	},
	"tritium": {
		"name": "T",
		"color": Color(1.0, 1.0, 0.0),
		"mode": "extract",
		"shape": "diamond",
		"builtin": true,
	},
	"packed_gas": {
		"name": "Bg",
		"color": Color(1.0, 0.0, 0.5),
		"mode": "extract",
		"shape": "trapezoid",
		"builtin": true,
	},
	"metalic_tritium": {
		"name": "Mt",
		"color": Color(1.0, 0.5, 0.5),
		"mode": "extract",
		"shape": "circle",
		"builtin": true,
	},
	"xotic_a": {
		"name": "XA",
		"color": Color(1.0, 0.5, 0.5),
		"mode": "insert",
		"shape": "triangle",
		"builtin": true,
	},
	"xotic_b": {
		"name": "XB",
		"color": Color(0.5, 1.5, 0.5),
		"mode": "extract",
		"shape": "diamond",
		"builtin": true,
	},
	"xotic_c": {
		"name": "XC",
		"color": Color(0.5, 0.5, 1.0),
		"mode": "extract",
		"shape": "trapezoid",
		"builtin": true,
	},
	"cg": {
		"name": "CG",
		"color": Color(0.4, 0.3, 0.7),
		"mode": "extract",
		"shape": "circle",
		"builtin": true,
	},
	"sw": {
		"name": "SW",
		"color": Color(0.2, 0.7, 0.4),
		"mode": "extract",
		"shape": "triangle",
		"builtin": true,
	},
}

var recipies = {
	"steel": {
		"level": 2,
		"time": 1.0,
		"amount_in": [1],
		"amount_out": 1,
		"input": ["iron"],
		"builtin": true,
	},
	"packed_hydrogen": {
		"level": 2,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["hydrogen", "steel"],
		"builtin": true,
	},
	"cunife": {
		"level": 3,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["iron", "copper"],
		"builtin": true,
	},
	"tritium": { # Note: Not a factory recipy
		"level": 3,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["cunife", "sol"],
		"builtin": true,
	},
	"packed_gas": {
		"level": 3,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["hydrogen", "tritium"],
		"builtin": true,
	},
	"metalic_tritium": {
		"level": 4,
		"time": 1.0,
		"amount_in": [1, 1, 1],
		"amount_out": 1,
		"input": ["copper", "steel", "tritium"],
		"builtin": true,
	},
	"xotic_a": {
		"level": 5,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["hydrogen", "cunife"],
		"builtin": true,
	},
	"xotic_b": {
		"level": 5,
		"time": 1.0,
		"amount_in": [1],
		"amount_out": 1,
		"input": ["xotic_a"],
		"builtin": true,
	},
	"xotic_c": {
		"level": 5,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["xotic_b", "copper"],
		"builtin": true,
	},
	"glass": {
		"level": 6,
		"time": 1.0,
		"amount_in": [1],
		"amount_out": 1,
		"input": ["silica"],
		"builtin": true,
	},
	"cg": {
		"level": 6,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["packed_gas", "copper"],
		"builtin": true,
	},
	"sw": {
		"level": 6,
		"time": 1.0,
		"amount_in": [1, 1, 1],
		"amount_out": 1,
		"input": ["iron", "cg", "glass"],
		"builtin": true,
	},
}

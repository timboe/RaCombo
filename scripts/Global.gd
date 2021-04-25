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
var lanes : int = 4
var factories_pull_from_above : bool = true

# Helper functions
func lighten(var c : Color) -> Color:
	return Color.from_hsv(c.h, 
		c.s - (c.s * 0.75),  # Lighten
		c.v)

# Game data
var data = {
	"none": {
		"color": Color(0.05, 0.05, 0.05),
		"mode": "extract",
		"shape": "circle",
		"builtin": true,
		"special": true,
	},
	"sol": {
		"color": Color(0.05, 0.05, 0.05),
		"mode": "extract",
		"shape": "triangle",
		"builtin": true,
		"special": true,
	},
	"H": {
		"color": Color(0.71, 0.4, 0.46),
		"mode": "extract",
		"shape": "diamond",
		"builtin": true,
		"special": false,
	},
	"Ir": {
		"color": Color(0.0, 0.0, 1.0),
		"mode": "insert",
		"shape": "trapezoid",
		"builtin": true,
		"special": false,
	},
	"Cu": {
		"color": Color(1.0, 1.0, 0.0),
		"mode": "insert",
		"shape": "circle",
		"builtin": true,
		"special": false,
	},
	"St": {
		"color": Color(1.0, 0.5, 0.0),
		"mode": "insert",
		"shape": "triangle",
		"builtin": true,
		"special": false,
	},
	"Si": {
		"color": Color(0.97, 0.15, 0.52),
		"mode": "insert",
		"shape": "diamond",
		"builtin": true,
		"special": false,
	},
	"G": {
		"color": Color(0.6, 0.9, 0.6),
		"mode": "extract",
		"shape": "trapezoid",
		"builtin": true,
		"special": false,
	},
	"Hi": {
		"color": Color(0.75, 0.0, 0.0),
		"mode": "extract",
		"shape": "circle",
		"builtin": true,
		"special": false,
	},
	"Cf": {
		"color": Color(0.75, 0.0, 0.8),
		"mode": "insert",
		"shape": "triangle",
		"builtin": true,
		"special": false,
	},
	"T": {
		"color": Color(1.0, 1.0, 0.0),
		"mode": "extract",
		"shape": "diamond",
		"builtin": true,
		"special": false,
	},
	"Bg": {
		"color": Color(0.34, 0.04, 0.68),
		"mode": "extract",
		"shape": "trapezoid",
		"builtin": true,
		"special": false,
	},
	"Mt": {
		"color": Color(1.0, 0.5, 0.5),
		"mode": "extract",
		"shape": "circle",
		"builtin": true,
		"special": false,
	},
	"XA": {
		"color": Color(1.0, 0.5, 0.5),
		"mode": "insert",
		"shape": "triangle",
		"builtin": true,
		"special": false,
	},
	"XB": {
		"color": Color(0.5, 1.5, 0.5),
		"mode": "extract",
		"shape": "diamond",
		"builtin": true,
		"special": false,
	},
	"XC": {
		"color": Color(0.5, 0.5, 1.0),
		"mode": "extract",
		"shape": "trapezoid",
		"builtin": true,
		"special": false,
	},
	"CG": {
		"color": Color(0.4, 0.3, 0.7),
		"mode": "extract",
		"shape": "circle",
		"builtin": true,
		"special": false,
	},
	"SW": {
		"color": Color(0.2, 0.7, 0.4),
		"mode": "extract",
		"shape": "triangle",
		"builtin": true,
		"special": false,
	},
}

var recipies = {
	"St": {
		"level": 2,
		"time": 1.0,
		"amount_in": [1],
		"amount_out": 1,
		"input": ["Ir"],
		"builtin": true,
		"factory:": true,
	},
	"Hi": {
		"level": 2,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["H", "St"],
		"builtin": true,
		"factory:": true,
	},
	"Cf": {
		"level": 3,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["Ir", "Cu"],
		"builtin": true,
		"factory:": true,
	},
	"T": { 
		"level": 3,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["Cu", "sol"],
		"builtin": true,
		"factory:": false, # Note: Not a factory recipy
	},
	"Bg": {
		"level": 3,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["H", "T"],
		"builtin": true,
		"factory:": true,
	},
	"Mt": {
		"level": 4,
		"time": 1.0,
		"amount_in": [1, 1, 1],
		"amount_out": 1,
		"input": ["Cu", "St", "T"],
		"builtin": true,
	},
	"XA": {
		"level": 5,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["H", "Cf"],
		"builtin": true,
	},
	"XB": {
		"level": 5,
		"time": 1.0,
		"amount_in": [1],
		"amount_out": 1,
		"input": ["XA"],
		"builtin": true,
	},
	"XC": {
		"level": 5,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["XB", "Cu"],
		"builtin": true,
	},
	"G": {
		"level": 6,
		"time": 1.0,
		"amount_in": [1],
		"amount_out": 1,
		"input": ["Si"],
		"builtin": true,
		"factory:": true,
	},
	"CG": {
		"level": 6,
		"time": 1.0,
		"amount_in": [1, 1],
		"amount_out": 1,
		"input": ["Bg", "Cu"],
		"builtin": true,
		"factory:": true,
	},
	"SW": {
		"level": 6,
		"time": 1.0,
		"amount_in": [1, 1, 1],
		"amount_out": 1,
		"input": ["Ir", "CG", "G"],
		"builtin": true,
		"factory:": true,
	},
}

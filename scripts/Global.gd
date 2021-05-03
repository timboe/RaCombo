extends Node
tool

# Constants
const M_SOL := 80
const INSERTER_RADIUS_MOD = 0.2
const MAX_STORAGE := 49
const MAX_INPUT_LANES := 6

enum {BUILDING_UNSET, BUILDING_EXTRACTOR, BUILDING_INSERTER, BUILDING_FACTORY}
enum {OUTWARDS, INWARDS}

# Helper globals (transient)
var last_pressed = null

# Current level & configuration globals
var campaign = null
# Unpacked into vars...
var data = null
var recipies = null
var mission = null
var rings : int = 10
var lanes : int = 4
var factories_pull_from_above : bool = true

# Current game data
var sandbox = false
var sandbox_injectors = []
#
var level : int = 1
var remaining : int = 1000
var to_subtract : int = 0 # Used to animate remaining
var exported = {} # Statistics

# Helper functions
func lighten(var c : Color) -> Color:
	return Color.from_hsv(c.h, 
		c.s - (c.s * 0.75),  # Lighten
		c.v)

# Scene changing #####
var current_scene = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func populate_data():
	if data == null or recipies == null:
		recipies = campaign["recipies"]
		data = campaign["resources"]
		for r in data:
			data[r]["color"] = Color(data[r]["color_hex"])

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
# Scene changing #####

# Cache of all campaign data
var campaigns := {}

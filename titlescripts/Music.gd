extends AudioStreamPlayer


var tracks = []
var current : int
var R = RandomNumberGenerator.new()

func _ready():
	current = 0
	tracks.append(load("res://resources/ader-da-silva-rareness-of-existence-4314.ogg"))
	tracks.append(load("res://resources/ader-da-silva-phyllodia-1451.ogg"))
	tracks.append(load("res://resources/ader-da-silva-naval-proeminence-1450.ogg"))
	for t in tracks:
		t.loop = false
	stream = tracks[0]
	play()

func _on_Music_finished():
	var next = current
	while next == current:
		next = R.randi() % tracks.size()
	stream = tracks[next]
	current = next
	print("play ",current)
	play()

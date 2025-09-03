extends Node

enum TYPE {
	GEAR_CHANGE,
	HIT
}

func vibrate(type: TYPE):
	match type:
		TYPE.GEAR_CHANGE:
			Input.vibrate_handheld(30, 0.4)
			Input.vibrate_handheld(30, 0.4)
		TYPE.HIT:
			Input.vibrate_handheld(50, 0.7)

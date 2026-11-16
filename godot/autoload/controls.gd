extends Node
## Registers every game action in the Input Map at startup, so keyboard,
## controller and the on-screen buttons all drive the same names.
## Edit the tables below to rebind. (Project Settings > Input Map also works,
## but anything defined there is kept and these are added on top.)

const KEYS := {
	"move_forward": [KEY_W, KEY_UP],
	"move_back": [KEY_S, KEY_DOWN],
	"strafe_left": [KEY_A],
	"strafe_right": [KEY_D],
	"turn_left": [KEY_Q, KEY_LEFT],
	"turn_right": [KEY_E, KEY_RIGHT],
	"attack": [KEY_SPACE, KEY_ENTER],
	"cast": [KEY_F],
	"sneak": [KEY_C],
	"map": [KEY_M, KEY_TAB],
	"menu": [KEY_ESCAPE],
}

const PAD_BUTTONS := {
	"move_forward": [JOY_BUTTON_DPAD_UP],
	"move_back": [JOY_BUTTON_DPAD_DOWN],
	"strafe_left": [JOY_BUTTON_DPAD_LEFT],
	"strafe_right": [JOY_BUTTON_DPAD_RIGHT],
	"turn_left": [JOY_BUTTON_LEFT_SHOULDER],
	"turn_right": [JOY_BUTTON_RIGHT_SHOULDER],
	"attack": [JOY_BUTTON_A],
	"cast": [JOY_BUTTON_X],
	"sneak": [JOY_BUTTON_B],
	"map": [JOY_BUTTON_BACK],
	"menu": [JOY_BUTTON_START],
}

## Left stick: [axis, direction] per action.
const PAD_AXES := {
	"move_forward": [JOY_AXIS_LEFT_Y, -1.0],
	"move_back": [JOY_AXIS_LEFT_Y, 1.0],
	"strafe_left": [JOY_AXIS_LEFT_X, -1.0],
	"strafe_right": [JOY_AXIS_LEFT_X, 1.0],
	"turn_left": [JOY_AXIS_RIGHT_X, -1.0],
	"turn_right": [JOY_AXIS_RIGHT_X, 1.0],
}

## Order matters for the HUD and for polling held actions.
const ACTIONS := ["move_forward", "move_back", "strafe_left", "strafe_right",
	"turn_left", "turn_right", "attack", "cast", "sneak", "map", "menu"]


func _ready() -> void:
	for action: String in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.5)
		for key in KEYS.get(action, []):
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
		for button in PAD_BUTTONS.get(action, []):
			var jb := InputEventJoypadButton.new()
			jb.button_index = button
			InputMap.action_add_event(action, jb)
		if PAD_AXES.has(action):
			var jm := InputEventJoypadMotion.new()
			jm.axis = PAD_AXES[action][0]
			jm.axis_value = PAD_AXES[action][1]
			InputMap.action_add_event(action, jm)

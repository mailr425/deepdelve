extends Control
## Root of the game screen, portrait like the browser build:
##   top    the 3D dungeon, rendered at 160x120 and scaled 2x (chunky pixels)
##   middle message log + minimap
##   bottom touch buttons (the same actions as keyboard and controller)
##
## Everything is built in code so the scene file stays tiny and readable.
## As screens grow (camp, character sheet, item cards) move pieces into their
## own .tscn files.

const VIEW_W := 160
const VIEW_H := 120
const SCALE := 2
const PAD_H := 144   # three rows of 44 px buttons plus gaps
const LOG_COLORS := {"info": "c8c0b0", "good": "8ce07a", "bad": "e0584a", "gold": "ffd36a"}
## Held keys repeat for these, so holding W walks like Grimrock.
const REPEATABLE := ["move_forward", "move_back", "strafe_left", "strafe_right", "turn_left", "turn_right"]

var dungeon: Dungeon
var minimap: Minimap
var log_label: RichTextLabel
var status_label: Label
var _press_pos := Vector2.ZERO


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = _make_theme()
	# Save slot 0 for now; the slot picker screen comes with stage 3.
	if not Hero.load_slot(0):
		Hero.start_new(0)

	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.05, 0.07)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# --- 3D view: a low-res SubViewport shown through a TextureRect.
	var sv := SubViewport.new()
	sv.size = Vector2i(VIEW_W, VIEW_H)
	sv.own_world_3d = true
	sv.msaa_3d = Viewport.MSAA_DISABLED
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(sv)
	dungeon = Dungeon.new()
	dungeon.name = "Dungeon"
	sv.add_child(dungeon)

	var view := TextureRect.new()
	view.texture = sv.get_texture()
	view.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	view.stretch_mode = TextureRect.STRETCH_SCALE
	view.position = Vector2.ZERO
	view.size = Vector2(VIEW_W * SCALE, VIEW_H * SCALE)
	view.mouse_filter = Control.MOUSE_FILTER_STOP
	view.gui_input.connect(_on_view_input)
	add_child(view)

	# --- status line, log and minimap.
	var y := VIEW_H * SCALE
	status_label = Label.new()
	status_label.position = Vector2(4, y + 2)
	status_label.size = Vector2(312, 12)
	add_child(status_label)

	log_label = RichTextLabel.new()
	log_label.bbcode_enabled = true
	log_label.scroll_following = true
	# Stretches down to the buttons, so taller phones get a longer log.
	log_label.anchor_right = 0.0
	log_label.anchor_bottom = 1.0
	log_label.offset_left = 4
	log_label.offset_top = y + 16
	log_label.offset_right = 210
	log_label.offset_bottom = -PAD_H - 4
	add_child(log_label)

	minimap = Minimap.new()
	minimap.position = Vector2(216, y + 16)
	minimap.size = Vector2(100, 80)
	minimap.dungeon = dungeon
	add_child(minimap)

	# --- touch buttons.
	var pad := GridContainer.new()
	pad.columns = 3
	# Anchored to the bottom edge, where thumbs are.
	pad.anchor_top = 1.0
	pad.anchor_bottom = 1.0
	pad.offset_left = 4
	pad.offset_top = -PAD_H
	pad.add_theme_constant_override("h_separation", 4)
	pad.add_theme_constant_override("v_separation", 4)
	add_child(pad)
	for b: Array in [["TURN L", "turn_left"], ["FORWARD", "move_forward"], ["TURN R", "turn_right"],
			["LEFT", "strafe_left"], ["BACK", "move_back"], ["RIGHT", "strafe_right"],
			["ATTACK", "attack"], ["CAST", "cast"], ["SNEAK", "sneak"]]:
		pad.add_child(_make_button(b[0], b[1]))

	dungeon.message.connect(add_log)
	dungeon.moved.connect(_refresh)
	add_log("You descend into the dark. (Stage 1 test room)", "gold")
	add_log("Swipe or use WASD/QE, arrows, or a controller.", "info")
	_refresh()


func _make_button(text: String, action: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(101, 44)
	b.focus_mode = Control.FOCUS_NONE   # keeps Space/Enter from re-pressing it
	b.pressed.connect(func() -> void: dungeon.do_action(action))
	return b


func _unhandled_input(event: InputEvent) -> void:
	for action: String in Controls.ACTIONS:
		if event.is_action_pressed(action, action in REPEATABLE):
			dungeon.do_action(action)
			get_viewport().set_input_as_handled()
			return


## Swipes on the dungeon view. Touch arrives as emulated mouse events.
## Swipe left turns left (the designer's choice in the browser build).
func _on_view_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb == null or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if mb.pressed:
		_press_pos = mb.position
		return
	var d := mb.position - _press_pos
	if d.length() < 24.0:
		dungeon.do_action("attack")   # tap the view to attack what is in front
	elif absf(d.x) > absf(d.y):
		dungeon.do_action("turn_left" if d.x < 0 else "turn_right")
	else:
		dungeon.do_action("move_forward" if d.y < 0 else "move_back")


func add_log(text: String, kind: String = "info") -> void:
	log_label.append_text("[color=#%s]%s[/color]\n" % [LOG_COLORS.get(kind, "c8c0b0"), text])


func _refresh() -> void:
	status_label.text = "HP %d/%d   FLOOR 1   %s" % [
		Hero.h.get("hp", int(Data.BAL.get("hp0", 26))),
		Hero.h.get("mhp", int(Data.BAL.get("hp0", 26))),
		["NORTH", "EAST", "SOUTH", "WEST"][dungeon.dir]]
	minimap.queue_redraw()


func _make_theme() -> Theme:
	var t := Theme.new()
	var font: FontFile = load("res://assets/fonts/delve.ttf")
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.hinting = TextServer.HINTING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	t.default_font = font
	t.default_font_size = 10   # the Delve font is 10 px to the em: 1 font pixel = 1 screen pixel
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.16, 0.13, 0.11)
	normal.border_color = Color(0.42, 0.34, 0.24)
	normal.set_border_width_all(1)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.30, 0.22, 0.14)
	t.set_stylebox("normal", "Button", normal)
	t.set_stylebox("hover", "Button", normal)
	t.set_stylebox("pressed", "Button", pressed)
	t.set_color("font_color", "Button", Color(0.9, 0.84, 0.7))
	t.set_color("font_color", "Label", Color(0.9, 0.84, 0.7))
	return t

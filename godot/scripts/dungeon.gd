class_name Dungeon
extends Node3D
## Stage 1 of the porting plan: a walkable grid in real 3D.
##
## The map is a list of strings, like the JS `G.map` drawn as text:
##   #  wall          D  closed door (bump to open)
##   .  floor         S  stairs down (blocks for now)
##   r k g o  a monster standing on floor (rat, skeleton, goblin, orc)
##   @  player start, facing north
##
## Geometry is one ArrayMesh built with SurfaceTool: only the faces you can
## see (floor, ceiling and wall faces next to open tiles), grouped into one
## surface per texture. That is cheaper than one MeshInstance per tile and
## needs no GridMap MeshLibrary, so floors from the generator (stage 2) can
## be dropped straight into build().
##
## Facing uses the JS codes: 0=N 1=E 2=S 3=W, DX/DY from Data.
## World axes: map x -> +X, map y -> +Z, so north is -Z.

signal message(text: String, kind: String)
signal moved

const WALL_H := 1.1          # JS: CEILY - FLOORY = 1.12
const EYE := 0.5             # eye height above the floor
const CAM_BACK := 0.3        # JS: BACK = .32, camera sits behind tile center
const STEP_TIME := 0.16
const TURN_TIME := 0.14

const TEST_MAP := [
	"#################",
	"#.......#.......#",
	"#.#####.#.#####.#",
	"#.#...#...#...#.#",
	"#.#.r.D...D.k.#.#",
	"#.#...#...#...#.#",
	"#.###.##.##.###.#",
	"#.......@.......#",
	"#.###.#####.###.#",
	"#...#...g...#...#",
	"###.#.#####.#.###",
	"#.....#.S.#.....#",
	"#################",
]

const MONSTER_CHARS := {"r": "rat", "k": "skeleton", "g": "goblin", "o": "orc"}

var rows: Array[String] = []
var pos := Vector2i.ZERO
var dir := 0
var busy := false
var queued := ""

var _pivot: Node3D
var _camera: Camera3D
var _mesh: MeshInstance3D
var _materials: Dictionary = {}
var _monsters: Dictionary = {}   # Vector2i -> Sprite3D
var _anim_t := 0.0


func _ready() -> void:
	_setup_environment()
	_pivot = Node3D.new()
	_pivot.name = "PlayerPivot"
	add_child(_pivot)
	_camera = Camera3D.new()
	_camera.fov = 66.0
	_camera.near = 0.05
	_camera.position = Vector3(0, 0, CAM_BACK)
	_pivot.add_child(_camera)
	_camera.current = true
	var torch := OmniLight3D.new()
	torch.light_color = Color(1.0, 0.82, 0.58)
	torch.light_energy = 1.7
	torch.omni_range = 5.5
	torch.omni_attenuation = 1.4
	torch.position = Vector3(0.15, 0.05, 0)
	_camera.add_child(torch)
	_mesh = MeshInstance3D.new()
	_mesh.name = "Level"
	add_child(_mesh)
	build(TEST_MAP)


# ---------------------------------------------------------------- building

func build(map_rows: Array) -> void:
	rows.clear()
	for r: String in map_rows:
		rows.append(r)
	for m: Node in _monsters.values():
		m.queue_free()
	_monsters.clear()
	for y in rows.size():
		for x in rows[y].length():
			var c := rows[y][x]
			if c == "@":
				pos = Vector2i(x, y)
				dir = 0
				_set_tile(pos, ".")
			elif MONSTER_CHARS.has(c):
				_spawn_monster(Vector2i(x, y), MONSTER_CHARS[c])
				_set_tile(Vector2i(x, y), ".")
	_rebuild_mesh()
	_snap_camera()
	moved.emit()


func _rebuild_mesh() -> void:
	var tools: Dictionary = {}   # texture key -> SurfaceTool
	for y in rows.size():
		for x in rows[y].length():
			if not is_open(Vector2i(x, y)):
				continue
			var fx := float(x)
			var fz := float(y)
			_quad(_tool(tools, "floor"),
				[Vector3(fx, 0, fz), Vector3(fx + 1, 0, fz), Vector3(fx + 1, 0, fz + 1), Vector3(fx, 0, fz + 1)],
				Vector3.UP)
			_quad(_tool(tools, "ceil"),
				[Vector3(fx, WALL_H, fz), Vector3(fx + 1, WALL_H, fz), Vector3(fx + 1, WALL_H, fz + 1), Vector3(fx, WALL_H, fz + 1)],
				Vector3.DOWN)
			for d in 4:
				var n := Vector2i(x + Data.DX[d], y + Data.DY[d])
				if is_open(n):
					continue
				_wall_face(_tool(tools, _face_texture(n)), Vector2i(x, y), d)
	var mesh := ArrayMesh.new()
	for key: String in tools.keys():
		var st: SurfaceTool = tools[key]
		st.commit(mesh)
		mesh.surface_set_material(mesh.get_surface_count() - 1, _material(key))
	_mesh.mesh = mesh


func _tool(tools: Dictionary, key: String) -> SurfaceTool:
	if not tools.has(key):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		tools[key] = st
	return tools[key]


## Wall face on side `d` of open tile `t`, facing into the tile, with u running
## left to right as seen by someone standing in the tile looking toward `d`.
func _wall_face(st: SurfaceTool, t: Vector2i, d: int) -> void:
	var fwd := Vector3(Data.DX[d], 0, Data.DY[d])
	var r := (d + 1) % 4
	var right := Vector3(Data.DX[r], 0, Data.DY[r])
	var center := Vector3(t.x + 0.5, 0, t.y + 0.5) + fwd * 0.5
	var left_pt := center - right * 0.5
	var right_pt := center + right * 0.5
	var up := Vector3(0, WALL_H, 0)
	# order: top-left, top-right, bottom-right, bottom-left (UVs match)
	_quad(st, [left_pt + up, right_pt + up, right_pt, left_pt], -fwd,
		[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])


func _quad(st: SurfaceTool, v: Array, normal: Vector3,
		uv: Array = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]) -> void:
	for i: int in [0, 1, 2, 0, 2, 3]:
		st.set_normal(normal)
		st.set_uv(uv[i])
		st.add_vertex(v[i])


func _face_texture(t: Vector2i) -> String:
	match tile(t):
		"D":
			return "door"
		"S":
			return "stairs"
	# Mostly plain brick, with the occasional moss or crack, stable per tile.
	var h := absi(hash(t)) % 100
	if h < 70:
		return "wall_%d" % (h % 3)
	return "wall_%d" % (3 + h % 3)


func _material(key: String) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key]
	var m := StandardMaterial3D.new()
	m.albedo_texture = load("res://assets/art/env/%s.png" % key)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.roughness = 1.0
	m.metallic_specular = 0.0
	_materials[key] = m
	return m


func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color.BLACK
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.09, 0.08, 0.1)
	env.fog_enabled = true
	env.fog_light_color = Color.BLACK
	env.fog_density = 0.22
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)


func _spawn_monster(t: Vector2i, key: String) -> void:
	var info := Data.monster_by_sprite(key)
	var size: float = info.get("sz", 0.7)
	var s := Sprite3D.new()
	s.texture = load("res://assets/art/monsters/%s_idle1.png" % key)
	s.set_meta("frames", [s.texture, load("res://assets/art/monsters/%s_idle2.png" % key)])
	s.pixel_size = size / 24.0
	s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	s.shaded = true
	var lift := 0.1 if info.get("float", 0) else 0.0
	s.position = Vector3(t.x + 0.5, size * 0.5 + lift, t.y + 0.5)
	s.name = "%s_%d_%d" % [key, t.x, t.y]
	add_child(s)
	_monsters[t] = s


func _process(delta: float) -> void:
	# Two-frame idle, like the browser build's breathing animation.
	_anim_t += delta
	var f := int(_anim_t * 2.0) % 2
	for s: Sprite3D in _monsters.values():
		s.texture = s.get_meta("frames")[f]


# ---------------------------------------------------------------- queries

func tile(t: Vector2i) -> String:
	if t.y < 0 or t.y >= rows.size() or t.x < 0 or t.x >= rows[t.y].length():
		return "#"
	return rows[t.y][t.x]


func is_open(t: Vector2i) -> bool:
	return tile(t) == "."


func _set_tile(t: Vector2i, c: String) -> void:
	var r := rows[t.y]
	rows[t.y] = r.substr(0, t.x) + c + r.substr(t.x + 1)


func monster_at(t: Vector2i) -> Sprite3D:
	return _monsters.get(t)


# ---------------------------------------------------------------- actions

## Single entry point for keyboard, controller, swipes and on-screen buttons.
func do_action(action: String) -> void:
	if busy:
		queued = action   # remember one press so fast tapping feels responsive
		return
	match action:
		"move_forward":
			_step(dir)
		"move_back":
			_step((dir + 2) % 4)
		"strafe_left":
			_step((dir + 3) % 4)
		"strafe_right":
			_step((dir + 1) % 4)
		"turn_left":
			_turn(-1)
		"turn_right":
			_turn(1)
		"attack":
			_attack()
		_:
			message.emit("%s: not ported yet." % action.capitalize(), "info")


func _step(d: int) -> void:
	var target := pos + Vector2i(Data.DX[d], Data.DY[d])
	var t := tile(target)
	if t == "D":
		_set_tile(target, ".")
		_rebuild_mesh()
		message.emit("The door creaks open.", "info")
		moved.emit()
		return
	if monster_at(target):
		message.emit("A %s blocks the way." % monster_at(target).name.get_slice("_", 0), "bad")
		_bump(d)
		return
	if t == "S":
		message.emit("Stairs down. Floors arrive in stage 2.", "gold")
		_bump(d)
		return
	if not is_open(target):
		_bump(d)
		return
	pos = target
	busy = true
	var tw := create_tween()
	tw.tween_property(_pivot, "position", _tile_center(pos), STEP_TIME) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.finished.connect(_done)
	moved.emit()


func _turn(sign_dir: int) -> void:
	dir = (dir + sign_dir + 4) % 4
	busy = true
	var tw := create_tween()
	tw.tween_property(_pivot, "rotation:y", _pivot.rotation.y - sign_dir * PI / 2.0, TURN_TIME) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.finished.connect(_done)
	moved.emit()


func _bump(d: int) -> void:
	busy = true
	var home := _tile_center(pos)
	var nudge := home + Vector3(Data.DX[d], 0, Data.DY[d]) * 0.08
	var tw := create_tween()
	tw.tween_property(_pivot, "position", nudge, 0.06)
	tw.tween_property(_pivot, "position", home, 0.08)
	tw.finished.connect(_done)


func _attack() -> void:
	var target := pos + Vector2i(Data.DX[dir], Data.DY[dir])
	var m := monster_at(target)
	if m == null:
		message.emit("You swing at the air.", "info")
		return
	# Placeholder until stage 4 ports attack()/strike(): one hit kills.
	message.emit("You strike the %s down." % m.name.get_slice("_", 0), "good")
	_monsters.erase(target)
	var tw := create_tween()
	tw.tween_property(m, "modulate", Color(1, 0.2, 0.2, 0), 0.35)
	tw.tween_callback(m.queue_free)


func _done() -> void:
	busy = false
	# Keep the yaw tidy so it never drifts after many turns.
	_pivot.rotation.y = -dir * PI / 2.0
	if queued != "":
		var a := queued
		queued = ""
		do_action(a)


func _tile_center(t: Vector2i) -> Vector3:
	return Vector3(t.x + 0.5, EYE, t.y + 0.5)


func _snap_camera() -> void:
	_pivot.position = _tile_center(pos)
	_pivot.rotation.y = -dir * PI / 2.0

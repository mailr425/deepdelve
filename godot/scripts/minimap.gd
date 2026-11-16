class_name Minimap
extends Control
## Small top-down map centered on the player, with a facing arrow.
## Stage 1 shows the whole test map; the browser build only shows explored
## tiles, which comes back with the generator in stage 2.

const CELL := 6
const COL_BG := Color(0.04, 0.03, 0.05)
const COL_FLOOR := Color(0.32, 0.29, 0.26)
const COL_WALL := Color(0.10, 0.09, 0.11)
const COL_DOOR := Color(0.55, 0.36, 0.18)
const COL_STAIRS := Color(0.85, 0.75, 0.35)
const COL_MON := Color(0.88, 0.25, 0.22)
const COL_HERO := Color(1.0, 0.85, 0.42)

var dungeon: Dungeon


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COL_BG)
	if dungeon == null:
		return
	var half := Vector2i(int(size.x / CELL / 2), int(size.y / CELL / 2))
	var origin := size / 2.0 - Vector2(CELL, CELL) / 2.0
	for dy in range(-half.y - 1, half.y + 2):
		for dx in range(-half.x - 1, half.x + 2):
			var t := dungeon.pos + Vector2i(dx, dy)
			var c := COL_WALL
			match dungeon.tile(t):
				".":
					c = COL_FLOOR
				"D":
					c = COL_DOOR
				"S":
					c = COL_STAIRS
			var p := origin + Vector2(dx * CELL, dy * CELL)
			draw_rect(Rect2(p, Vector2(CELL, CELL)), c)
			if dungeon.monster_at(t):
				draw_rect(Rect2(p + Vector2(2, 2), Vector2(2, 2)), COL_MON)
	# Facing arrow, pointing the way the hero looks.
	var center := size / 2.0
	var f := Vector2(Data.DX[dungeon.dir], Data.DY[dungeon.dir])
	var side := Vector2(-f.y, f.x)
	var tip := center + f * 4.0
	var back := center - f * 3.0
	draw_colored_polygon(PackedVector2Array([tip, back + side * 3.0, back - side * 3.0]), COL_HERO)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.35, 0.3, 0.25), false, 1.0)

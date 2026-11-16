extends Node
## All game tables, exported unchanged from ../index.html (the browser game) (v16).
## Regenerate with tools/export_from_html.py after changing the browser build.
##
## Access: Data.BAL["mhp"], Data.table("MONS")[0]["n"], Data.affix_value(...)
## Note: JSON has one number type, so every number arrives as a float.
## Use int() where the JS code relied on integers (tiers, counts, indices).

const PATH := "res://data/game_data.json"

var tables: Dictionary = {}
var BAL: Dictionary = {}
var CONST: Dictionary = {}
var DX: Array[int] = [0, 1, 0, -1]   # facing 0..3 = N, E, S, W (same as the JS)
var DY: Array[int] = [-1, 0, 1, 0]

var _expr_cache: Dictionary = {}


func _ready() -> void:
	var res: JSON = load(PATH)
	if res == null or typeof(res.data) != TYPE_DICTIONARY:
		push_error("Could not load %s" % PATH)
		return
	tables = res.data
	BAL = tables.get("BAL", {})
	CONST = tables.get("CONST", {})
	print("Data: loaded %d tables (%s)" % [tables.size(), ", ".join(tables.keys())])


func table(table_name: String) -> Variant:
	return tables.get(table_name)


## AFFIX values were JS arrow functions of the tier `t`; they are stored as
## expression strings such as "2+floor(t*0.8)" and evaluated here.
func affix_value(expr_text: String, tier: int) -> float:
	var e: Expression = _expr_cache.get(expr_text)
	if e == null:
		e = Expression.new()
		if e.parse(expr_text, ["t"]) != OK:
			push_error("Bad affix expression: %s" % expr_text)
			return 0.0
		_expr_cache[expr_text] = e
	return float(e.execute([tier]))


func skill_need(level: int) -> int:
	# JS: skNeed = l => Math.round(4 + l * .8)
	return roundi(4 + level * 0.8)


func monster_by_sprite(sprite_key: String) -> Dictionary:
	for m: Dictionary in tables.get("MONS", []):
		if m.get("s") == sprite_key:
			return m
	return {}

extends Node2D

const VIEW_CENTER := Vector2(640.0, 360.0)
const ROOM_WIDTH := 2400.0
const WALL_TOP := 88.0
const WALL_BOTTOM := 632.0
const PANEL_WIDTH := 120.0

var view_x := ROOM_WIDTH * 0.5

func set_view_x(value: float) -> void:
	view_x = value
	queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	_draw_room()

func _draw_room() -> void:
	var left := _screen_x(0.0)
	var right := _screen_x(ROOM_WIDTH)
	var visible_left := maxf(left, 0.0)
	var visible_right := minf(right, 1280.0)

	if visible_right <= visible_left:
		return

	draw_rect(
		Rect2(visible_left, WALL_TOP, visible_right - visible_left, WALL_BOTTOM - WALL_TOP),
		Color(0.93, 0.94, 0.96, 1.0)
	)

	var first_panel := int(floor(maxf(0.0, view_x - VIEW_CENTER.x) / PANEL_WIDTH))
	var last_panel := int(ceil(minf(ROOM_WIDTH, view_x + VIEW_CENTER.x) / PANEL_WIDTH))
	for panel in range(first_panel, last_panel + 1):
		_draw_panel(float(panel) * PANEL_WIDTH, panel)

	_draw_room_edge(left, "INICIO")
	_draw_room_edge(right, "FIN")
	draw_line(Vector2(visible_left, WALL_TOP), Vector2(visible_right, WALL_TOP), Color(0.72, 0.76, 0.84, 1.0), 2.0)
	draw_line(Vector2(visible_left, WALL_BOTTOM), Vector2(visible_right, WALL_BOTTOM), Color(0.72, 0.76, 0.84, 1.0), 2.0)

func _draw_panel(world_x: float, index: int) -> void:
	var x := _screen_x(world_x)
	if x > 1280.0 or x + PANEL_WIDTH < 0.0:
		return

	var shade := 0.82 + float(index % 4) * 0.025
	var color := Color(shade, shade + 0.01, shade + 0.035, 1.0)
	var top_y := WALL_TOP
	var bottom_y := WALL_BOTTOM

	var points := PackedVector2Array([
		Vector2(x, top_y),
		Vector2(x + PANEL_WIDTH, top_y),
		Vector2(x + PANEL_WIDTH, bottom_y),
		Vector2(x, bottom_y),
	])
	draw_colored_polygon(points, color)
	draw_polyline(points + PackedVector2Array([points[0]]), Color(0.63, 0.67, 0.75, 1.0), 1.0)

func _draw_room_edge(x: float, label: String) -> void:
	if x < -20.0 or x > 1300.0:
		return

	draw_line(Vector2(x, WALL_TOP), Vector2(x, WALL_BOTTOM), Color(0.32, 0.36, 0.44, 1.0), 4.0)
	draw_string(ThemeDB.fallback_font, Vector2(x + 12.0, WALL_TOP + 34.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, Color(0.32, 0.36, 0.44, 1.0))

func _screen_x(world_x: float) -> float:
	return world_x - view_x + VIEW_CENTER.x

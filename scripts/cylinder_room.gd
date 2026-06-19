extends Node2D

const ROOM_WIDTH := 2400.0
const PANEL_WIDTH := 120.0

var view_x := ROOM_WIDTH * 0.5
var viewport_size := Vector2(1280.0, 720.0)

func set_view_x(value: float) -> void:
	view_x = value
	queue_redraw()

func set_viewport_size(value: Vector2) -> void:
	viewport_size = value
	queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	_draw_room()

func _draw_room() -> void:
	var left := _screen_x(0.0)
	var right := _screen_x(ROOM_WIDTH)
	var visible_left := maxf(left, 0.0)
	var visible_right := minf(right, viewport_size.x)
	var wall_top := viewport_size.y * 0.12
	var wall_bottom := viewport_size.y * 0.88

	if visible_right <= visible_left:
		return

	draw_rect(
		Rect2(visible_left, wall_top, visible_right - visible_left, wall_bottom - wall_top),
		Color(0.93, 0.94, 0.96, 1.0)
	)

	var half_width := viewport_size.x * 0.5
	var first_panel := int(floor(maxf(0.0, view_x - half_width) / PANEL_WIDTH))
	var last_panel := int(ceil(minf(ROOM_WIDTH, view_x + half_width) / PANEL_WIDTH))
	for panel in range(first_panel, last_panel + 1):
		_draw_panel(float(panel) * PANEL_WIDTH, panel, wall_top, wall_bottom)

	_draw_room_edge(left, "INICIO", wall_top, wall_bottom)
	_draw_room_edge(right, "FIN", wall_top, wall_bottom)
	draw_line(Vector2(visible_left, wall_top), Vector2(visible_right, wall_top), Color(0.72, 0.76, 0.84, 1.0), 2.0)
	draw_line(Vector2(visible_left, wall_bottom), Vector2(visible_right, wall_bottom), Color(0.72, 0.76, 0.84, 1.0), 2.0)

func _draw_panel(world_x: float, index: int, wall_top: float, wall_bottom: float) -> void:
	var x := _screen_x(world_x)
	if x > viewport_size.x or x + PANEL_WIDTH < 0.0:
		return

	var shade := 0.82 + float(index % 4) * 0.025
	var color := Color(shade, shade + 0.01, shade + 0.035, 1.0)
	var top_y := wall_top
	var bottom_y := wall_bottom

	var points := PackedVector2Array([
		Vector2(x, top_y),
		Vector2(x + PANEL_WIDTH, top_y),
		Vector2(x + PANEL_WIDTH, bottom_y),
		Vector2(x, bottom_y),
	])
	draw_colored_polygon(points, color)
	draw_polyline(points + PackedVector2Array([points[0]]), Color(0.63, 0.67, 0.75, 1.0), 1.0)

func _draw_room_edge(x: float, label: String, wall_top: float, wall_bottom: float) -> void:
	if x < -20.0 or x > viewport_size.x + 20.0:
		return

	draw_line(Vector2(x, wall_top), Vector2(x, wall_bottom), Color(0.32, 0.36, 0.44, 1.0), 4.0)
	draw_string(ThemeDB.fallback_font, Vector2(x + 12.0, wall_top + 34.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, Color(0.32, 0.36, 0.44, 1.0))

func _screen_x(world_x: float) -> float:
	return world_x - view_x + viewport_size.x * 0.5

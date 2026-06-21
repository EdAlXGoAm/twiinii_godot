extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var room: Node2D = $World/CylinderRoom
@onready var twiinii_ball: Node2D = $World/TwiiniiBall
@onready var sky: ColorRect = $Sky
@onready var left_button: Button = $Controls/LeftButton
@onready var right_button: Button = $Controls/RightButton

const ROOM_WIDTH := 2400.0
const PAN_SPEED := 1.0

var view_x := ROOM_WIDTH * 0.5
var drag_active := false
var viewport_size := Vector2(1280.0, 720.0)
var external_move_callback = null

func _ready() -> void:
	camera.zoom = Vector2.ONE
	left_button.pressed.connect(twiinii_ball.move_left)
	right_button.pressed.connect(twiinii_ball.move_right)
	if OS.has_feature("web"):
		left_button.visible = false
		right_button.visible = false
	get_viewport().size_changed.connect(_handle_viewport_size_changed)
	_install_web_move_bridge()
	_handle_viewport_size_changed()
	_apply_view_position()

func _install_web_move_bridge() -> void:
	if not OS.has_feature("web"):
		return

	external_move_callback = JavaScriptBridge.create_callback(_handle_external_move)
	var window := JavaScriptBridge.get_interface("window")
	window.twiiniiWorldMove = external_move_callback
	JavaScriptBridge.eval(
		"window.addEventListener('message', function(event) {" +
		"var data = event.data;" +
		"if (!data || data.type !== 'twiinii-world-move') return;" +
		"if (typeof window.twiiniiWorldMove === 'function') window.twiiniiWorldMove(String(data.direction));" +
		"});",
		true
	)

func _handle_external_move(args: Array) -> void:
	if args.is_empty():
		return

	var direction := str(args[0])
	if direction == "left":
		twiinii_ball.move_left()
	elif direction == "right":
		twiinii_ball.move_right()

func _process(delta: float) -> void:
	var input_axis := Input.get_axis("ui_left", "ui_right")
	if not is_zero_approx(input_axis):
		_move_view(input_axis * 520.0 * delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		drag_active = event.pressed
	elif event is InputEventMouseMotion and drag_active:
		_move_view(-event.relative.x * PAN_SPEED)
	elif event is InputEventScreenTouch:
		drag_active = event.pressed
	elif event is InputEventScreenDrag:
		_move_view(-event.relative.x * PAN_SPEED)

func _move_view(delta_x: float) -> void:
	var half_width := viewport_size.x * 0.5
	view_x = clampf(delta_x + view_x, half_width, ROOM_WIDTH - half_width)
	_apply_view_position()

func _apply_view_position() -> void:
	room.set_viewport_size(viewport_size)
	room.set_view_x(view_x)
	twiinii_ball.set_viewport_size(viewport_size)
	twiinii_ball.set_view_x(view_x)

func _handle_viewport_size_changed() -> void:
	viewport_size = Vector2(get_viewport_rect().size)
	camera.position = viewport_size * 0.5
	sky.size = viewport_size
	_layout_controls()
	_move_view(0.0)

func _layout_controls() -> void:
	var is_portrait := viewport_size.y > viewport_size.x
	var button_size := 108.0 if is_portrait else 84.0
	var margin := 22.0
	var bottom := viewport_size.y - margin
	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color(0.08, 0.1, 0.16, 0.92)
	button_style.border_color = Color(0.0, 0.74, 0.83, 1.0)
	button_style.set_border_width_all(2)
	button_style.set_corner_radius_all(18)

	for button in [left_button, right_button]:
		button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_stylebox_override("normal", button_style)
		button.add_theme_stylebox_override("hover", button_style)
		button.add_theme_stylebox_override("pressed", button_style)
		button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
		button.add_theme_font_size_override("font_size", 42 if is_portrait else 34)

	left_button.position = Vector2(margin, bottom - button_size)
	left_button.size = Vector2(button_size, button_size)
	right_button.position = Vector2(viewport_size.x - margin - button_size, bottom - button_size)
	right_button.size = Vector2(button_size, button_size)

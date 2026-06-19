extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var room: Node2D = $World/CylinderRoom
@onready var twiinii_ball: Node2D = $World/TwiiniiBall
@onready var left_button: Button = $Controls/LeftButton
@onready var right_button: Button = $Controls/RightButton

const VIEW_CENTER := Vector2(640.0, 360.0)
const ROOM_WIDTH := 2400.0
const PAN_SPEED := 1.0

var view_x := ROOM_WIDTH * 0.5
var drag_active := false

func _ready() -> void:
	camera.position = VIEW_CENTER
	camera.zoom = Vector2.ONE
	left_button.pressed.connect(twiinii_ball.move_left)
	right_button.pressed.connect(twiinii_ball.move_right)
	_apply_view_position()

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
	view_x = clampf(delta_x + view_x, VIEW_CENTER.x, ROOM_WIDTH - VIEW_CENTER.x)
	_apply_view_position()

func _apply_view_position() -> void:
	room.set_view_x(view_x)
	twiinii_ball.set_view_x(view_x)

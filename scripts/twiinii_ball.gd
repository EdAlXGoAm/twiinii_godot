extends Node2D

const MODEL_PATHS := [
	"res://assets/models/twiinii/blue_ball_twiinii_model.glb",
	"res://assets/models/twiinii/twiinii.glb",
	"res://assets/models/twiinii/twiinii.gltf",
	"res://assets/models/twiinii/model.glb",
]

const VIEW_CENTER := Vector2(640.0, 360.0)
const ROOM_WIDTH := 2400.0
const TWIINII_WORLD_X := 1220.0
const MOVE_STEP := 190.0
const MIN_WORLD_X := 160.0
const MAX_WORLD_X := ROOM_WIDTH - 160.0
const BASE_Y := 360.0

var view_x := ROOM_WIDTH * 0.5
var world_x := TWIINII_WORLD_X
var target_world_x := TWIINII_WORLD_X
var velocity_x := 0.0
var float_time := 0.0

@onready var model_slot: Node2D = $ModelSlot
@onready var placeholder_ball: Node2D = $PlaceholderBall
var model_root: Node3D

func _ready() -> void:
	_try_load_model()
	_update_placement()

func set_view_x(value: float) -> void:
	view_x = value
	_update_placement()

func move_left() -> void:
	_set_target_world_x(target_world_x - MOVE_STEP)

func move_right() -> void:
	_set_target_world_x(target_world_x + MOVE_STEP)

func _set_target_world_x(value: float) -> void:
	target_world_x = clampf(value, MIN_WORLD_X, MAX_WORLD_X)

func _try_load_model() -> void:
	for path in MODEL_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var packed_scene: PackedScene = load(path)
		if packed_scene == null:
			continue
		_mount_model_preview(packed_scene.instantiate())
		placeholder_ball.visible = false
		return

func _mount_model_preview(model: Node) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 256)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)

	var root_3d := Node3D.new()
	model_root = root_3d
	viewport.add_child(root_3d)

	if model is Node3D:
		root_3d.add_child(model)
		_make_model_unlit(model)
		model.position = Vector3(0.0, -0.2, 0.0)
		model.rotation_degrees = Vector3(0.0, 270.0, 0.0)
		model.scale = Vector3.ONE * 1.35

	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 0.25, 3.2)
	camera.look_at(Vector3(0.0, 0.0, 0.0), Vector3.UP)
	camera.current = true
	viewport.add_child(camera)

	var preview := Sprite2D.new()
	preview.texture = viewport.get_texture()
	preview.scale = Vector2.ONE * 0.85
	model_slot.add_child(preview)

func _make_model_unlit(node: Node) -> void:
	if node is MeshInstance3D:
		_apply_unlit_materials(node)

	for child in node.get_children():
		_make_model_unlit(child)

func _apply_unlit_materials(mesh_instance: MeshInstance3D) -> void:
	if mesh_instance.mesh == null:
		return

	for surface_index in range(mesh_instance.mesh.get_surface_count()):
		var material := mesh_instance.get_active_material(surface_index)
		if material is BaseMaterial3D:
			var unlit_material := material.duplicate()
			unlit_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			unlit_material.metallic = 0.0
			unlit_material.roughness = 1.0
			mesh_instance.set_surface_override_material(surface_index, unlit_material)

func _update_placement() -> void:
	position = Vector2(
		world_x - view_x + VIEW_CENTER.x,
		BASE_Y + sin(float_time * 2.4) * 9.0 - minf(absf(velocity_x) * 0.018, 18.0)
	)
	scale = Vector2.ONE * (1.0 + sin(float_time * 2.4) * 0.035)
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	z_index = 100

func _process(delta: float) -> void:
	float_time += delta
	var spring_force := (target_world_x - world_x) * 16.0
	velocity_x += spring_force * delta
	velocity_x *= pow(0.84, delta * 60.0)
	world_x += velocity_x * delta
	_update_model_turn(delta)
	_update_placement()

func _update_model_turn(delta: float) -> void:
	if model_root == null:
		return

	var turn_strength := clampf(velocity_x / 520.0, -1.0, 1.0)
	var target_y := deg_to_rad(turn_strength * 80.0)
	model_root.rotation.y = lerp_angle(model_root.rotation.y, target_y, minf(1.0, delta * 8.0))

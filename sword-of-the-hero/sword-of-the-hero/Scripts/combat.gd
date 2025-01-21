extends Node3D

@onready var sword = $Sword
@onready var enemy = $Enemy
@onready var camera = $Camera3D

const SPHERE_RADIUS = 3.0

var sword_position = Vector3.ZERO  # Keeps track of the sword's current position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var window_size = DisplayServer.window_get_size()
	Input.warp_mouse(Vector2(window_size.x / 2, window_size.y / 2))
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	
	# Convert the screen position to 3D space
	var camera = get_viewport().get_camera_3d()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_direction = camera.project_ray_normal(mouse_position)
	
	var target_position = ray_origin + ray_direction * SPHERE_RADIUS
	var camera_position = camera.global_transform.origin
	var direction = (target_position - camera_position).normalized()
	var clamped_position = camera_position + direction * SPHERE_RADIUS
	
	sword.global_transform.origin = clamped_position
	
	# Calculate the sword's orientation
	var up_vector = (clamped_position - camera_position).normalized()  # Points outward from the camera to the sword
	var tangent_vector = Vector3.UP.cross(up_vector).normalized()  # Tangential to the sphere
	if tangent_vector.length() < 0.01:
		tangent_vector = Vector3(1, 0, 0)  # Fallback to avoid degenerate cross product
	var blade_direction = tangent_vector.cross(up_vector).normalized()  # Points along the sword's blade
	
	# Create the new transform basis for the sword
	var sword_basis = Basis(blade_direction, up_vector, tangent_vector).orthonormalized()
	sword.global_transform.basis = sword_basis
	

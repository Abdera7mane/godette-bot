class_name EngineWrapper

var editor_hint: bool          setget __set, is_editor_hint
var print_error_messages: bool setget __set, is_printing_error_messages
var iterations_per_second: int setget __set, get_iterations_per_second
var target_fps: int            setget __set, get_target_fps
var time_scale: float          setget __set, get_time_scale
var physics_jitter_fix: float  setget __set, get_physics_jitter_fix

func is_editor_hint() -> bool:
	return Engine.editor_hint

func is_printing_error_messages() -> bool:
	return Engine.print_error_messages

func get_iterations_per_second() -> int:
	return Engine.iterations_per_second

func get_target_fps() -> int:
	return Engine.target_fps

func get_time_scale() -> float:
	return Engine.time_scale

func get_physics_jitter_fix() -> float:
	return Engine.physics_jitter_fix

func get_author_info() -> Dictionary:
	return Engine.get_author_info()

func get_donor_info() -> Dictionary:
	return Engine.get_donor_info()

func get_frames_drawn() -> int:
	return Engine.get_frames_drawn()

func get_frames_per_second() -> float:
	return Engine.get_frames_per_second()

func get_idle_frames() -> int:
	return Engine.get_idle_frames()

func get_license_info() -> Dictionary:
	return Engine.get_license_info()

func get_license_text() -> String:
	return Engine.get_license_text()

func get_main_loop() -> MainLoop:
	return null

func get_physics_frames() -> int:
	return Engine.get_physics_frames()

func get_physics_interpolation_fraction() -> float:
	return Engine.get_physics_interpolation_fraction()

func get_singleton(name: String) -> Object:
	return self if name == "Engine" else null

func get_version_info() -> Dictionary:
	return Engine.get_version_info()

func has_singleton(name: String) -> bool:
	return name == "Engine"

func is_in_physics_frame() -> bool:
	return Engine.is_in_physics_frame()

func _to_string() -> String:
	return Engine.to_string()

func __set(_value) -> void:
	pass

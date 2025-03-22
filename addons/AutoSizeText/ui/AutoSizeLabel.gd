@tool
extends Label
class_name AutoSizeLabel

## watch_text_change true is needed for this event to work
signal text_changed(old_text: String, new_text: String)

## When true, text-size will be re-calculated when the text is changed.[br]
## Needed for the text_changed event to work.
@export
var watch_text_change: bool = false

@export_tool_button("FORCE REFRESH")
var refresh_button: Callable = do_resize_text

@export_group("Auto-Size")

var _min_font_size: int = 8
@export_range(1, 512, 1.0)
var min_font_size: int = _min_font_size:
	get:
		return _min_font_size
	set(value):
		_min_font_size = value
		if _min_font_size >= max_font_size:
			_min_font_size = max_font_size - 1
			push_warning(
				"min_font_size {0} >= max_font_size {1}, fixed to {2}"
				.format([value, max_font_size, _min_font_size])
			)

		notify_property_list_changed()
		resize_text()

var _max_font_size: int = 38
@export_range(1, 512, 1.0)
var max_font_size: int = _max_font_size:
	get:
		return _max_font_size
	set(value):
		_max_font_size = value
		if _max_font_size <= min_font_size:
			_max_font_size = min_font_size + 1
			push_warning(
				"max_font_size {0} <= min_font_size {1}, fixed to {2}"
				.format([value, min_font_size, _max_font_size])
			)

		notify_property_list_changed()
		resize_text()

@export_group("Step Size")

var _step_sizes: Array[int] = []
## Needs 2 numbers to work / will be automatically prefered over "Auto-Size"[br]
## when 2 numbers or more are present.
@export
var step_sizes: Array[int] = _step_sizes:
	get:
		return _step_sizes
	set(value):
		_step_sizes = value
		_step_sizes.sort()
		
		notify_property_list_changed()
		resize_text()


var _processing_flag: bool = false
var _last_text: String = ""


func _ready() -> void:
	# TODO: change defaults instead of hard-setting!

	if autowrap_mode == TextServer.AUTOWRAP_OFF:
		autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		push_warning("changed autowrap_mode to " + str(autowrap_mode))

	if text_overrun_behavior == TextServer.AUTOWRAP_OFF:
		text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		push_warning("changed text_overrun_behavior to " + str(text_overrun_behavior))

	clip_text = true
	
	draw.connect(resize_text)
	resized.connect(do_resize_text)
	do_resize_text()


func _process(delta: float) -> void:
	if watch_text_change:
		if text != _last_text:
			do_resize_text()
			
			if not Engine.is_editor_hint():
				text_changed.emit(_last_text, text)
				
			_last_text = text


func resize_text() -> void:
	if not needs_resize():
		return

	do_resize_text()


func do_resize_text() -> void:
	# Prevent draw call stack handler
	if _processing_flag:
		return 
	
	_processing_flag = true
	for target_font_size: int in get_iterator():
		set(&"theme_override_font_sizes/font_size", target_font_size)

		# force a refresh before checking needs_resize
		custom_minimum_size = Vector2(custom_minimum_size.x, custom_minimum_size.y)

		if not needs_resize():
			break
	
	_processing_flag = false


func get_iterator() -> Array:
	if len(step_sizes) >= 2:
		var clone: Array[int] = step_sizes.duplicate()
		clone.reverse()
		return clone
	
	if len(step_sizes) == 1:
		push_warning(name + " Step sizes needs at least 2 numbers to work")
	
	return range(max_font_size, min_font_size, -1)


func needs_resize() -> bool:
	return get_line_count() > get_visible_line_count()

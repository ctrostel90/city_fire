class_name FireTruckDebug
extends CanvasLayer
## Autoload singleton. Register this scene (debug_layer.tscn) in
## Project Settings > Autoload as "DebugLayer".
##
## Usage:
##   DebugLayer.add_debug_value("Speed", self, "speed")
##   DebugLayer.add_debug_value_callable("FPS", func(): return Engine.get_frames_per_second())
##   DebugLayer.remove_debug_value("Speed")
##   DebugLayer.toggle()

const DebugValueEntryScene := preload("res://utility/debug_layer/debug_value_entry.tscn")

@onready var _vbox: VBoxContainer = $Container/data

var _entries: Dictionary = { } # display_name (String) -> DebugValueEntry


func _ready() -> void:
	layer = 100
	visible = false
	# So the debug layer keeps working even if you pause the game to inspect values.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	# Add a "toggle_debug_layer" action in Input Map (e.g. bound to F3 / `)
	if event.is_action_pressed("toggle_debug_layer"):
		toggle()


func toggle() -> void:
	visible = not visible


func show_layer() -> void:
	visible = true


func hide_layer() -> void:
	visible = false


## Watches object.property live. Reads it every frame and lets the user
## edit the LineEdit to write back into the object via .set().
## Requires `property` to be an actual property/exported var on `object`,
## not a local variable in a function.
func add_debug_value(display_name: String, object: Object, property: String) -> void:
	if _entries.has(display_name):
		push_warning("DebugLayer: '%s' is already being tracked." % display_name)
		return

	var entry: DebugValueEntry = DebugValueEntryScene.instantiate()
	_vbox.add_child(entry)
	entry.setup_object(display_name, object, property)
	_entries[display_name] = entry


## Alternative for values that aren't a simple object property: computed
## values, local values you've wrapped, read-only telemetry, etc.
## setter is optional - omit it for a read-only row.
func add_debug_value_callable(display_name: String, getter: Callable, setter: Callable = Callable()) -> void:
	if _entries.has(display_name):
		push_warning("DebugLayer: '%s' is already being tracked." % display_name)
		return

	var entry := DebugValueEntryScene.instantiate()
	_vbox.add_child(entry)
	entry.setup_callable(display_name, getter, setter)
	_entries[display_name] = entry


func remove_debug_value(display_name: String) -> void:
	if _entries.has(display_name):
		_entries[display_name].queue_free()
		_entries.erase(display_name)


func clear_all() -> void:
	for entry in _entries.values():
		entry.queue_free()
	_entries.clear()

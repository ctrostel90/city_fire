class_name DebugValueEntry
extends HBoxContainer

@onready var _name_label: Label = $Label
@onready var _value_edit: LineEdit = $Value

var _object: Object = null
var _property: String = ""

var _getter: Callable
var _setter: Callable
var _use_callable: bool = false

var _editing: bool = false # true while the user has focus, so we don't overwrite their typing


func setup_object(display_name: String, object: Object, property: String) -> void:
	_name_label.text = display_name
	_object = object
	_property = property
	_use_callable = false
	_value_edit.editable = true
	_refresh_display()


func setup_callable(display_name: String, getter: Callable, setter: Callable) -> void:
	_name_label.text = display_name
	_getter = getter
	_setter = setter
	_use_callable = true
	_value_edit.editable = setter.is_valid()
	_refresh_display()


func _process(_delta: float) -> void:
	if not _editing:
		_refresh_display()


func _refresh_display() -> void:
	var value = _read_value()
	if value == null:
		_name_label.modulate = Color(1, 0.5, 0.5) # flag dead references visually
		return
	_name_label.modulate = Color(1, 1, 1)
	_value_edit.text = str(value)


func _read_value():
	if _use_callable:
		return _getter.call() if _getter.is_valid() else null
	if is_instance_valid(_object):
		return _object.get(_property)
	return null


func _write_value(value: float) -> void:
	if _use_callable:
		if _setter.is_valid():
			_setter.call(value)
	elif is_instance_valid(_object):
		_object.set(_property, value)


func _on_value_edit_focus_entered() -> void:
	_editing = true


func _on_value_edit_focus_exited() -> void:
	_editing = false


func _on_value_edit_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float():
		_write_value(new_text.to_float())
	_editing = false
	_value_edit.release_focus()

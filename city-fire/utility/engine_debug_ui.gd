class_name FireTruckDebug
extends CanvasLayer

@export var engine: FireEngineController
@export var tiller: TillerController

var ang_vel_lbl: Label


func _ready() -> void:
	ang_vel_lbl = find_child("AngVel")
	print(ang_vel_lbl)


func _process(_delta: float) -> void:
	ang_vel_lbl.text = str(engine.angular_velocity)

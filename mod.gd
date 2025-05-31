extends RefCounted

class_name mod

func _init() -> void:
	Logger.write("getin")
	var go:Variant=go.new()
	go.name="go"
	go._ready()

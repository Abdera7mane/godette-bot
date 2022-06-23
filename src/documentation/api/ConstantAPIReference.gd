class_name ConstantAPIReference

var name: String
var value: String
var description: String

func _to_string() -> String:
	return "%s = %s" % [name, value]

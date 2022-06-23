class_name EnumAPIReference

var name: String
var entries: Dictionary
var description: String

class Entry:
	var name: String
	var value: String
	var description: String
	
	func _to_string() -> String:
		return "%s = %s" % [name, value]

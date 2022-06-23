class_name SignalAPIReference

var name: String
var description: String
var arguments: Array

func _to_string() -> String:
	var argument_list: PoolStringArray = []
	for argument in arguments:
		argument_list.append(str(argument))
	return "%s(%s)" % [name, argument_list.join(", ")]

class Argument:
	var name: String
	var type: String
	
	func _to_string() -> String:
		return  "%s: %s" % [name, type]

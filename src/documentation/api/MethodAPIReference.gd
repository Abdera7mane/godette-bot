class_name MethodAPIReference

var name: String
var qualifiers: String
var return_type: String
var description: String
var arguments: Array

func _to_string() -> String:
	var argument_list: PoolStringArray = []
	for argument in arguments:
		argument_list.append(str(argument))
	if qualifiers == "vararg":
		argument_list.append("...")
	return  ("%s %s(%s) %s" % [return_type, name, argument_list.join(", "), qualifiers]).strip_edges()

class Argument:
	var name: String
	var type: String
	var default: String
	
	func _to_string() -> String:
		return  "%s: %s" % [name, type]\
				+ (" = %s" % default if not default.empty() else "")

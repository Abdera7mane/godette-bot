class_name MemberAPIReference

var name: String
var description: String
var type: String
var setter: String
var getter: String
var default: String

func _to_string() -> String:
	return  "%s %s" % [type, name]\
			+ (" [default: %s]" % default if not default.empty() else "")

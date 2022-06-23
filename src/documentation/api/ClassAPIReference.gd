class_name ClassAPIReference

var name: String
var inherits: String
var brief_description: String
var description: String
var tutorials: Array
var methods: Dictionary
var members: Dictionary
var signals: Dictionary
var constants: Dictionary
var enums: Dictionary

func has_brief_description() -> bool:
	return not brief_description.empty()

func has_description() -> bool:
	return not description.empty()

func contains_method(method: String) -> bool:
	return methods.has(method.to_lower())

func contains_signal(signal_name: String) -> bool:
	return signals.has(signal_name.to_lower())

func contains_member(member: String) -> bool:
	return members.has(member.to_lower())

func contains_constant(constant: String) -> bool:
	return constants.has(constant.to_lower())

func contains_enum(enum_name: String) -> bool:
	return enums.has(enum_name.to_lower())

func get_method(name: String) -> MethodAPIReference:
	return methods[name.to_lower()]

func get_member(name: String) -> MemberAPIReference:
	return members[name.to_lower()]

func get_signal(name: String) -> SignalAPIReference:
	return signals[name.to_lower()]

func get_constant(name: String) -> ConstantAPIReference:
	return constants[name.to_lower()]

func get_enum(name: String) -> EnumAPIReference:
	return enums[name.to_lower()]

class Tutorial:
	var title: String
	var link: String

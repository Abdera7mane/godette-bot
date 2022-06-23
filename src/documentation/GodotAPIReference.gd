class_name GodotAPIReference

var classes: Dictionary

func load(path: String) -> int:
	var parser := GodotAPIReferenceParser.new()
	parser.bold_start = "**"
	parser.bold_end = "**"
	
	parser.italic_start = "*"
	parser.italic_end = "*"
		
	parser.underline_start = "__"
	parser.underline_end = "__"
		
	parser.strikethrough_start = "~~"
	parser.strikethrough_end = "~~"
		
	parser.link_format = "{url}"
	parser.named_link_format = "[{title}]({url})"
	
	parser.code_start = "`"
	parser.code_end = "`"

	parser.codeblock_start = "```gdscript"
	parser.codeblock_end = "```"
	
	parser.class_tag_format = "`{name}`"
	parser.method_tag_format = "`{name}()`"
	parser.member_tag_format = "`{name}`"
	parser.signal_tag_format = "`Signal:{name}()`"
	parser.constant_tag_format = "`{name} const`"
	parser.enum_tag_format = "`{name} enum`"
	
	var error: int = yield(parser.load(path), "completed")
	if error != OK:
		push_error('Failed loading documentation at path "%s", error: %d' % [
			path, error
		])
	else:
		classes = parser.classes
		print_debug("Successfully loaded %d class documentations" % classes.size())
	return error

func get_class_reference(name: String) -> ClassAPIReference:
	return classes[name.to_lower()]

func get_parents_from_class(name: String) -> PoolStringArray:
	var parents: PoolStringArray = []
	if has_class(name):
		var clazz: ClassAPIReference = get_class_reference(name)
		var parent: String = clazz.inherits
		if not parent.empty():
			parents.append(parent)
			parents.append_array(get_parents_from_class(parent))
	return parents

func has_class(name: String) -> bool:
	return classes.has(name.to_lower())

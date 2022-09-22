class_name GodotAPIReferenceParser

const DOCS_URL: String = "https://docs.godotengine.org/en/%s"

const PROPERTY_ANCHOR: String = "#class-%s-property-%s"
const METHOD_ANCHOR: String = "#class-%s-method-%s"

var _current_class: ClassAPIReference
var _current_reference

var bold_formatter: = RegEx.new()
var italic_formatter: = RegEx.new()
var underline_formatter: = RegEx.new()
var strikethrough_formatter: = RegEx.new()
var link_formatter: = RegEx.new()
var named_link_formatter: = RegEx.new()
var code_formatter: = RegEx.new()
var codeblock_formatter: = RegEx.new()
var class_formatter: = RegEx.new()
var method_formatter: = RegEx.new()
var member_formatter: = RegEx.new()
var signal_formatter: = RegEx.new()
var constant_formatter: = RegEx.new()
var enum_formatter: = RegEx.new()

var bold_start: String
var bold_end: String

var italic_start: String
var italic_end: String

var underline_start: String
var underline_end: String

var strikethrough_start: String
var strikethrough_end: String

var link_format: String # example: "{url}"
var named_link_format: String # example: "[{title}]({url})"

var code_start: String
var code_end: String

var codeblock_start: String
var codeblock_end: String

var class_tag_format: String
var method_tag_format: String
var member_tag_format: String
var signal_tag_format: String
var constant_tag_format: String
var enum_tag_format: String

var classes: Dictionary

var godot_version: String

func _init() -> void:
	bold_formatter.compile("\\[b\\]((.|\n)*?)\\[\/b\\]")
	italic_formatter.compile("\\[i\\]((.|\n)*?)\\[/i\\]")
	underline_formatter.compile("\\[u\\]((.|\n)*?)\\[/u\\]")
	strikethrough_formatter.compile("\\[s\\]((.|\n)*?)\\[/s\\]")
	link_formatter.compile("\\[url\\]((.|\n)*?)\\[/url\\]")
	named_link_formatter.compile("\\[url=(.+?)\\]((.|\n)*?)\\[/url\\]")
	code_formatter.compile("\\[code\\]((.|\n)*?)\\[/code\\]")
	codeblock_formatter.compile("\\[codeblock\\]((.|\n)*?)\\[/codeblock\\]")
	class_formatter.compile("(?<=^|\\s)\\[([\\w@\\.]+)\\]")
	method_formatter.compile("(?<=^|\\s)\\[method ([\\w@\\.]+)\\]")
	member_formatter.compile("(?<=^|\\s)\\[member ([\\w@\\.]+)\\]")
	signal_formatter.compile("(?<=^|\\s)\\[signal ([\\w@\\.]+)\\]")
	constant_formatter.compile("(?<=^|\\s)\\[constant ([\\w@\\.]+)\\]")
	enum_formatter.compile("(?<=^|\\s)\\[enum ([\\w@\\.]+)\\]")

func format_description(description: String) -> String:
	var formatted: String = description.dedent().strip_edges()
	
	if not (bold_start.empty() or bold_end.empty()):
		formatted = bold_formatter.sub(
			formatted,
			"%s$1%s" % [bold_start, bold_end],
			true
		)
		
	if not (italic_start.empty() or italic_end.empty()):
		formatted = italic_formatter.sub(
			formatted,
			"%s$1%s" % [italic_start, italic_end],
			true
		)
			
	if not (underline_start.empty() or underline_end.empty()):
		formatted = underline_formatter.sub(
			formatted,
			"%s$1%s" % [underline_start, underline_end],
			true
		)
		
	if not (strikethrough_start.empty() or strikethrough_end.empty()):
		formatted = strikethrough_formatter.sub(
			formatted,
			"%s$1%s" % [strikethrough_start, strikethrough_end],
			true
		)
			
	if not link_format.empty():
		formatted = link_formatter.sub(
			formatted,
			link_format.format({url = "$1"}),
			true
		)
		
	if not named_link_format.empty():
		formatted = named_link_formatter.sub(
			formatted,
			named_link_format.format({title = "$2", url = "$1"}),
			true
		)
		
	if not (code_start.empty() or code_end.empty()):
		formatted = code_formatter.sub(
			formatted,
			"%s$1%s" % [code_start, code_end],
			true
		)
		
	if not (codeblock_start.empty() or codeblock_end.empty()):
		formatted = codeblock_formatter.sub(
			formatted,
			"%s$1%s" % [codeblock_start, codeblock_end],
			true
		)
		
			
	if not class_tag_format.empty():
		formatted = class_formatter.sub(
			formatted,
			class_tag_format.format({name = "$1"}),
			true
		)
		
	if not method_tag_format.empty():
		formatted = method_formatter.sub(
			formatted,
			method_tag_format.format({name = "$1"}),
			true
		)
		
			
	if not member_tag_format.empty():
		formatted = member_formatter.sub(
			formatted,
			member_tag_format.format({name = "$1"}),
			true
		)
		
	if not signal_tag_format.empty():
		formatted = signal_formatter.sub(
			formatted,
			signal_tag_format.format({name = "$1"}),
			true
		)
				
	if not constant_tag_format.empty():
		formatted = constant_formatter.sub(
			formatted,
			constant_tag_format.format({name = "$1"}),
			true
		)
				
	if not enum_tag_format.empty():
		formatted = enum_formatter.sub(
			formatted,
			enum_tag_format.format({name = "$1"}),
			true
		)
		
	return formatted.replace("$DOCS_URL", get_docs_url(godot_version))

func handle_node_name(current_node: String, parent_node: String, parser: XMLParser) -> int:
	var error: int = OK
	var node_type: int = parser.get_node_type()
	match current_node:
		"class":
			if node_type == XMLParser.NODE_ELEMENT:
				_current_class.name = parser.get_named_attribute_value("name")
				_current_class.inherits = parser.get_named_attribute_value_safe("inherits")
		"brief_description":
			if node_type != XMLParser.NODE_TEXT:
				continue
			if parent_node == "class":
				var description: String = format_description(parser.get_node_data())
				_current_class.brief_description = description
			else:
				error = ERR_INVALID_DATA
		"description":
			if node_type != XMLParser.NODE_TEXT:
				continue
			var description: String = format_description(parser.get_node_data())
			if _current_reference and "description" in _current_reference:
				_current_reference.description = description
			elif parent_node == "class":
				_current_class.description = description
			else:
				error = ERR_INVALID_DATA
		"link":
			if node_type == XMLParser.NODE_ELEMENT:
				_current_reference = ClassAPIReference.Tutorial.new()
				_current_reference.title = parser.get_named_attribute_value_safe("title")
				_current_class.tutorials.append(_current_reference)
			elif node_type == XMLParser.NODE_TEXT:
				var link: String = parser.get_node_data()
				link = link.replace("$DOCS_URL", get_docs_url(godot_version))
				_current_reference.link = link
				
			else:
				error = ERR_INVALID_DATA
		"method":
			if node_type != XMLParser.NODE_ELEMENT:
				continue
			_current_reference = MethodAPIReference.new()
			_current_reference.name = parser.get_named_attribute_value("name")
			_current_reference.qualifiers = parser.get_named_attribute_value_safe("qualifiers")
			_current_class.methods[_current_reference.name.to_lower()] = _current_reference
		"member":
			if node_type == XMLParser.NODE_ELEMENT:
				_current_reference = MemberAPIReference.new()
				_current_reference.name = parser.get_named_attribute_value("name")
				_current_reference.type = parser.get_named_attribute_value("type")
				_current_reference.setter = parser.get_named_attribute_value_safe("setter")
				_current_reference.getter = parser.get_named_attribute_value_safe("getter")
				_current_reference.default = parser.get_named_attribute_value_safe("default")
				_current_class.members[_current_reference.name.to_lower()] = _current_reference
			elif node_type == XMLParser.NODE_TEXT:
				if _current_reference is MemberAPIReference:
					var description: String = format_description(parser.get_node_data())
					_current_reference.description = description
				else:
					error = ERR_INVALID_DATA
		"signal":
			if node_type != XMLParser.NODE_ELEMENT:
				continue
			_current_reference = SignalAPIReference.new()
			_current_reference.name = parser.get_named_attribute_value("name")
			_current_class.signals[_current_reference.name.to_lower()] = _current_reference
		"constant":
			if node_type == XMLParser.NODE_ELEMENT:
				if parser.has_attribute("enum"):
					var name: String = parser.get_named_attribute_value("enum")
					var enum_reference: EnumAPIReference
					if _current_class.enums.has(name.to_lower()):
						enum_reference = _current_class.enums[name.to_lower()]
					else:
						enum_reference = EnumAPIReference.new()
						enum_reference.name = name
						_current_class.enums[name.to_lower()] = enum_reference
					var entry := EnumAPIReference.Entry.new()
					entry.name = parser.get_named_attribute_value("name")
					entry.value = parser.get_named_attribute_value("value")
					enum_reference.entries[entry.name.to_lower()] = entry
					_current_reference = enum_reference
				else:
					var constant_reference := ConstantAPIReference.new()
					constant_reference.name = parser.get_named_attribute_value("name")
					constant_reference.value = parser.get_named_attribute_value("value")
					_current_class.constants[constant_reference.name.to_lower()] = constant_reference
					_current_reference = constant_reference
			elif node_type == XMLParser.NODE_TEXT:
				var description: String = format_description(parser.get_node_data())
				_current_reference.description = description
			else:
				error = ERR_INVALID_DATA
		"return":
			if node_type != XMLParser.NODE_ELEMENT:
				continue
			_current_reference.return_type = parser.get_named_attribute_value("type")
		"argument":
			if node_type != XMLParser.NODE_ELEMENT:
				continue
			var argument_reference
			match parent_node:
				"method":
					argument_reference = MethodAPIReference.Argument.new()
				"signal":
					argument_reference = SignalAPIReference.Argument.new()
			if "arguments" in _current_reference and argument_reference:
				argument_reference.name = parser.get_named_attribute_value("name")
				argument_reference.type = parser.get_named_attribute_value("type")
				if "default" in argument_reference:
					argument_reference.default = parser.get_named_attribute_value_safe("default")
				_current_reference.arguments.append(argument_reference)
			else:
				error = ERR_INVALID_DATA
	
	return error

func load(path: String) -> int:
	yield(Engine.get_main_loop(), "idle_frame")
	
	var directory: Directory = Directory.new()
	
	var error: int = directory.open(path)
	if error != OK:
		return error
		
	directory.list_dir_begin(true, true)
	var file_name: String = directory.get_next()
	while error == OK and file_name != "":
		var current_path: String = directory.get_current_dir().plus_file(file_name)
		if directory.current_is_dir():
			error = yield(self.load(current_path), "completed")
		elif file_name.get_extension() == "xml":
			error = load_file(current_path)
		file_name = directory.get_next()
		yield(Engine.get_main_loop(), "idle_frame")
	return error

func load_file(path: String) -> int:
#	print_debug("Loading doc file: ", path)
	var parser: XMLParser = XMLParser.new()
	
	var error: int = parser.open(path)
	if error != OK:
		return error
	
	_current_class = ClassAPIReference.new()
	
	var stack: PoolStringArray
	var current_node: String
	var parent_node: String
	while error == OK and parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				current_node = parser.get_node_name()
				if not parser.is_empty():
					stack.append(current_node)
					parent_node = stack[-2] if stack.size() > 1 else ""
				else:
					parent_node = stack[-1] if stack.size() > 1 else ""
			XMLParser.NODE_ELEMENT_END:
				stack.remove(stack.size() - 1)
				current_node = stack[-1] if stack.size() > 0 else ""
				parent_node = stack[-2] if stack.size() > 1 else ""
		
		error = handle_node_name(current_node, parent_node, parser)
	
	if error == OK:
		if classes.has(_current_class.name.to_lower()):
			printerr("Duplicate: ", path)
		classes[_current_class.name.to_lower()] = _current_class
	
	_current_class = null
	_current_reference = null
	
	return error

static func get_docs_url(version: String = "") -> String:
	return DOCS_URL % get_godot_version() if version.empty() else version

static func get_class_url(name: String) -> String:
	return   get_docs_url()\
			.plus_file("classes")\
			.plus_file("class_%s.html" % name.to_lower())

static func get_godot_version() -> String:
	var version: Dictionary = Engine.get_version_info()
	return str(version.major, ".", version.minor)

# warning-ignore-all:return_value_discarded

class_name DocsCommandExecutor extends ApplicationCommandExecutor

const BOT_SOURCE: String = "https://github.com/Abdera7mane/godette-bot"

const GODOT_3_VERSION: String = "3.5"
const GODOT_4_VERSION: String = ""

const CLASS_URL: String = "https://docs.godotengine.org/en/{version}/classes/class_{name}.html"

const ASSETS_URL: String = "https://ik.imagekit.io/godette"

const ICON_BACKGROUND: String = "202225"

const ICON_SIZE: int = 64
const DEFAULT_CLASS_ICON: String = "default_class_icon.png"
const ICONS_URL: String = ASSETS_URL + "/godot/icons/3_x/tr:w-%d,h-%d,cm-pad_resize,q-100,bg-%s,di-%s" % [
	ICON_SIZE, ICON_SIZE,
	ICON_BACKGROUND,
	DEFAULT_CLASS_ICON
]

const ICON_URL: String = ICONS_URL + "/{name}.png"

var godot_3: GodotAPIReference
var godot_4: GodotAPIReference

func _init() -> void:
	load_godot_3_dcos()
#	load_godot_4_dcos()

func load_godot_3_dcos() -> void:
	godot_3 = GodotAPIReference.new()
	yield(godot_3.load("res://assets/documentation/godot-3.x"), "completed")
	
	# Add aliases
	godot_3.classes["any"] = godot_3.classes["variant"]
	godot_3.classes["obj"] = godot_3.classes["object"]
	godot_3.classes["integer"] = godot_3.classes["int"]
	godot_3.classes["real"] = godot_3.classes["float"]
	godot_3.classes["number"] = godot_3.classes["float"]
	godot_3.classes["dict"] = godot_3.classes["dictionary"]
	godot_3.classes["str"] = godot_3.classes["string"]
	godot_3.classes["list"] = godot_3.classes["array"]
	godot_3.classes["bytes"] = godot_3.classes["poolbytearray"]
	godot_3.classes["colors"] = godot_3.classes["poolcolorarray"]
	godot_3.classes["ints"] = godot_3.classes["poolintarray"]
	godot_3.classes["integers"] = godot_3.classes["poolintarray"]
	godot_3.classes["reals"] = godot_3.classes["poolrealarray"]
	godot_3.classes["floats"] = godot_3.classes["poolrealarray"]
	godot_3.classes["numbers"] = godot_3.classes["poolrealarray"]
	godot_3.classes["strings"] = godot_3.classes["poolstringarray"]
	godot_3.classes["vectors2"] = godot_3.classes["poolvector2array"]
	godot_3.classes["vectors3"] = godot_3.classes["poolvector3array"]
	godot_3.classes["node3d"] = godot_3.classes["spatial"]
	
func load_godot_4_dcos() -> void:
	yield(godot_3.load("res://assets/documentation/godot-master"), "completed")

func get_class_icon(clazz: String) -> String:
	return ICON_URL.format({name = clazz.to_lower()})

func get_class_url(clazz: String) -> String:
	return CLASS_URL.format({
			version = "3.5",
			name = clazz.to_lower()
		})

func generate_embed(title: String, url: String, thumbnail: String) -> MessageEmbedBuilder:
	var version: Dictionary = Engine.get_version_info()
	return MessageEmbedBuilder.new()\
			.set_title(title)\
			.set_url(url)\
			.set_thumbnail(MessageEmbedAttachmentBuilder.new(thumbnail))\
			.set_footer(
				MessageEmbedFooterBuilder.new(
					"Godot %d.%d documentation" % [version.major, version.minor]
				).set_icon_url(ASSETS_URL + "/godot_docs.png")
			)

func generate_class_embed(clazz: String, anchor: String = "") -> MessageEmbedBuilder:
	var url: String = get_class_url(clazz) + anchor
	var icon: String = get_class_icon(clazz)
	return generate_embed(clazz, url, icon)

func display_class_documentation(clazz: String, api: GodotAPIReference) -> DiscordInteractionMessage:
	var message := DiscordInteractionMessage.new()
	
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	var embed: MessageEmbedBuilder = generate_class_embed(clazz_name)\
		.set_description(class_reference.brief_description)
	
	var parents: PoolStringArray = api.get_parents_from_class(clazz_name)
	if parents.size() > 0:
		var list: PoolStringArray = []
		for parent in parents:
			list.append('`' + parent + '`')
		embed.add_field("Inherits", "**" + list.join(" < ") + "**")
	
	if class_reference.has_description():
		var description: String = class_reference.description
		description = description.substr(0, description.find(".\n"))
		if description.length() != class_reference.description.length():
			description += " *[...]*"
		embed.add_field("Description", description)
	
	if class_reference.tutorials.size() > 0:
		var tutorials: PoolStringArray = []
		for tutorial in  class_reference.tutorials:
			if tutorial.title.empty():
				tutorials.append(tutorial.link)
			else:
				tutorials.append("[%s](%s)" % [tutorial.title, tutorial.link])
		embed.add_field("Tutorials", "**" + tutorials.join(", ") + "**")
	
	return message.add_embed(embed)

func display_methods_documentation(clazz: String, api: GodotAPIReference) -> DiscordInteractionMessage:
	var message := DiscordInteractionMessage.new()
	
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	if class_reference.methods.size() == 0:
		message.set_content("**No methods in base `%s`**" % clazz_name)
	else:
		var methods: Array = class_reference.methods.values()
		
		var description: String = "`%s` class methods\n" % clazz_name
		for i in range(min(methods.size(), 5)):
			var method: MethodAPIReference = methods[i]
			# Arduino is the closest to highlight most of the method syntax
			description += str('```ino\n', method, '```')
		
		message.add_embed(
			generate_class_embed(clazz_name, "#method-descriptions")\
			.set_title(clazz_name + " methods")\
			.set_description(description)
		)
		
	return message

func display_method_documentation(clazz: String, method: String, api: GodotAPIReference) -> DiscordInteractionMessage:
	var message := DiscordInteractionMessage.new()
	
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	
	if class_reference.contains_method(method):
		var method_ref: MethodAPIReference = class_reference.get_method(method)
		message.add_embed(
			generate_class_embed(clazz_name, "#method-descriptions")\
			.set_title("%s.%s()" % [clazz_name, method_ref.name])\
			.set_description(method_ref.description)\
			.add_field("Declaration", str('```ino\n', method_ref, '```'))
		)
	else:
		message.set_content("**`%s` method not found in base `%s`**" % [method, clazz_name])
		
	return message

func display_properties_documentation(clazz: String, api: GodotAPIReference) -> DiscordInteractionMessage:
	var message := DiscordInteractionMessage.new()
	
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	if class_reference.members.size() == 0:
		message.set_content("**No properties in base `%s`**" % clazz_name)
	else:
		var members: Array = class_reference.members.values()
		
		var description: String = "`%s` class properties\n" % clazz_name
		for i in range(min(members.size(), 5)):
			var member: MemberAPIReference = members[i]
			description += str('```ino\n', member, '```')
		
		message.add_embed(
			generate_class_embed(clazz_name, "#property-descriptions")\
			.set_title(clazz_name + " properties")\
			.set_description(description)
		)
		
	return message
	

func display_property_documentation(clazz: String, property: String, api: GodotAPIReference) -> DiscordInteractionMessage:
	var message := DiscordInteractionMessage.new()
	
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	
	if class_reference.contains_member(property):
		var property_ref: MemberAPIReference = class_reference.get_member(property)
		message.add_embed(
			generate_class_embed(clazz_name, "#property-descriptions")\
			.set_title("%s.%s" % [clazz_name, property_ref.name])\
			.set_description(property_ref.description)\
			.add_field("Declaration", str('```ino\n', property_ref, '```'))
		)
	else:
		message.set_content("**`%s` property not found in base `%s`**" % [property, clazz_name])
		
	return message

func display_signals_documentation(clazz: String, api: GodotAPIReference) -> DiscordInteractionMessage:
	var message := DiscordInteractionMessage.new()
	
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	if class_reference.signals.size() == 0:
		message.set_content("**No signals in base `%s`**" % clazz_name)
	else:
		var signals: Array = class_reference.signals.values()
		
		var description: String = "`%s` class signals\n" % clazz_name
		for i in range(min(signals.size(), 5)):
			var signal_ref: SignalAPIReference = signals[i]
			# Yeah whatever, haskell time
			description += str('```hs\n', signal_ref, '```')
		
		message.add_embed(
			generate_class_embed(clazz_name, "#signals")\
			.set_title(clazz_name + " singals")\
			.set_description(description)
		)
		
	return message

func display_signal_documentation(clazz: String, signal_name: String, api: GodotAPIReference) -> DiscordInteractionMessage:
	var message := DiscordInteractionMessage.new()
	
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	
	if class_reference.contains_signal(signal_name):
		var signal_ref: SignalAPIReference = class_reference.get_signal(signal_name)
		message.add_embed(
			generate_class_embed(clazz_name, "#signals")\
			.set_title("%s [signal] %s" % [clazz_name, signal_ref.name])\
			.set_description(signal_ref.description)\
			.add_field("Declaration", str('```hs\n', signal_ref, '```'))
		)
	else:
		message.set_content("**`%s` signal not found in base `%s`**" % [signal_name, clazz_name])
		
	return message

func display_constants_documentation(clazz: String, api: GodotAPIReference) -> DiscordInteractionMessage:
	var message := DiscordInteractionMessage.new()
	
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	
	if class_reference.constants.size() == 0:
		message.set_content("**No constants in base `%s`**" % clazz_name)
	else:
		var constants: Array = class_reference.constants.values()
		
		var description: String = "`%s` class constants\n" % clazz_name
		for i in range(min(constants.size(), 5)):
			var constant: ConstantAPIReference = constants[i]
			description += str('```ino\n', constant, '```')
		
		message.add_embed(
			generate_class_embed(clazz_name, "#constants")\
			.set_title(clazz_name + " constants")\
			.set_description(description)
		)
		
	return message

func display_constant_documentation(clazz: String, constant: String, api: GodotAPIReference) -> DiscordInteractionMessage:
	var message := DiscordInteractionMessage.new()
	
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	
	if class_reference.contains_constant(constant):
		var const_ref: ConstantAPIReference = class_reference.get_constant(constant)
		message.add_embed(
			generate_class_embed(clazz_name, "#constants")\
			.set_title("%s.%s" % [clazz_name, const_ref.name])\
			.set_description(const_ref.description)\
			.add_field("Declaration", str('```hs\n', const_ref, '```'))
		)
	else:
		message.set_content("**`%s` constant not found in base `%s`**" % [constant, clazz_name])
		
	return message

func display_enums_documentation(clazz: String, api: GodotAPIReference) -> DiscordInteractionMessage:
	var message := DiscordInteractionMessage.new()
	
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	if class_reference.enums.size() == 0:
		message.set_content("**No enums in base `%s`**" % clazz_name)
	else:
		var enums: Array = class_reference.enums.values()
		
		var description: String = "`%s` class enums\n" % clazz_name
		for i in range(min(enums.size(), 5)):
			var enum_ref: EnumAPIReference = enums[i]
			description += str('```swift\n', enum_ref.name, '```')
		
		message.add_embed(
			generate_class_embed(clazz_name, "#enumerations")\
			.set_title(clazz_name + " enums")\
			.set_description(description)
		)
		
	return message

func display_enum_documentation(clazz: String, enum_name: String, api: GodotAPIReference) -> DiscordInteractionMessage:
	var message := DiscordInteractionMessage.new()
	
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	
	if class_reference.contains_enum(enum_name):
		var enum_ref: EnumAPIReference = class_reference.get_enum(enum_name)
		
		var description: String = enum_ref.description + "\n```swift\n"
		var entries: Array = enum_ref.entries.values()
		for i in range(min(entries.size(), 5)):
			var entry: EnumAPIReference.Entry = entries[i]
			description += str(entry, "\n")
		description += "```"
		message.add_embed(
			generate_class_embed(clazz_name, "#enumerations")\
			.set_title("%s.%s" % [clazz_name, enum_ref.name])\
			.set_description(description)\
		)
	else:
		message.set_content("**`%s` enum not found in base `%s`**" % [enum_name, clazz_name])
		
	return message

func interact(interaction: DiscordInteraction) -> void:
	var clazz: String = interaction.get_named_string_option_value("class_name")
	var attribute: String = interaction.get_named_string_option_value("attribute")
	var attribute_name: String = interaction.get_named_string_option_value("attribute_name")
	var for_godot_4: bool = interaction.get_named_boolean_option_value("godot_4")
	
#	var api_reference: GodotAPIReference = godot_4 if for_godot_4 else godot_3
	var api_reference: GodotAPIReference = godot_3
	
	var message: DiscordInteractionMessage
	
	if attribute.empty() and not attribute_name.empty():
		message = DiscordInteractionMessage.new()\
			.set_content("**`attribute` option must be set when `attribute_name` is provided**")
	
	elif api_reference.has_class(clazz):
		match attribute:
			"method":
				if attribute_name.empty():
					message = display_methods_documentation(clazz, api_reference)
				else:
					message = display_method_documentation(clazz, attribute_name, api_reference)
			"property":
				if attribute_name.empty():
					message = display_properties_documentation(clazz, api_reference)
				else:
					message = display_property_documentation(clazz, attribute_name, api_reference)
			"signal":
				if attribute_name.empty():
					message = display_signals_documentation(clazz, api_reference)
				else:
					message = display_signal_documentation(clazz, attribute_name, api_reference)
			"constant":
				if attribute_name.empty():
					message = display_constants_documentation(clazz, api_reference)
				else:
					message = display_constant_documentation(clazz, attribute_name, api_reference)
			"enum":
				if attribute_name.empty():
					message = display_enums_documentation(clazz, api_reference)
				else:
					message = display_enum_documentation(clazz, attribute_name, api_reference)
			_:
				message = display_class_documentation(clazz, api_reference)
	else:
		message = DiscordInteractionMessage.new()\
			.set_content("**Class name `%s` not found**" % clazz)
	
	interaction.reply(message)

# warning-ignore-all:return_value_discarded
# warning-ignore-all:integer_division

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
	load_godot_3_docs()
#	load_godot_4_docs()

func load_godot_3_docs() -> void:
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
	
func load_godot_4_docs() -> void:
	yield(godot_4.load("res://assets/documentation/godot-master"), "completed")

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

func display_class_documentation(
	clazz: String, api: GodotAPIReference, action: MessageAction
) -> void:
	
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
	
	action.add_embed(embed)
	
	var row := MessageActionRowBuilder.new()
	if class_reference.members.size() > 0:
		row.add_component(
			MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
			.with_custom_id("property").with_label("Properties")
		)
	if class_reference.methods.size() > 0:
		row.add_component(
			MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
			.with_custom_id("method").with_label("Methods")
		)
	if class_reference.signals.size() > 0:
		row.add_component(
			MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
			.with_custom_id("signal").with_label("Signals")
		)
	if class_reference.constants.size() > 0:
		row.add_component(
			MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
			.with_custom_id("constant").with_label("Constants")
		)
	if class_reference.constants.size() > 0:
		row.add_component(
			MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
			.with_custom_id("enum").with_label("Enums")
		)
	
	action.add_component(row)

func display_methods_documentation(
	clazz: String, api: GodotAPIReference, page: int, action: MessageAction
) -> int:
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	var total_methods: int = class_reference.methods.size()
	if total_methods == 0:
		action.set_content("**No methods in base `%s`**" % clazz_name)\
			.ephemeral(true)
	else:
		var methods: Array = class_reference.methods.values()
		
		var description: String = "`%s` class methods\n" % clazz_name
		var pages: int = total_methods / 5
		page = int(clamp(page, 0, pages))
		var offset: int = 5 * page
		var row := MessageActionRowBuilder.new()
		for i in range(min(total_methods, min(5, total_methods - offset))):
			var method: MethodAPIReference = methods[i + offset]
			# Arduino is the closest to highlight most of the method syntax
			description += str('```ino\n', method, '```')
			row.add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id(method.name).with_label(method.name)
			)
		
		action.add_embed(
			generate_class_embed(clazz_name, "#method-descriptions")\
			.set_title(clazz_name + " methods").set_description(description)
		).add_component(
			MessageActionRowBuilder.new().add_component(
				MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
				.with_custom_id("class").with_label("Overview")
			).add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id("previous").with_label("Previous")\
				.disabled(page == 0)
			).add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id("next").with_label("Next")\
				.disabled(page == pages)
			)
		).add_component(row)
		return page
	return 0

func display_method_documentation(
	clazz: String, method: String, api: GodotAPIReference,
	action: MessageAction
) -> void:
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	
	if class_reference.contains_method(method):
		var method_ref: MethodAPIReference = class_reference.get_method(method)
		action.add_embed(
			generate_class_embed(clazz_name, "#method-descriptions")\
			.set_title("%s.%s()" % [clazz_name, method_ref.name])\
			.set_description(method_ref.description)\
			.add_field("Declaration", str('```ino\n', method_ref, '```'))
		).add_component(
			MessageActionRowBuilder.new().add_component(
				MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
				.with_custom_id("method").with_label("Methods")
			)
		)
	else:
		action.set_content("**`%s` method not found in base `%s`**" % [
			method, clazz_name
		]).ephemeral(true)

func display_properties_documentation(
	clazz: String, api: GodotAPIReference, page: int, action: MessageAction
) -> int:
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	var total_members: int = class_reference.members.size()
	if total_members == 0:
		action.set_content("**No properties in base `%s`**" % clazz_name)\
			.ephemeral(true)
	else:
		var members: Array = class_reference.members.values()
		var description: String = "`%s` class properties\n" % clazz_name
		var pages: int = total_members / 5
		page = int(clamp(page, 0, pages))
		var offset: int = 5 * page
		var row := MessageActionRowBuilder.new()
		for i in range(min(total_members, min(5, total_members - offset))):
			var member: MemberAPIReference = members[i + offset]
			description += str('```ino\n', member, '```')
			row.add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id(member.name).with_label(member.name)
			)
		
		action.add_embed(
			generate_class_embed(clazz_name, "#property-descriptions")\
			.set_title(clazz_name + " properties")\
			.set_description(description)
		).add_component(
			MessageActionRowBuilder.new().add_component(
				MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
				.with_custom_id("class").with_label("Overview")
			).add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id("previous").with_label("Previous")\
				.disabled(page == 0)
			).add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id("next").with_label("Next")\
				.disabled(page == pages)
			)
		).add_component(row)
		return page
	return 0

func display_property_documentation(
	clazz: String, property: String, api: GodotAPIReference,
	action: MessageAction
) -> void:
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	
	if class_reference.contains_member(property):
		var property_ref: MemberAPIReference = class_reference.get_member(property)
		action.add_embed(
			generate_class_embed(clazz_name, "#property-descriptions")\
			.set_title("%s.%s" % [clazz_name, property_ref.name])\
			.set_description(property_ref.description)\
			.add_field("Declaration", str('```ino\n', property_ref, '```'))
		).add_component(
			MessageActionRowBuilder.new().add_component(
				MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
				.with_custom_id("property").with_label("Properties")
			)
		)
	else:
		action.set_content("**`%s` property not found in base `%s`**" % [
			property, clazz_name
		]).ephemeral(true)

func display_signals_documentation(
	clazz: String, api: GodotAPIReference, page: int, action: MessageAction
) -> int:
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	var total_signals: int = class_reference.signals.size()
	if class_reference.signals.size() == 0:
		action.set_content("**No signals in base `%s`**" % clazz_name)\
			.ephemeral(true)
	else:
		var signals: Array = class_reference.signals.values()
		var description: String = "`%s` class signals\n" % clazz_name
		var pages: int = total_signals / 5
		page = int(clamp(page, 0, pages))
		var offset: int = 5 * page
		var row := MessageActionRowBuilder.new()
		for i in range(min(total_signals, min(5, total_signals - offset))):
			var signal_ref: SignalAPIReference = signals[i + offset]
			# Yeah whatever, haskell time
			description += str('```hs\n', signal_ref, '```')
			row.add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id(signal_ref.name).with_label(signal_ref.name)
			)
		
		action.add_embed(
			generate_class_embed(clazz_name, "#signals")\
			.set_title(clazz_name + " singals")\
			.set_description(description)
		).add_component(
			MessageActionRowBuilder.new().add_component(
				MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
				.with_custom_id("class").with_label("Overview")
			).add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id("previous").with_label("Previous")\
				.disabled(page == 0)
			).add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id("next")\
				.with_label("Next")\
				.disabled(page == pages)
			)
		).add_component(row)
		return page
	return 0


func display_signal_documentation(
	clazz: String, signal_name: String, api: GodotAPIReference,
	action: MessageAction
) -> void:
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	
	if class_reference.contains_signal(signal_name):
		var signal_ref: SignalAPIReference = class_reference.get_signal(signal_name)
		action.add_embed(
			generate_class_embed(clazz_name, "#signals")\
			.set_title("%s [signal] %s" % [clazz_name, signal_ref.name])\
			.set_description(signal_ref.description)\
			.add_field("Declaration", str('```hs\n', signal_ref, '```'))
		).add_component(
			MessageActionRowBuilder.new().add_component(
				MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
				.with_custom_id("signal").with_label("Signals")
			)
		)
	else:
		action.set_content("**`%s` signal not found in base `%s`**" % [
			signal_name, clazz_name
		]).ephemeral(true)

func display_constants_documentation(
	clazz: String, api: GodotAPIReference, page: int, action: MessageAction
) -> int:
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	var total_constants: int = class_reference.constants.size()
	if total_constants == 0:
		action.set_content("**No constants in base `%s`**" % clazz_name)\
			.ephemeral(true)
	else:
		var constants: Array = class_reference.constants.values()
		var description: String = "`%s` class constants\n" % clazz_name
		var pages: int = total_constants / 5
		page = int(clamp(page, 0, pages))
		var offset: int = 5 * page
		var row := MessageActionRowBuilder.new()
		for i in range(min(total_constants, min(5, total_constants - offset))):
			var constant: ConstantAPIReference = constants[i + offset]
			description += str('```ino\n', constant, '```')
			row.add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id(constant.name).with_label(constant.name)
			)
		
		action.add_embed(
			generate_class_embed(clazz_name, "#constants")\
			.set_title(clazz_name + " constants")\
			.set_description(description)
		).add_component(
			MessageActionRowBuilder.new().add_component(
				MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
				.with_custom_id("class").with_label("Overview")
			).add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id("previous").with_label("Previous")\
				.disabled(page == 0)
			).add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id("next").with_label("Next")\
				.disabled(page == pages)
			)
		).add_component(row)
		return page
	return 0


func display_constant_documentation(
	clazz: String, constant: String, api: GodotAPIReference,
	action: MessageAction
) -> void:
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	
	if class_reference.contains_constant(constant):
		var const_ref: ConstantAPIReference = class_reference.get_constant(constant)
		action.add_embed(
			generate_class_embed(clazz_name, "#constants")\
			.set_title("%s.%s" % [clazz_name, const_ref.name])\
			.set_description(const_ref.description)\
			.add_field("Declaration", str('```hs\n', const_ref, '```'))
		).add_component(
			MessageActionRowBuilder.new().add_component(
				MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
				.with_custom_id("constant").with_label("Constants")
			)
		)
	else:
		action.set_content("**`%s` constant not found in base `%s`**" % [
			constant, clazz_name
		]).ephemeral(true)

func display_enums_documentation(
	clazz: String, api: GodotAPIReference, page: int, action: MessageAction
) -> int:
	var class_reference: ClassAPIReference = api.get_class_reference(clazz)
	var clazz_name: String = class_reference.name
	var total_enums: int = class_reference.enums.size()
	if class_reference.enums.size() == 0:
		action.set_content("**No enums in base `%s`**" % clazz_name)\
			.ephemeral(true)
	else:
		var enums: Array = class_reference.enums.values()
		var description: String = "`%s` class enums\n" % clazz_name
		var pages: int = total_enums / 5
		page = int(clamp(page, 0, pages))
		var offset: int = 5 * page
		var row := MessageActionRowBuilder.new()
		for i in range(min(total_enums, min(5, total_enums - offset))):
			var enum_ref: EnumAPIReference = enums[i + offset]
			description += str('```swift\n', enum_ref.name, '```')
			row.add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id(enum_ref.name).with_label(enum_ref.name)
			)
		
		action.add_embed(
			generate_class_embed(clazz_name, "#enumerations")\
			.set_title(clazz_name + " enums")\
			.set_description(description)
		).add_component(
			MessageActionRowBuilder.new().add_component(
				MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
				.with_custom_id("class").with_label("Overview")
			).add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id("previous").with_label("Previous")\
				.disabled(page == 0)
			).add_component(
				MessageButtonBuilder.new(MessageButton.Styles.SECONDARY)\
				.with_custom_id("next").with_label("Next")\
				.disabled(page == pages)
			)
		).add_component(row)
		return page
	return 0


func display_enum_documentation(
	clazz: String, enum_name: String, api: GodotAPIReference,
	action: MessageAction
) -> void:
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
		action.add_embed(
			generate_class_embed(clazz_name, "#enumerations")\
			.set_title("%s.%s" % [clazz_name, enum_ref.name])\
			.set_description(description)\
		).add_component(
			MessageActionRowBuilder.new().add_component(
				MessageButtonBuilder.new(MessageButton.Styles.PRIMARY)\
				.with_custom_id("enum").with_label("Enums")
			)
		)
	else:
		action.set_content("**`%s` enum not found in base `%s`**" % [
			enum_name, clazz_name
		]).ephemeral(true)

func display_attribute(
	api_reference: GodotAPIReference, clazz: String,
	attribute: String, attribute_name: String, page: int,
	action: MessageAction
) -> int:
	match attribute:
		"method":
			if attribute_name.empty():
				page = display_methods_documentation(clazz, api_reference, page, action)
			else:
				display_method_documentation(clazz, attribute_name, api_reference, action)
		"property":
			if attribute_name.empty():
				page = display_properties_documentation(clazz, api_reference, page, action)
			else:
				display_property_documentation(clazz, attribute_name, api_reference, action)
		"signal":
			if attribute_name.empty():
				page = display_signals_documentation(clazz, api_reference, page, action)
			else:
				display_signal_documentation(clazz, attribute_name, api_reference, action)
		"constant":
			if attribute_name.empty():
				page = display_constants_documentation(clazz, api_reference, page, action)
			else:
				display_constant_documentation(clazz, attribute_name, api_reference, action)
		"enum":
			if attribute_name.empty():
				page = display_enums_documentation(clazz, api_reference, page, action)
			else:
				display_enum_documentation(clazz, attribute_name, api_reference, action)
		_:
			display_class_documentation(clazz, api_reference, action)
		
	yield(action.submit(), "completed")
	return page

func _on_slash_command(command: DiscordSlashCommand) -> void:
	var clazz: String = command.get_string_option("class_name")
	var attribute: String = command.get_string_option("attribute")
	var attribute_name: String = command.get_string_option("attribute_name")
	var page: int = command.get_integer_option("page")
	var for_godot_4: bool = command.get_boolean_option("godot_4")
	
#	var api_reference: GodotAPIReference = godot_4 if for_godot_4 else godot_3
	var api_reference: GodotAPIReference = godot_3
	
	var action: MessageAction = command.create_reply()
	
	if attribute.empty() and not attribute_name.empty():
		action.set_content(
			"**`attribute` option must be set when `attribute_name` is provided**"
		)
	
	elif api_reference.has_class(clazz):
		yield(display_attribute(
			api_reference, clazz, attribute,
			attribute_name, page, action
		), "completed")
	else:
		action.set_content("**Class name `%s` not found**" % clazz)\
			.ephemeral(true).submit()
	
	
	var response: Message = yield(command.fetch_response(), "completed")
	if not response:
		return

	var awaiter := await_components(response.id, 30_000)
	
	var previous: String
	while yield(awaiter.wait(), "completed"):
		awaiter.reset()
		var event := awaiter.get_event()
		var custom_id: String = event.data.custom_id
		action = event.update_message()
		match custom_id:
			"next":
				page += 1
			"previous":
				page -= 1
			"class":
				attribute = ""
				attribute_name = ""
			"method", "property", "signal", "constant", "enum":
				if previous != custom_id:
					page = 0
				attribute = custom_id
				attribute_name = ""
				previous = attribute
			_:
				attribute_name = custom_id
		
		page = yield(display_attribute(
			api_reference, clazz, attribute,
			attribute_name, page, action
		), "completed")
	
	command.edit_response().clear_components().submit()

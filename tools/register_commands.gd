tool
extends EditorScript

const APPLICATION_ID: int = 948797584305164359

func create_docs_command() -> ApplicationCommandBuilder:
	return ApplicationCommandBuilder.new("docs")\
		.with_description("Godot documentation")\
		.add_option(
			ApplicationCommandStringOption.new("class_name")\
			.with_description("Class name").is_required(true)
		).add_option(
			ApplicationCommandStringOption.new("attribute")\
			.with_description("Class attribute type")\
			.is_required(false)\
			.add_choice("Method", "method")\
			.add_choice("Property", "property")\
			.add_choice("Signal", "signal")\
			.add_choice("Constant", "constant")\
			.add_choice("Enum", "enum")
		).add_option(
			ApplicationCommandStringOption.new("attribute_name")\
			.with_description("Attribute name").is_required(false)
		).add_option(
			ApplicationCommandBoolOption.new("godot_4")\
			.with_description("Godot 4 docs").is_required(false)
		)

func create_execute_command() -> ApplicationCommandBuilder:
	return ApplicationCommandBuilder.new("execute")\
		.with_description("Execute a GDScript expression").add_option(
			ApplicationCommandStringOption.new("expression")\
			.with_description("The expression to execute")\
			.is_required(true)
		)

func create_ping_command() -> ApplicationCommandBuilder:
	return ApplicationCommandBuilder.new("ping")\
		.with_description("Display bot's ping")

func _run() -> void:
	if not ProjectSettings.has_setting("bot/token"):
		ProjectSettings.set_setting("bot/token", "")
		
	var token: String = ProjectSettings.get_setting("bot/token")
	if token.empty():
		printerr('"bot/token" setting is not set')
		return
	
	print("Register Godette commands" )
	
	var rest := DiscordRESTAdapter.new(token)
	
	var commands: Array = yield(
		rest.application.bulk_overwrite_global_application_commands(
			APPLICATION_ID,
			[
				create_docs_command().build(),
				create_execute_command().build(),
				create_ping_command().build()
			]
		), "completed")
	
	assert(commands.size() != 0)
	print("Done")

class_name ExpressionCommandExecutor extends ApplicationCommandExecutor

var singletons: Dictionary = {
	Engine = EngineWrapper.new()
}

var expression: Expression = Expression.new()

func _on_slash_command(command: DiscordSlashCommand) -> void:
	var expression_string: String = command.get_string_option("expression")
	if expression.parse(expression_string, singletons.keys()) != OK:
		var reply: String = "```diff\n"
		reply += "- " + expression.get_error_text()
		reply += "\n```"
		command.create_reply(reply).submit()
		return
	
	var formatting = ""
	var result: String = str(expression.execute(singletons.values(), null, false))
	if expression.has_execute_failed():
		formatting = "diff"
		result = "- " + expression.get_error_text()
	elif result.length() > MessageAction.MAX_CONTENT_LENGTH - 7 - formatting.length():
		formatting = "diff"
		result = "- " + "Output is too big"
	
	if result.empty():
		formatting = "diff"
		result = "! Empty output"
	
	
	command.create_reply(
		"```" + formatting + "\n"
		+ result
		+ "```"
	).ephemeral(true).submit()

class_name ExpressionCommandExecutor extends ApplicationCommandExecutor

var singletons: Dictionary = {
	Engine = EngineWrapper.new()
}

var expression: Expression = Expression.new()

func interact(interaction: DiscordInteraction) -> void:
	var expression_string: String = interaction.get_string_option_value(0)
	if expression.parse(expression_string, singletons.keys()) != OK:
		var reply: String = "```diff\n"
		reply += "-" + expression.get_error_text()
		reply += "\n```"
		interaction.reply(
			DiscordInteractionMessage.new().set_content(reply)
		)
		return
	
	var formatting = ""
	var result: String = str(expression.execute(singletons.values(), null, false))
	if expression.has_execute_failed():
		formatting = "diff"
		result = "-" + expression.get_error_text()
	
	if result.empty():
		formatting = "diff"
		result = "! Empty"
	
	interaction.reply(
		DiscordInteractionMessage.new().set_content(
			"```" + formatting + "\n"
			+ result
			+ "```"
		)
	)

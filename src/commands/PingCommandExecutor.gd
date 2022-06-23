class_name PingCommandExecutor extends ApplicationCommandExecutor

var client_ref: WeakRef

func _init(client: DiscordClient) -> void:
	client_ref = weakref(client)

func interact(interaction: DiscordInteraction) -> void:
	var client: DiscordClient = client_ref.get_ref()
	
	var content: String = "**Gateway ping:** %d" % client.get_ping()
	
	yield(interaction.reply(
		DiscordInteractionMessage.new().set_content(content)
	), "completed")
	
	yield(interaction.edit_response(
		MessageEditData.new().set_content(
			content
			+ "\n**REST ping:** %d" % client.rest.requester.get_last_latency_ms()
		)
	), "completed")

class_name PingCommandExecutor extends ApplicationCommandExecutor

var client_ref: WeakRef

func _init(client: DiscordClient) -> void:
	client_ref = weakref(client)

func _on_slash_command(command: DiscordSlashCommand) -> void:
	var client: DiscordClient = client_ref.get_ref()
	
	var content: String = "**Gateway:** `%d ms`" % client.get_ping()
	
	yield(command.create_reply(content).submit(), "completed")
	
	yield(command.edit_response().set_content(
		content
		+ "\n**REST:** `%d ms`" % client.rest.requester.get_last_latency_ms()
	).submit(), "completed")

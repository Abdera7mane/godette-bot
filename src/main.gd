extends SceneTree

const Bot: Script = preload("res://src/bot.gd")

var bot: Bot = Bot.new()

func _initialize() -> void:
	VisualServer.render_loop_enabled = false
	Physics2DServer.set_active(false)
	PhysicsServer.set_active(false)
	
	auto_accept_quit = false
	
	bot.client.connect("disconnected", self, "notification", [NOTIFICATION_WM_QUIT_REQUEST])
	root.add_child(bot)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_QUIT_REQUEST:
			if bot.client.is_client_connected():
				bot.client.logout()
				yield(bot.client, "disconnected")
			print("Bot offline. Quitting...")
			quit()

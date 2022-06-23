# warning-ignore-all:return_value_discarded

extends Node

var cmd_arg: Dictionary
var client: DiscordClient

func _init() -> void:
	parse_cmdline_args()
	
	client = DiscordClient.new(get_token(), GatewayIntents.ALL)
	client.connect("client_ready", self, "_on_ready")
	
	client.register_application_command_executor("docs", DocsCommandExecutor.new())
	client.register_application_command_executor("execute", ExpressionCommandExecutor.new())
	client.register_application_command_executor("ping", PingCommandExecutor.new(client))
	
	add_child(client)

func _ready() -> void:
	client.login()

func parse_cmdline_args() -> void:
	var regex: RegEx = RegEx.new()
	# warning-ignore:return_value_discarded
	regex.compile("--(?<key>\\w+)=\"?(?<value>.+)\"?")
	for arg in OS.get_cmdline_args():
		var result: RegExMatch = regex.search(arg)
		if result:
			cmd_arg[result.get_string("key")] = str2var(result.get_string("value"))

func get_token() -> String:
	return cmd_arg.get("token", "")

func _on_ready(user: User) -> void:
	print("Bot is ready !")
	print("logged as: ", user.get_tag())

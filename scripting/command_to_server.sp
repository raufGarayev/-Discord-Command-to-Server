#pragma semicolon 1

#include <discord>
#include <sourcemod>

ConVar g_cvBotToken, g_cvOutputChannel, g_cvServerId;
char   g_sBotToken[128], g_sOutputChannel[128], g_sServerId[128];

public Plugin myinfo =
{
	name        = "[Discord] Command to Server",
	author      = "GARAYEV",
	description = "Send command from discord to server",
	version     = "1.2",
	url         = "www.garayev-sp.ru & Discord: GARAYEV#9999"
};

DiscordBot gBot;

public void OnPluginStart()
{
	g_cvBotToken = CreateConVar("sm_cts_bot_token", "", "Bot token | Токен Бота");
	GetConVarString(g_cvBotToken, g_sBotToken, sizeof(g_sBotToken));
	g_cvOutputChannel = CreateConVar("sm_cts_output_channel", "", "Channel id to use for commands| Айди канала для использования команд");
	GetConVarString(g_cvOutputChannel, g_sOutputChannel, sizeof(g_sOutputChannel));
	g_cvServerId = CreateConVar("sm_cts_server_id", "", "ID of your Server | Айди дискорд сервера");
	GetConVarString(g_cvServerId, g_sServerId, sizeof(g_sServerId));
	AutoExecConfig(true, "command_to_server");

	HookConVarChange(g_cvBotToken, OnCtsSettingsChanged);
	HookConVarChange(g_cvOutputChannel, OnCtsSettingsChanged);
	HookConVarChange(g_cvServerId, OnCtsSettingsChanged);
}

public int OnCtsSettingsChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == g_cvBotToken)
	{
		strcopy(g_sBotToken, sizeof(g_sBotToken), newValue);
	}
	else if (convar == g_cvOutputChannel)
	{
		strcopy(g_sOutputChannel, sizeof(g_sOutputChannel), newValue);
	}
	else if (convar == g_cvServerId)
	{
		strcopy(g_sServerId, sizeof(g_sServerId), newValue);
	}
}

public void OnConfigsExecuted()
{
	if (!gBot)
	{
		gBot = new DiscordBot(g_sBotToken);

		gBot.GetGuilds(GuildList);
	}
}

public void GuildList(DiscordBot bot, char[] id, char[] name, char[] icon, bool owner, int permissions, any data)
{
	if (StrEqual(id, g_sServerId, false))
		gBot.GetGuildChannels(id, ChannelList);
}

public void ChannelList(DiscordBot bot, char[] guild, DiscordChannel Channel, any data)
{
	char id[32];
	Channel.GetID(id, sizeof(id));

	if (Channel.IsText && StrEqual(id, g_sOutputChannel))
	{
		gBot.SendMessage(Channel, "READY FOR COMMANDS");

		gBot.StartListeningToChannel(Channel, OnMessage);
	}
}

public void OnMessage(DiscordBot Bot, DiscordChannel Channel, DiscordMessage message)
{
	if (message.GetAuthor().IsBot())
		return;

	char sMessage[2048];
	message.GetContent(sMessage, sizeof(sMessage));
	char sBuffer[3096];

	ServerCommandEx(sBuffer, sizeof(sBuffer), sMessage);

	gBot.SendMessageToChannelID(g_sOutputChannel, sBuffer);
}

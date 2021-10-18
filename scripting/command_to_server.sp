#pragma semicolon 1

#include <sourcemod>
#include <discord>

ConVar g_cvBotToken, g_cvCmdChannel, g_cvOutputChannel, g_cvServerId;
char g_sBotToken[128], g_sCmdChannel[128], g_sOutputChannel[128], g_sServerId[128];

public Plugin myinfo = 
{
	name = "[Discord] Command to Server",
	author = "GARAYEV",
	description = "Send command from discord to server",
	version = "1.0",
	url = "www.garayev-sp.ru & Discord: GARAYEV#9999"
};

DiscordBot gBot;

public void OnPluginStart() 
{
    g_cvBotToken = CreateConVar("sm_cts_bot_token", "", "Bot token | Токен Бота");
    GetConVarString(g_cvBotToken, g_sBotToken, sizeof(g_sBotToken));
    g_cvCmdChannel = CreateConVar("sm_cts_command_channel_id", "", "Channel id to write commands | Айди канала для отправки сообщений");
    GetConVarString(g_cvCmdChannel, g_sCmdChannel, sizeof(g_sCmdChannel));
    g_cvOutputChannel = CreateConVar("sm_cts_output_channel", "", "Channel id where bot will send output of commands | Айди канала для получения результата от команд");
    GetConVarString(g_cvOutputChannel, g_sOutputChannel, sizeof(g_sOutputChannel));
    g_cvServerId = CreateConVar("sm_cts_server_id", "", "ID of your Server | Айди дискорд сервера");
    GetConVarString(g_cvServerId, g_sServerId, sizeof(g_sServerId));
    AutoExecConfig(true, "command_to_server");

    HookConVarChange(g_cvBotToken, OnCtsSettingsChanged);
    HookConVarChange(g_cvCmdChannel, OnCtsSettingsChanged);
    HookConVarChange(g_cvOutputChannel, OnCtsSettingsChanged);
}

public int OnCtsSettingsChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
    if(convar == g_cvBotToken)
    {
        strcopy(g_sBotToken, sizeof(g_sBotToken), newValue);
    }
    else if(convar == g_cvCmdChannel)
    {
        strcopy(g_sCmdChannel, sizeof(g_sCmdChannel), newValue);
    }
    else if(convar == g_cvOutputChannel)
    {
        strcopy(g_sOutputChannel, sizeof(g_sOutputChannel), newValue);
    }
    else if(convar == g_cvServerId)
    {
        strcopy(g_sServerId, sizeof(g_sServerId), newValue);
    }
}

public void OnAllPluginsLoaded() 
{
    gBot = new DiscordBot(g_sBotToken);
    
    gBot.GetGuilds(GuildList);
}

public void GuildList(DiscordBot bot, char[] id, char[] name, char[] icon, bool owner, int permissions, any data) 
{
    if(StrEqual(id, g_sServerId, false))
	    gBot.GetGuildChannels(id, ChannelList);
}

public void ChannelList(DiscordBot bot, char[] guild, DiscordChannel Channel, any data) 
{
	char id[32];
	Channel.GetID(id, sizeof(id));
		
	if(Channel.IsText && StrEqual(id, g_sCmdChannel)) 
    {
		gBot.SendMessage(Channel, "READY FOR COMMANDS");
            	
		gBot.StartListeningToChannel(Channel, OnMessage);
	}
}

public void OnMessage(DiscordBot Bot, DiscordChannel Channel, DiscordMessage message) 
{
    char sMessage[2048];
    message.GetContent(sMessage, sizeof(sMessage));
    char sBuffer[3096];
	
    ServerCommandEx(sBuffer, sizeof(sBuffer), sMessage);

    gBot.SendMessageToChannelID(g_sOutputChannel, sBuffer);
}
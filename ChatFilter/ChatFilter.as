void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("kek");
	g_Module.ScriptInfo.SetContactInfo("https://github.com/kekekekkek/ChatFilter");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
}

void PlayerSay(CBaseEntity@ pEntity, string strMsg)
{
	NetworkMessage NetMsg(MSG_ALL, NetworkMessages::NetworkMessageType(74)); //SayText
	
	NetMsg.WriteByte(pEntity.entindex());
	NetMsg.WriteByte(2); //CLASS_PLAYER
	NetMsg.WriteString("" + pEntity.pev.netname + ": " + strMsg + "\n");
	
    NetMsg.End();
}

void PlayerSayTeam(CBaseEntity@ pEntity, string strMsg)
{
	for (int i = 0; i < g_Engine.maxClients + 1; i++)
	{
		edict_t@ pCurEdict = g_EngineFuncs.PEntityOfEntIndex(i);
		CBaseEntity@ pCurEntity = g_EntityFuncs.Instance(pCurEdict);
		
		if (pEntity.IRelationship(pCurEntity) == R_AL)
		{
			NetworkMessage NetMsg(MSG_ONE, NetworkMessages::NetworkMessageType(74), pCurEdict); //SayText
		
			NetMsg.WriteByte(pEntity.entindex());
			NetMsg.WriteByte(2); //CLASS_PLAYER
			NetMsg.WriteString("(TEAM) " + pEntity.pev.netname + ": " + strMsg + "\n");
			
			NetMsg.End();
		}
	}
}

bool IsSayTeam(ClientSayType cstSayType)
{
	if (cstSayType == CLIENTSAY_SAYTEAM)
		return true;
		
	return false;
}

array<string> LoadBadWordsFromFile()
{
	array<string> strBadWords = {};
	File@ fFile = g_FileSystem.OpenFile("scripts/plugins/ChatFilter/BadWords.txt", OpenFile::READ);
	
	if (fFile.IsOpen())
	{
		while (!fFile.EOFReached())
		{
			string strCurLine = "";
			fFile.ReadLine(strCurLine);
			
			strBadWords.insertLast(strCurLine);
		}
		
		fFile.Close();
	}
	
	return strBadWords;
}

bool IsBadWords(string strText, array<string> strBadWords)
{
	int iArraySize = strBadWords.length();
	
	for (int i = 0; i < iArraySize; i++)
	{
		if (strText.Find(strBadWords[i]) != String::INVALID_INDEX)
			return true;
	}
	
	return false;
}

string Filter(string strText, array<string> strBadWords)
{
	string strReplace = "";
	int iArraySize = strBadWords.length();
	
	for (int a = 0; a < iArraySize; a++)
	{
		int iTextLength = strBadWords[a].Length();
	
		for (int b = 0; b < iTextLength; b++)
			strReplace += "*";
		
		strText = strText.Replace(strBadWords[a], strReplace);
		strReplace.Clear();
	}
	
	return strText;
}

HookReturnCode ClientSay(SayParameters@ pSayParam)
{
	string strMsg = pSayParam.GetCommand();
	CBasePlayer@ pPlayer = pSayParam.GetPlayer();
	ClientSayType cstSayType = pSayParam.GetSayType();
	array<string> strGetBadWords = LoadBadWordsFromFile();

	if (IsBadWords(strMsg, strGetBadWords))
	{
		string strFilteredMsg = Filter(strMsg, strGetBadWords);
		pSayParam.ShouldHide = true;
		
		if (!IsSayTeam(cstSayType))
			PlayerSay(pPlayer, strFilteredMsg);
		else
			PlayerSayTeam(pPlayer, strFilteredMsg);
		
		return HOOK_HANDLED;
	}
	
	return HOOK_CONTINUE;
}
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
		if (strText.ToLowercase().Find(strBadWords[i].ToLowercase()) != String::INVALID_INDEX)
			return true;
	}
	
	return false;
}

string Filter(string strText, array<string> strBadWords)
{
	string strReplace = "";
	string strGetReplace = "";
	string strGetText = strText;
	
	int iArraySize = strBadWords.length();
	
	for (int a = 0; a < iArraySize; a++)
	{
		uint uFind = strText.ToLowercase().Find(strBadWords[a].ToLowercase());
		
		if (uFind != String::INVALID_INDEX)
		{
			int iTextLength = strBadWords[a].Length();
	
			for (int b = 0; b < iTextLength; b++)
				strReplace += "*";
		
			for (int b = uFind; b < (uFind + iTextLength); b++)
				strGetReplace += strText.opIndex(b);
			
			a = 0;
			strText = strText.Replace(strGetReplace, strReplace);
		}
		
		strReplace.Clear();
		strGetReplace.Clear();
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
		
		(!IsSayTeam(cstSayType) ? PlayerSay(pPlayer, strFilteredMsg) : PlayerSayTeam(pPlayer, strFilteredMsg));
		return HOOK_HANDLED;
	}
	
	return HOOK_CONTINUE;
}
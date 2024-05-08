array<string> strGetBadWords = {};
uint uSaveFileSize = 0, uCurFileSize = 0;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("kek");
	g_Module.ScriptInfo.SetContactInfo("https://github.com/kekekekkek/ChatFilter");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
}

void PlayerSay(CBaseEntity@ pEntity, string strMsg)
{
	NetworkMessage NetMsg(MSG_ALL, NetworkMessages::NetworkMessageType(74));
	
	NetMsg.WriteByte(pEntity.entindex());
	NetMsg.WriteByte(2);
	NetMsg.WriteString(("" + pEntity.pev.netname + ": " + strMsg + "\n"));
	
    NetMsg.End();
}

void PlayerSayTeam(CBaseEntity@ pEntity, string strMsg)
{
	for (int i = 1; i <= g_Engine.maxClients; i++)
	{
		edict_t@ pCurEdict = g_EngineFuncs.PEntityOfEntIndex(i);
		CBaseEntity@ pCurEntity = g_EntityFuncs.Instance(pCurEdict);
		
		if (pEntity.IRelationship(pCurEntity) == R_AL)
		{
			NetworkMessage NetMsg(MSG_ONE, NetworkMessages::NetworkMessageType(74), pCurEdict);
		
			NetMsg.WriteByte(pEntity.entindex());
			NetMsg.WriteByte(2);
			NetMsg.WriteString(("(TEAM) " + pEntity.pev.netname + ": " + strMsg + "\n"));
			
			NetMsg.End();
		}
	}
}

bool IsSayTeam(ClientSayType cstSayType)
{
	return (cstSayType == CLIENTSAY_SAYTEAM);
}

bool Is2Bytes(char chSymbol)
{
	return (chSymbol > 255);
}

uint GetFileSize(string strFileName)
{
	uint uFileSize = 0;
	File@ fFile = g_FileSystem.OpenFile(strFileName, OpenFile::READ);
	
	if (fFile !is null && fFile.IsOpen())
	{
		uFileSize = fFile.GetSize();
		fFile.Close();
	}
		
	return uFileSize;
}

array<string> LoadBadWordsFromFile()
{
	array<string> strBadWords = {};
	File@ fFile = g_FileSystem.OpenFile("scripts/plugins/ChatFilter/BadWords.txt", OpenFile::READ);
	
	if (fFile !is null && fFile.IsOpen())
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
	for (uint i = 0; i < strBadWords.length(); i++)
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
	
	for (uint a = 0; a < strBadWords.length(); a++)
	{
		uint uFind = strText.ToLowercase().Find(strBadWords[a].ToLowercase());
		
		if (uFind != String::INVALID_INDEX)
		{
			int iTextLength = strBadWords[a].Length();
	
			for (int b = 0; b < iTextLength; b++)
			{
				if (Is2Bytes(strText[b]))
					b++;
					
				if (b >= iTextLength)
					break;
				
				strReplace += "*";
			}
		
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
	
	uCurFileSize = GetFileSize("scripts/plugins/ChatFilter/BadWords.txt");
	
	if (uSaveFileSize != uCurFileSize 
		|| strGetBadWords.length() <= 0)
	{
		uSaveFileSize = uCurFileSize;
		strGetBadWords = LoadBadWordsFromFile();
	}

	if (IsBadWords(strMsg, strGetBadWords))
	{
		string strFilteredMsg = Filter(strMsg, strGetBadWords);
		pSayParam.ShouldHide = true;
		
		(!IsSayTeam(pSayParam.GetSayType()) ? PlayerSay(pPlayer, strFilteredMsg) : PlayerSayTeam(pPlayer, strFilteredMsg));
		return HOOK_HANDLED;
	}
	
	return HOOK_CONTINUE;
}
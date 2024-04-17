void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("kek");
	g_Module.ScriptInfo.SetContactInfo("https://github.com/kekekekkek/ChatFilter");

	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);

	LoadBadWordsFromFile();
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
	for (int i = 1; i <= g_Engine.maxClients; i++)
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

array<string> BadWords;

void MapActivate()
{
	LoadBadWordsFromFile();
}

void LoadBadWordsFromFile()
{
	BadWords.resize(0);

	File@ fFile = g_FileSystem.OpenFile("scripts/plugins/ChatFilter/BadWords.txt", OpenFile::READ);

	if (fFile !is null && fFile.IsOpen())
	{
		while (!fFile.EOFReached())
		{
			string strCurLine = "";
			fFile.ReadLine(strCurLine);

			if( strCurLine.Length() < 1 || strCurLine.StartsWith( '//' ) )
				continue;

			BadWords.insertLast(strCurLine);
		}

		fFile.Close();
	}
}

bool IsBadWords(string strText)
{
	int iArraySize = BadWords.length();

	for (int i = 0; i < iArraySize; i++)
	{
		if (strText.ToLowercase().Find(BadWords[i].ToLowercase()) != String::INVALID_INDEX)
			return true;
	}

	return false;
}

string Filter(string strText)
{
	string strReplace = "";
	string strGetReplace = "";

	int iArraySize = BadWords.length();

	for (int a = 0; a < iArraySize; a++)
	{
		uint uFind = strText.ToLowercase().Find(BadWords[a].ToLowercase());

		if (uFind != String::INVALID_INDEX)
		{
			int iTextLength = BadWords[a].Length();

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
	if( BadWords.length() < 1 || pPlayer is null || pSayParam.ShouldHide )
		return HOOK_CONTINUE;

	string strMsg = pSayParam.GetCommand();
	CBasePlayer@ pPlayer = pSayParam.GetPlayer();
	ClientSayType cstSayType = pSayParam.GetSayType();

	if (IsBadWords(strMsg))
	{
		string strFilteredMsg = Filter(strMsg);
		pSayParam.ShouldHide = true;

		(!IsSayTeam(cstSayType) ? PlayerSay(pPlayer, strFilteredMsg) : PlayerSayTeam(pPlayer, strFilteredMsg));
		return HOOK_HANDLED;
	}

	return HOOK_CONTINUE;
}
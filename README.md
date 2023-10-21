# ChatFilter
`ChatFilter` is a simple plugin that will allow you to avoid unnecessary problems when communicating with toxic players.<br>The task of this plugin is to censor incoming messages if they contain obscene words.

# Installation
Installing the plugin consists of several steps:
1. Download this plugin;
2. Open the `..\Sven Co-op\svencoop_addon\scripts\plugins` directory and place the `ChatFilter` folder there;
3. Next, go to the `..\Sven Co-op\svencoop` folder and find there the text file `default_plugins.txt`;
4. Open this file and paste the following text into it:
```
	"plugin"
	{
		"name" "ChatFilter"
		"script" "ChatFilter/ChatFilter"
	}
```
5. Next, navigate to the `..\Sven Co-op\svencoop_addon\scripts\plugins\ChatFilter` directory;
6. Open the `BadWords.txt` file and write the words you want to censor in it. For example, it could be the following words:
```
fuck
bitch
gay
shit
nigg
whore
slut
faggot
bastard
asshole
dafaq
nerd
```
You can add words in any language (I only tested two languages).<br><br>
**REMEMBER**: The `LoadBadWordsFromFile` function reads the file line by line, so we need a one-line indent between each new word in the `BadWords.txt` file.<br>
**REMEMBER**: The `Filter` function is case-sensitive when replacing words. This should be taken into account if you need to filter the same word in different cases.<br>
**REMEMBER**: Sometimes, the `Filter` function may replace a 5-character word with a 10-character string consisting of asterisks `*`. This happens because some characters are encoded in a two-byte encoding.<br>
**REMEMBER**: Also, reading an empty `BadWords.txt` file and filling it out incorrectly can lead to unpredictable situations.<br>
**REMEMBER**: And also, if the `BadWords.txt` file is missing, this can also lead to unpredictable situations (I haven't tested it).<br>
**REMEMBER**: This plugin may conflict with the [ChatColors](https://github.com/wootguy/ChatColors) plugin.<br>

7. Now, after placing the plugin in the game files and after filling in the text file `BadWords.txt`, you can run the game and check the result.

# Screenshots
* Скриншот 1<br><br>
![Screenshot_1]()
* Скриншот 2<br><br>
![Screenshot_2]()
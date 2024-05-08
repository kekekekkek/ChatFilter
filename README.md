# ChatFilter
`ChatFilter.as` is a simple plugin that will allow you to avoid unnecessary problems when communicating with toxic players.<br>The task of this plugin is to censor incoming messages if they contain obscene words.

# Installation
Installing the plugin consists of several steps:
1. [Download](https://github.com/kekekekkek/ChatFilter/archive/refs/heads/main.zip) this plugin;
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
пидор
даун
конч
уебок
придурок
долбаеб
ебаный
нахуй
хуй
сука
блять
```
You can add words in any language (I only tested two languages).<br><br>
**REMEMBER**: The `LoadBadWordsFromFile` function reads the file line by line, so we need a one-line indent between each new word in the `BadWords.txt` file.<br>
**REMEMBER**: The `Filter` function is no longer case-sensitive when replacing words. The words `shiT`, `sHIt` or `Shit` will be recognized by the filter as one swear word, unless the player writes the word `sh1t` or something else. Therefore, in the file `BadWords.txt` you will need to write only one variation of this word. But even this can be easily bypassed by putting a single space character between the word, such as `s h i t`.<br>
**REMEMBER**: Added encoding definition. The `Filter` function will now replace a two-byte encoded character with a single asterisk `*` character.<br>
**REMEMBER**: This plugin may conflict with the [ChatColors](https://github.com/wootguy/ChatColors) plugin.<br>

7. Now, after placing the plugin in the game files and after filling in the text file `BadWords.txt`, you can run the game and check the result.

# Screenshots
* Screenshot 1<br><br>
![Screenshot_1](https://github.com/kekekekkek/ChatFilter/blob/main/Images/Screenshot_1.png)
* Screenshot 2<br><br>
![Screenshot_2](https://github.com/kekekekkek/ChatFilter/blob/main/Images/Screenshot_2.png)

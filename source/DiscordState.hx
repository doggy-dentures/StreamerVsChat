// package;

// import com.raidandfade.haxicord.DiscordClient;
// import haxe.io.Error;
// import sys.io.File;
// import haxe.io.Bytes;
// import flixel.util.FlxColor;
// import sys.net.Host;
// import sys.net.Socket;
// import sys.FileSystem;
// import flixel.text.FlxText;
// import flixel.FlxState;
// import flixel.FlxSprite;
// import flixel.FlxG;
// import flixel.util.FlxTimer;

// class DiscordState extends FlxState
// {
// 	public static var id:String;
// 	// public static var data:YTSetupData;
// 	public static var isConnected:Bool = false;

// 	var discordBot:DiscordClient;

// 	var log:FlxText = new FlxText();

// 	override function create()
// 	{
// 		super.create();

// 		Main.streamMethod = "discord";

// 		add(log);

// 		log.text = "Attempting to get YouTube video ID details...\n";

// 		if (!FileSystem.exists('scripts/setup-youtube.json'))
// 		{
// 			error("Can't find setup-youtube.json!");
// 			return;
// 		}

// 		var rawJson:String = File.getContent('scripts/setup-youtube.json');
// 		StringTools.trim(rawJson);
// 		// data = haxe.Json.parse(rawJson);

// 		// if (data == null || data.video_id == null)
// 		// {
// 		// 	error("setup-youtube.json is not formatted correctly!");
// 		// 	return;
// 		// }

// 		// id = StringTools.trim(data.video_id);

// 		// if (id == 'video_id_goes_here')
// 		// {
// 		// 	error("It doesn't seem like you've entered your YouTube stream video ID into setup-youtube.json!");
// 		// 	return;
// 		// }

// 		print("Attempting to connect to Septapus IRC...");

// 		discordBot = new DiscordClient("lol");

// 		discordBot.onReady = function(){trace("GET THAT SHIT");};
// 	}

// 	override function update(elapsed:Float)
// 	{
// 		super.update(elapsed);
// 	}

// 	function print(stuff:String)
// 	{
// 		log.text += stuff + "\n";
// 	}

// 	function error(stuff:String)
// 	{
// 		print(stuff);
// 		print("");
// 		print("Program will now halt.");
// 	}

// 	public static function tryRead()
// 	{
		
// 	}

// 	public static function getMatches(ereg:EReg, input:String, index:Int = 0):Array<String>
// 	{
// 		var matches = [];
// 		while (ereg.match(input))
// 		{
// 			matches.push(ereg.matched(index));
// 			input = ereg.matchedRight();
// 		}
// 		return matches;
// 	}


// }

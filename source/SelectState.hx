package;

import flixel.math.FlxPoint;
import flixel.addons.display.shapes.FlxShapeArrow;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;

class SelectState extends FlxState
{
	var wasPressed:Bool = false;
	var selectText:FlxText = new FlxText();
	var twitch:FlxText = new FlxText();
	var yt:FlxText = new FlxText();
	var marker:FlxShapeArrow;

	var available:Array<FlxText> = [];
	var selected:Int = 0;

	override function create()
	{
		super.create();

		marker = new FlxShapeArrow(0, 0, FlxPoint.weak(0, 0), FlxPoint.weak(0, 1), 24, {color: FlxColor.WHITE});

		selectText.setFormat(null, 36, FlxColor.WHITE, FlxTextAlign.CENTER);
		selectText.text = "Select your streaming platform";
		selectText.y = 5;
		selectText.screenCenter(X);

		twitch.setFormat(null, 24, FlxColor.WHITE, FlxTextAlign.CENTER);
		twitch.text = "Twitch";
		twitch.screenCenter(Y);
		twitch.x = FlxG.width / 4 - twitch.width / 2;

		yt.setFormat(null, 24, FlxColor.WHITE, FlxTextAlign.CENTER);
		yt.text = "YouTube";
		yt.screenCenter(Y);
		yt.x = FlxG.width * 0.75 - yt.width / 2;

		available.push(twitch);
		available.push(yt);

        add(selectText);
        add(twitch);
        add(yt);
        add(marker);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER && !wasPressed)
		{
			wasPressed = true;
			switch (available[selected].text)
			{
				case 'Twitch':
					FlxG.switchState(new TwitchState());
				case 'YouTube':
					FlxG.switchState(new YouTubeState());
			}
		}

		if (FlxG.keys.justPressed.LEFT)
		{
			changeSelection(-1);
		}

		if (FlxG.keys.justPressed.RIGHT)
		{
			changeSelection(1);
		}

		marker.x = available[selected].x + available[selected].width / 2 - marker.width / 2;
		marker.y = available[selected].y - marker.height - 5;
	}

	function changeSelection(direction:Int = 0)
	{
		if (wasPressed)
			return;

		selected = selected + direction;
		if (selected < 0)
			selected = available.length - 1;
		else if (selected >= available.length)
			selected = 0;
	}
}

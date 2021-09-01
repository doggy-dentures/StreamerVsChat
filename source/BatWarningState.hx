package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;

class BatWarningState extends FlxState
{

    var skippable:Bool = false;
    var nobat:FlxSprite;
    var wasPressed:Bool = false;

	override function create()
    {
        super.create();
        nobat = new FlxSprite().loadGraphic('assets/images/nobat.png');
        nobat.scrollFactor.x = 0;
        nobat.scrollFactor.y = 0;
        add(nobat);
        new FlxTimer().start(0.5, function(tmr:FlxTimer)
        {
            skippable = true;
        });
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (skippable && FlxG.keys.justPressed.ENTER && !wasPressed)
		{
            wasPressed = true;
			FlxG.switchState(new TitleVidState());
		}

	}

}

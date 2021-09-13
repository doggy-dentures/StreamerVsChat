package;

import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public function new(boyfriend:Boyfriend, follow:FlxObject)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(boyfriend.x, boyfriend.y, daBf);
		add(bf);

		if (follow == null)
			follow = new FlxObject(bf.x, bf.y, 1, 1);
		
		camFollow = new FlxObject(follow.x, follow.y, 1, 1);
		add(camFollow);

		FlxTween.tween(camFollow, {x: bf.getGraphicMidpoint().x, y: bf.getGraphicMidpoint().y}, 3, {ease: FlxEase.quintOut, startDelay: 0.5});

		FlxG.sound.play('assets/sounds/fnf_loss_sfx' + stageSuffix + TitleState.soundExt);
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.camera.follow(camFollow, LOCKON);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic('assets/music/gameOver' + stageSuffix + TitleState.soundExt);
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
			//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play('assets/music/gameOverEnd' + stageSuffix + TitleState.soundExt);
			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1.2, false, function()
				{
					FlxG.switchState(new PlayState());
				});
			});
		}
	}
}

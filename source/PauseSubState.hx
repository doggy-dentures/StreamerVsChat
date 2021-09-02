package;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.events.KeyboardEvent;
import openfl.events.KeyboardEvent;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();

		openfl.Lib.current.stage.frameRate = 144;

		if (PlayState.storyPlaylist.length > 1 && PlayState.isStoryMode)
		{
			menuItems.insert(2, "Skip Song");
		}

		if (!PlayState.isStoryMode)
		{
			menuItems.insert(2, "Chart Editor");
		}

		if (!PlayState.isStoryMode && PlayState.sectionStart)
		{
			menuItems.insert(1, "Restart Section");
		}

		pauseMusic = new FlxSound().loadEmbedded('assets/music/breakfast' + TitleState.soundExt, true, true);

		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function create()
	{
		FlxTimer.globalManager.active = false;
		FlxTween.globalManager.active = false;
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.05 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					unpause();

				case "Restart Song":
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);
					FlxG.resetState();
					PlayState.sectionStart = false;

				case "Restart Section":
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);
					FlxG.resetState();

				case "Chart Editor":
					PlayerSettings.menuControls();
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);
					FlxG.switchState(new ChartingState());

				case "Skip Song":
					PlayState.instance.endSong();

				case "Exit to menu":
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyDown);
					// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayState.instance.keyUp);

					PlayState.sectionStart = false;

					switch (PlayState.returnLocation)
					{
						case "freeplay":
							FlxG.switchState(new FreeplayState());
						case "story":
							FlxG.switchState(new StoryMenuState());
						default:
							FlxG.switchState(new MainMenuState());
					}
			}
		}
	}

	function unpause()
	{
		FlxTimer.globalManager.active = true;
		FlxTween.globalManager.active = true;
		if (Config.noFpsCap)
			openfl.Lib.current.stage.frameRate = 999;
		close();
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

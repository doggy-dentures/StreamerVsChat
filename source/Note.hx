package;

import flixel.util.FlxDestroyUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

// import polymod.format.ParseRules.TargetSignatureElement;
using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var trueNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public var playedEditorClick:Bool = false;
	public var editorBFNote:Bool = false;
	public var absoluteNumber:Int;

	public var spinAmount:Float = 0;
	public var rootNote:Note;

	public var isMine:Bool = false;
	public var isAlert:Bool = false;
	public var isHeal:Bool = false;
	public var isFreeze:Bool = false;
	public var isFakeHeal:Bool = false;

	public var specialNote:Bool = false;
	public var ignoreMiss:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	var posTween:FlxTween;

	var justMixedUp:Bool = false;

	public function new(_strumTime:Float, _noteData:Int, ?_editor = false, ?_prevNote:Note, ?_sustainNote:Bool = false, ?_rootNote:Note, noteType:Int = 0)
	{
		super();

		if (_prevNote == null)
			_prevNote = this;

		prevNote = _prevNote;
		isSustainNote = _sustainNote;
		rootNote = _rootNote;

		switch (noteType)
		{
			case 1:
				isMine = true;
				specialNote = true;
				ignoreMiss = true;
			case 2:
				isAlert = true;
				specialNote = true;
			case 3:
				isHeal = true;
				specialNote = true;
				ignoreMiss = true;
			case 4:
				isFreeze = true;
				specialNote = true;
				ignoreMiss = true;
			case 5:
				isFakeHeal = true;
				specialNote = true;
				ignoreMiss = true;
		}

		x += 100;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (!_editor)
		{
			strumTime = _strumTime + Config.offset;
			if (strumTime < 0)
			{
				strumTime = 0;
			}
		}
		else
		{
			strumTime = _strumTime;
		}

		noteData = _noteData;
		trueNoteData = _noteData;

		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				switch (noteType)
				{
					case 0:
						loadGraphic('assets/images/weeb/pixelUI/arrows-pixels.png', true, 17, 17);

						animation.add('greenScroll', [6]);
						animation.add('redScroll', [7]);
						animation.add('blueScroll', [5]);
						animation.add('purpleScroll', [4]);

						if (Config.noteGlow)
						{
							animation.add('green glow', [22]);
							animation.add('red glow', [23]);
							animation.add('blue glow', [21]);
							animation.add('purple glow', [20]);
						}

						if (isSustainNote)
						{
							loadGraphic('assets/images/weeb/pixelUI/arrowEnds.png', true, 7, 6);

							animation.add('purpleholdend', [4]);
							animation.add('greenholdend', [6]);
							animation.add('redholdend', [7]);
							animation.add('blueholdend', [5]);

							animation.add('purplehold', [0]);
							animation.add('greenhold', [2]);
							animation.add('redhold', [3]);
							animation.add('bluehold', [1]);
						}

						if (Config.noteGlow)
						{
							animation.addByPrefix('purple glow', 'Purple Active');
							animation.addByPrefix('green glow', 'Green Active');
							animation.addByPrefix('red glow', 'Red Active');
							animation.addByPrefix('blue glow', 'Blue Active');
						}
					case 1:
						loadGraphic("assets/images/weeb/pixelUI/minenote.png");
					case 2:
						loadGraphic("assets/images/weeb/pixelUI/warningnote.png");
					case 3:
						loadGraphic("assets/images/weeb/pixelUI/healnote.png");
					case 4:
						loadGraphic("assets/images/weeb/pixelUI/icenote.png");
					case 5:
						loadGraphic("assets/images/weeb/pixelUI/fakehealnote.png");
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			default:
				switch (noteType)
				{
					case 0:
						frames = FlxAtlasFrames.fromSparrow('assets/images/NOTE_assets.png', 'assets/images/NOTE_assets.xml');

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						animation.addByPrefix('purpleholdend', 'pruple end hold');
						animation.addByPrefix('greenholdend', 'green hold end');
						animation.addByPrefix('redholdend', 'red hold end');
						animation.addByPrefix('blueholdend', 'blue hold end');

						animation.addByPrefix('purplehold', 'purple hold piece');
						animation.addByPrefix('greenhold', 'green hold piece');
						animation.addByPrefix('redhold', 'red hold piece');
						animation.addByPrefix('bluehold', 'blue hold piece');

						if (Config.noteGlow)
						{
							animation.addByPrefix('purple glow', 'Purple Active');
							animation.addByPrefix('green glow', 'Green Active');
							animation.addByPrefix('red glow', 'Red Active');
							animation.addByPrefix('blue glow', 'Blue Active');
						}
					case 1:
						loadGraphic("assets/images/minenote.png");
					case 2:
						loadGraphic("assets/images/warningnote.png");
					case 3:
						loadGraphic("assets/images/healnote.png");
					case 4:
						loadGraphic("assets/images/icenote.png");
					case 5:
						loadGraphic("assets/images/fakehealnote.png");
				}

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			x += width / 2;

			updateFlip();

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
					case 1:
						prevNote.animation.play('bluehold');
					case 0:
						prevNote.animation.play('purplehold');
				}

				updatePrevScale();
				prevNote.updateHitbox();
			}
		}
	}

	public function updatePrevScale()
	{
		if (isSustainNote && prevNote != null && prevNote.isSustainNote)
		{
			prevNote.scale.x = prevNote.scale.y = 1;
			prevNote.updateHitbox();
			switch (PlayState.curStage)
			{
				case 'school' | 'schoolEvil':
					prevNote.setGraphicSize(Std.int(prevNote.width * PlayState.daPixelZoom));
				default:
					prevNote.setGraphicSize(Std.int(prevNote.width * 0.7));
			}
			prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.effectiveScrollSpeed;
			prevNote.updateHitbox();
		}
	}

	public function updateFlip()
	{
		if (isSustainNote && prevNote != null)
		{
			flipY = PlayState.effectiveDownScroll;
			updateHitbox();
		}
	}

	public function swapPositions()
	{
		justMixedUp = true;
		if (posTween != null && posTween.active)
			posTween.cancel();
		var newX = FlxG.width / 2
			+ 100
			+ swagWidth * PlayState.notePositions[noteData % 4]
			+ (isSustainNote ? (PlayState.curStage.startsWith('school') ? width * 0.75 : width) : 0);
		posTween = FlxTween.tween(this, {x: newX}, 0.25, {
			onComplete: function(_)
			{
				justMixedUp = false;
			}
		});
	}

	function updateXPosition()
	{
		if (justMixedUp)
			return;
		if (mustPress)
		{
			var newX = FlxG.width / 2
				+ 100
				+ swagWidth * PlayState.notePositions[noteData % 4]
				+ (isSustainNote ? (PlayState.curStage.startsWith('school') ? width * 0.75 : width) : 0);
			x = newX;
		}
		else
		{
			var newX = 0
				+ 100
				+ swagWidth * noteData
				+ (isSustainNote ? (PlayState.curStage.startsWith('school') ? width * 0.75 : width) : 0);
			x = newX;
		}
	}

	public var isGhosting:Bool = false;
	public var ghostSpeed:Float = 1;
	public var ghostSine:Bool = false;

	public function doGhost(?speed:Float, ?sine:Bool)
	{
		if (speed == null)
			speed = FlxG.random.float(0.003, 0.006);
		if (sine == null)
			sine = FlxG.random.bool();

		ghostSine = sine;
		ghostSpeed = speed;
		isGhosting = true;
	}

	public function undoGhost()
	{
		isGhosting = false;
		alpha = 1.0;
	}

	public function refreshSprite()
	{
		if (animation == null || animation.name == null)
			return;

		if (animation.name.contains("Scroll"))
		{
			switch (noteData)
			{
				case 0:
					animation.play('purpleScroll');
				case 1:
					animation.play('blueScroll');
				case 2:
					animation.play('greenScroll');
				case 3:
					animation.play('redScroll');
			}
		}
		else if (animation.name.contains("end"))
		{
			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}
		}
		else if (animation.name.contains("hold"))
		{
			switch (noteData)
			{
				case 2:
					animation.play('greenhold');
				case 3:
					animation.play('redhold');
				case 1:
					animation.play('bluehold');
				case 0:
					animation.play('purplehold');
			}
		}

		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isGhosting)
		{
			if (ghostSine)
			{
				alpha = 0.1 + 0.65 * Math.abs(Math.sin(Conductor.songPosition * ghostSpeed));
			}
			else
			{
				alpha = 0.1 + 0.65 * Math.abs(Math.cos(Conductor.songPosition * ghostSpeed));
			}
		}

		if (mustPress)
		{
			if (isSustainNote)
			{
				canBeHit = (strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.125);
			}
			else if (isMine || isFreeze || isFakeHeal)
			{
				canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * 0.9
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.9);
			}
			else if (isAlert || isHeal)
			{
				canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * 1.2
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 1.2);
			}
			else
			{
				canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset);
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
			{
				wasGoodHit = true;
			}
		}

		// Glow note stuff.

		if (!specialNote)
		{
			if (canBeHit && Config.noteGlow && !isSustainNote && animation.curAnim.name.contains("Scroll"))
			{
				switch (noteData)
				{
					case 2:
						animation.play('green glow');
					case 3:
						animation.play('red glow');
					case 1:
						animation.play('blue glow');
					case 0:
						animation.play('purple glow');
				}
			}

			if (tooLate && !isSustainNote && !animation.curAnim.name.contains("Scroll"))
			{
				switch (noteData)
				{
					case 2:
						animation.play('greenScroll');
					case 3:
						animation.play('redScroll');
					case 1:
						animation.play('blueScroll');
					case 0:
						animation.play('purpleScroll');
				}
			}

			if (spinAmount != 0)
			{
				angle += FlxG.elapsed * spinAmount;
			}
		}

		centerOffsets();
		if (PlayState.xWiggle != null && PlayState.yWiggle != null)
		{
			offset.x += PlayState.xWiggle[noteData % 4];
			offset.y += PlayState.yWiggle[noteData % 4];
		}
		updateXPosition();
	}

	override public function destroy()
	{
		if (posTween != null && posTween.active)
		{
			posTween.cancel();
		}
		FlxDestroyUtil.destroy(posTween);
		super.destroy();
	}
}

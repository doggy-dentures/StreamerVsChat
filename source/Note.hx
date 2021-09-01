package;

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

	public var specialNote:Bool = false;
	public var ignoreMiss:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

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

	var posTween:FlxTween;

	public function updatePosition(available:Array<Int>)
	{
		if (posTween != null && posTween.active)
			posTween.cancel();
		var newX = FlxG.width / 2
			+ 100
			+ swagWidth * available[noteData % 4]
			+ (isSustainNote ? (PlayState.curStage.startsWith('school') ? width * 0.75 : width) : 0);
		posTween = FlxTween.tween(this, {x: newX}, 0.25);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (isSustainNote)
			{
				canBeHit = (strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.125);
			}
			else if (isMine)
			{
				canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * 0.9
					&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.9);
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
		offset.x += PlayState.xWiggle[noteData % 4];
		offset.y += PlayState.yWiggle[noteData % 4];
	}
}

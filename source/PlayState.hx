package;

import openfl.media.ID3Info;
import lime.media.openal.AL;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.misc.NumTween;
import flixel.math.FlxRandom;
import flixel.FlxState;
import flixel.util.FlxDestroyUtil;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.BitmapFilter;
import haxe.Json;
import lime.utils.Assets;
import flixel.math.FlxRect;
import openfl.system.System;
import openfl.ui.KeyLocation;
import flixel.input.keyboard.FlxKey;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import sys.FileSystem;
// import polymod.fs.SysFileSystem;
import Section.SwagSection;
import Song.SwagSong;
// import WiggleEffect.WiggleEffectType;
// import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
// import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
// import flixel.FlxState;
import flixel.FlxSubState;
// import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
// import flixel.addons.effects.FlxTrailArea;
// import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
// import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
// import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
// import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
// import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

// import haxe.Json;
// import lime.utils.Assets;
// import openfl.display.BlendMode;
// import openfl.display.StageQuality;
// import openfl.filters.ShaderFilter;
using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var commands:Array<String> = [];

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public static var returnLocation:String = "main";
	public static var returnSong:Int = 0;

	private var canHit:Bool = false;
	private var noMissCount:Int = 0;

	public static var stageSongs:Array<String>;
	public static var spookySongs:Array<String>;
	public static var phillySongs:Array<String>;
	public static var limoSongs:Array<String>;
	public static var mallSongs:Array<String>;
	public static var evilMallSongs:Array<String>;
	public static var schoolSongs:Array<String>;
	public static var schoolScared:Array<String>;
	public static var evilSchoolSongs:Array<String>;

	private var camFocus:String = "";
	private var camTween:FlxTween;
	private var camZoomTween:FlxTween;
	private var uiZoomTween:FlxTween;
	private var camFollow:FlxObject;
	private var autoCam:Bool = true;
	private var autoZoom:Bool = true;
	private var autoUi:Bool = true;

	private var bopSpeed:Int = 1;

	private var sectionHasOppNotes:Bool = false;
	private var sectionHasBFNotes:Bool = false;
	private var sectionHaveNotes:Array<Array<Bool>> = [];

	// private var vocals:FlxSound;
	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	// Wacky input stuff=========================
	private var skipListener:Bool = false;

	private var upTime:Int = 0;
	private var downTime:Int = 0;
	private var leftTime:Int = 0;
	private var rightTime:Int = 0;

	private var upPress:Bool = false;
	private var downPress:Bool = false;
	private var leftPress:Bool = false;
	private var rightPress:Bool = false;

	private var upRelease:Bool = false;
	private var downRelease:Bool = false;
	private var leftRelease:Bool = false;
	private var rightRelease:Bool = false;

	private var upHold:Bool = false;
	private var downHold:Bool = false;
	private var leftHold:Bool = false;
	private var rightHold:Bool = false;

	// End of wacky input stuff===================
	private var invulnCount:Int = 0;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var enemyStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = true;
	private var curSong:String = "";

	private var health:Float = 1;
	private var combo:Int = 0;
	private var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camUnderTop:FlxCamera;

	public var camSpellPrompts:FlxCamera;

	private var camTop:FlxCamera;
	private var camNotes:FlxCamera;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = [':bf:strange code', ':dad:>:]'];

	/*var bfPos:Array<Array<Float>> = [
										[975.5, 862],
										[975.5, 862],
										[975.5, 862],
										[1235.5, 642],
										[1175.5, 866],
										[1295.5, 866],
										[1189, 1108],
										[1189, 1108]
										];

		var dadPos:Array<Array<Float>> = [
										 [314.5, 867],
										 [346, 849],
										 [326.5, 875],
										 [339.5, 914],
										 [42, 882],
										 [342, 861],
										 [625, 1446],
										 [334, 968]
										 ]; */
	var halloweenBG:FlxSprite;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;

	// var wiggleShit:WiggleEffect = new WiggleEffect();
	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	var dadBeats:Array<Int> = [0, 2];
	var bfBeats:Array<Int> = [1, 3];

	public static var sectionStart:Bool = false;
	public static var sectionStartPoint:Int = 0;
	public static var sectionStartTime:Float = 0;

	private var meta:SongMetaTags;

	var filters:Array<BitmapFilter> = [];
	var filtersGame:Array<BitmapFilter> = [];
	var filterMap:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}>;

	public static var effectiveScrollSpeed:Float;
	public static var effectiveDownScroll:Bool;

	var musicThing:AudioThing;
	var vocals:AudioThing;

	var effectsActive:Map<String, Int> = new Map<String, Int>();

	var effectTimer:FlxTimer = new FlxTimer();

	public static var xWiggle:Array<Float> = [0, 0, 0, 0];
	public static var yWiggle:Array<Float> = [0, 0, 0, 0];

	var xWiggleTween:Array<NumTween> = [null, null, null, null];
	var yWiggleTween:Array<NumTween> = [null, null, null, null];

	var severInputs:Array<Bool> = [false, false, false, false];

	var drainHealth:Bool = false;

	var drunkTween:NumTween = null;

	var lagOn:Bool = false;

	var addedMP4s:Array<VideoHandlerMP4> = [];

	var flashbangTimer:FlxTimer = new FlxTimer();

	var errorMessages:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var noiseSound:FlxSound = new FlxSound();

	var camAngle:Float = 0;

	var dmgMultiplier:Float = 1;

	var delayOffset:Float = 0;
	var volumeMultiplier:Float = 1;

	var frozenInput:Int = 0;

	public static var notePositions:Array<Int> = [0, 1, 2, 3];

	var blurEffect:MosaicEffect = new MosaicEffect();

	public static var validWords:Array<String> = [];

	var spellPrompts:Array<SpellPrompt> = [];

	public static var controlButtons:Array<String> = [];

	var terminateStep:Int = -1;
	var terminateMessage:FlxSprite = new FlxSprite();
	var terminateSound:FlxSound = new FlxSound();
	var terminateTimestamps:Array<TerminateTimestamp> = new Array<TerminateTimestamp>();
	var terminateCooldown:Bool = false;

	var shieldSprite:FlxSprite = new FlxSprite();

	override public function create()
	{
		instance = this;
		FlxG.mouse.visible = false;
		PlayerSettings.gameControls();

		resetChatData();

		Conductor.playbackSpeed = 1.0;

		effectiveScrollSpeed = PlayState.SONG.speed;
		effectiveDownScroll = Config.downscroll;
		notePositions = [0, 1, 2, 3];

		blurEffect.setStrength(0, 0);

		var wordList:Array<String> = [];

		if (FileSystem.exists("assets/data/words.txt"))
		{
			var content:String = sys.io.File.getContent("assets/data/words.txt");
			wordList = content.split("\n");
		}

		validWords.resize(0);
		for (word in wordList)
		{
			if (StringTools.contains(word.toLowerCase(), StringTools.trim(FlxG.save.data.leftBind).toLowerCase())
				|| StringTools.contains(word.toLowerCase(), StringTools.trim(FlxG.save.data.downBind).toLowerCase())
				|| StringTools.contains(word.toLowerCase(), StringTools.trim(FlxG.save.data.upBind).toLowerCase())
				|| StringTools.contains(word.toLowerCase(), StringTools.trim(FlxG.save.data.rightBind).toLowerCase())
				|| StringTools.contains(word.toLowerCase(), StringTools.trim(FlxG.save.data.killBind).toLowerCase()))
			{
				continue;
			}
			else
			{
				validWords.push(word.toLowerCase());
			}
		}
		if (validWords.length <= 0)
		{
			trace("wtf no valid words");
			validWords = ["i am error"];
		}

		controlButtons.resize(0);
		for (thing in [
			FlxG.save.data.leftBind, FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind, FlxG.save.data.killBind, "LEFT", "RIGHT", "UP",
			"DOWN", "SEVEN", "EIGHT", "NINE"
		])
		{
			controlButtons.push(StringTools.trim(thing).toLowerCase());
		}
		// FlxG.sound.cache("assets/music/" + SONG.song + "_Inst" + TitleState.soundExt);
		// FlxG.sound.cache("assets/music/" + SONG.song + "_Voices" + TitleState.soundExt);

		musicThing = new AudioThing("assets/music/" + SONG.song + "_Inst" + TitleState.soundExt);
		vocals = new AudioThing("assets/music/" + SONG.song + "_Voices" + TitleState.soundExt);

		add(musicThing);
		add(vocals);

		if (Config.noFpsCap)
			openfl.Lib.current.stage.frameRate = 999;
		else
			openfl.Lib.current.stage.frameRate = 144;

		camTween = FlxTween.tween(this, {}, 0);
		camZoomTween = FlxTween.tween(this, {}, 0);
		uiZoomTween = FlxTween.tween(this, {}, 0);

		stageSongs = ["tutorial", "bopeebo", "fresh", "dadbattle"];
		spookySongs = ["spookeez", "south", "monster"];
		phillySongs = ["pico", "philly", "blammed"];
		limoSongs = ["satin-panties", "high", "milf"];
		mallSongs = ["cocoa", "eggnog"];
		evilMallSongs = ["winter-horrorland"];
		schoolSongs = ["senpai", "roses"];
		schoolScared = ["roses"];
		evilSchoolSongs = ["thorns"];

		for (i in 0...SONG.notes.length)
		{
			var array = [false, false];

			array[0] = sectionContainsBfNotes(i);
			array[1] = sectionContainsOppNotes(i);

			sectionHaveNotes.push(array);
		}

		canHit = !(Config.ghostTapType > 0);
		noMissCount = 0;
		invulnCount = 0;

		filterMap = [
			"Grayscale" => {
				var matrix:Array<Float> = [
					0.5, 0.5, 0.5, 0, 0,
					0.5, 0.5, 0.5, 0, 0,
					0.5, 0.5, 0.5, 0, 0,
					  0,   0,   0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"BlurLittle" => {
				filter: new BlurFilter()
			}
		];

		terminateSound = new FlxSound().loadEmbedded('assets/sounds/beep' + TitleState.soundExt);
		FlxG.sound.list.add(terminateSound);

		terminateMessage.visible = false;
		add(terminateMessage);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camNotes = new FlxCamera();
		camTop = new FlxCamera();
		camUnderTop = new FlxCamera();
		camSpellPrompts = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camNotes.bgColor.alpha = 0;
		camTop.bgColor.alpha = 0;
		camUnderTop.bgColor.alpha = 0;
		camSpellPrompts.bgColor.alpha = 0;

		camNotes.setFilters(filters);
		camNotes.filtersEnabled = true;

		camGame.setFilters(filtersGame);
		camGame.filtersEnabled = true;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camNotes);
		FlxG.cameras.add(camUnderTop);
		FlxG.cameras.add(camSpellPrompts);
		FlxG.cameras.add(camTop);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		errorMessages.cameras = [camUnderTop];
		add(errorMessages);

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.changeBPM(SONG.bpm);

		if (FileSystem.exists("assets/data/" + SONG.song.toLowerCase() + "/" + SONG.song.toLowerCase() + "Dialogue.txt"))
		{
			try
			{
				dialogue = CoolUtil.coolTextFile("assets/data/" + SONG.song.toLowerCase() + "/" + SONG.song.toLowerCase() + "Dialogue.txt");
			}
			catch (e)
			{
			}
		}

		var stageCheck:String = 'stage';
		if (SONG.stage == null)
		{
			if (spookySongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'spooky';
			}
			else if (phillySongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'philly';
			}
			else if (limoSongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'limo';
			}
			else if (mallSongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'mall';
			}
			else if (evilMallSongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'mallEvil';
			}
			else if (schoolSongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'school';
			}
			else if (evilSchoolSongs.contains(SONG.song.toLowerCase()))
			{
				stageCheck = 'schoolEvil';
			}

			SONG.stage = stageCheck;
		}
		else
		{
			stageCheck = SONG.stage;
		}

		if (stageCheck == 'spooky')
		{
			curStage = "spooky";

			halloweenBG = new FlxSprite(-200, -100);
			halloweenBG.frames = Paths.getSparrowAtlas("halloween_bg");
			halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
			halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
			halloweenBG.animation.play('idle');
			halloweenBG.antialiasing = true;
			add(halloweenBG);
		}
		else if (stageCheck == 'philly')
		{
			curStage = 'philly';

			var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
			bg.scrollFactor.set(0.1, 0.1);
			add(bg);

			var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
			city.scrollFactor.set(0.3, 0.3);
			city.setGraphicSize(Std.int(city.width * 0.85));
			city.updateHitbox();
			add(city);

			phillyCityLights = new FlxTypedGroup<FlxSprite>();
			add(phillyCityLights);

			for (i in 0...5)
			{
				var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
				light.scrollFactor.set(0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLights.add(light);
			}

			var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
			add(streetBehind);

			phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
			add(phillyTrain);

			trainSound = new FlxSound().loadEmbedded('assets/sounds/train_passes' + TitleState.soundExt);
			FlxG.sound.list.add(trainSound);

			// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

			var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
			add(street);
		}
		else if (stageCheck == 'limo')
		{
			curStage = 'limo';
			defaultCamZoom = 0.90;

			var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image("limo/limoSunset"));
			skyBG.scrollFactor.set(0.1, 0.1);
			add(skyBG);

			var bgLimo:FlxSprite = new FlxSprite(-200, 480);
			bgLimo.frames = Paths.getSparrowAtlas("limo/bgLimo");
			bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
			bgLimo.animation.play('drive');
			bgLimo.scrollFactor.set(0.4, 0.4);
			add(bgLimo);

			grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
			add(grpLimoDancers);

			for (i in 0...5)
			{
				var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				grpLimoDancers.add(dancer);
			}

			// overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic('assets/images/limo/limoOverlay.png');
			// overlayShit.alpha = 0.5;
			// add(overlayShit);

			// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

			// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

			// overlayShit.shader = shaderBullshit;

			limo = new FlxSprite(-120, 550);
			limo.frames = Paths.getSparrowAtlas("limo/limoDrive");
			limo.animation.addByPrefix('drive', "Limo stage", 24);
			limo.animation.play('drive');
			limo.antialiasing = true;

			fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image("limo/fastCarLol"));
			// add(limo);
		}
		else if (stageCheck == 'mall')
		{
			curStage = 'mall';

			defaultCamZoom = 0.80;

			var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			upperBoppers = new FlxSprite(-240, -90);
			upperBoppers.frames = Paths.getSparrowAtlas("christmas/upperBop");
			upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
			upperBoppers.antialiasing = true;
			upperBoppers.scrollFactor.set(0.33, 0.33);
			upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
			upperBoppers.updateHitbox();
			add(upperBoppers);

			var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image("christmas/bgEscalator"));
			bgEscalator.antialiasing = true;
			bgEscalator.scrollFactor.set(0.3, 0.3);
			bgEscalator.active = false;
			bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
			bgEscalator.updateHitbox();
			add(bgEscalator);

			var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image("christmas/christmasTree"));
			tree.antialiasing = true;
			tree.scrollFactor.set(0.40, 0.40);
			add(tree);

			bottomBoppers = new FlxSprite(-300, 140);
			bottomBoppers.frames = Paths.getSparrowAtlas("christmas/bottomBop");
			bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
			bottomBoppers.antialiasing = true;
			bottomBoppers.scrollFactor.set(0.9, 0.9);
			bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
			bottomBoppers.updateHitbox();
			add(bottomBoppers);

			var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image("christmas/fgSnow"));
			fgSnow.active = false;
			fgSnow.antialiasing = true;
			add(fgSnow);

			santa = new FlxSprite(-840, 150);
			santa.frames = Paths.getSparrowAtlas("christmas/santa");
			santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
			santa.antialiasing = true;
			add(santa);
		}
		else if (stageCheck == 'mallEvil')
		{
			curStage = 'mallEvil';
			var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image("christmas/evilBG"));
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
			evilTree.antialiasing = true;
			evilTree.scrollFactor.set(0.2, 0.2);
			add(evilTree);

			var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
			evilSnow.antialiasing = true;
			add(evilSnow);
		}
		else if (stageCheck == 'school')
		{
			curStage = 'school';

			// defaultCamZoom = 0.9;

			var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
			bgSky.scrollFactor.set(0.1, 0.1);
			add(bgSky);

			var repositionShit = -200;

			var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
			bgSchool.scrollFactor.set(0.6, 0.90);
			add(bgSchool);

			var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
			bgStreet.scrollFactor.set(0.95, 0.95);
			add(bgStreet);

			var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
			fgTrees.scrollFactor.set(0.9, 0.9);
			add(fgTrees);

			var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
			var treetex = Paths.getPackerAtlas("weeb/weebTrees");
			bgTrees.frames = treetex;
			bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
			bgTrees.animation.play('treeLoop');
			bgTrees.scrollFactor.set(0.85, 0.85);
			add(bgTrees);

			var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
			treeLeaves.frames = Paths.getSparrowAtlas("weeb/petals");
			treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
			treeLeaves.animation.play('leaves');
			treeLeaves.scrollFactor.set(0.85, 0.85);
			add(treeLeaves);

			var widShit = Std.int(bgSky.width * 6);

			bgSky.setGraphicSize(widShit);
			bgSchool.setGraphicSize(widShit);
			bgStreet.setGraphicSize(widShit);
			bgTrees.setGraphicSize(Std.int(widShit * 1.4));
			fgTrees.setGraphicSize(Std.int(widShit * 0.8));
			treeLeaves.setGraphicSize(widShit);

			fgTrees.updateHitbox();
			bgSky.updateHitbox();
			bgSchool.updateHitbox();
			bgStreet.updateHitbox();
			bgTrees.updateHitbox();
			treeLeaves.updateHitbox();

			bgGirls = new BackgroundGirls(-100, 190);
			bgGirls.scrollFactor.set(0.9, 0.9);

			if (schoolScared.contains(SONG.song.toLowerCase()))
			{
				bgGirls.getScared();
			}

			bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
			bgGirls.updateHitbox();
			add(bgGirls);
		}
		else if (stageCheck == 'schoolEvil')
		{
			curStage = 'schoolEvil';

			var posX = 400;
			var posY = 200;

			var bg:FlxSprite = new FlxSprite(posX, posY);
			bg.frames = Paths.getSparrowAtlas("weeb/animatedEvilSchool");
			bg.animation.addByPrefix('idle', 'background 2', 24);
			bg.animation.play('idle');
			bg.scrollFactor.set(0.8, 0.9);
			bg.scale.set(6, 6);
			add(bg);
		}
		else
		{
			defaultCamZoom = 0.9;
			curStage = 'stage';
			var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image("stageback"));
			// bg.setGraphicSize(Std.int(bg.width * 2.5));
			// bg.updateHitbox();
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);

			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image("stagefront"));
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);

			var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image("stagecurtains"));
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;

			add(stageCurtains);
		}

		switch (SONG.song.toLowerCase())
		{
			case "tutorial":
				autoZoom = false;
				dadBeats = [0, 1, 2, 3];
			case "bopeebo":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "fresh":
				camZooming = false;
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "spookeez":
				dadBeats = [0, 1, 2, 3];
			case "south":
				dadBeats = [0, 1, 2, 3];
			case "monster":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "cocoa":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "thorns":
				dadBeats = [0, 1, 2, 3];
		}

		var gfVersion:String = 'gf';

		var gfCheck:String = 'gf';

		if (SONG.gf == null)
		{
			switch (storyWeek)
			{
				case 4:
					gfCheck = 'gf-car';
				case 5:
					gfCheck = 'gf-christmas';
				case 6:
					gfCheck = 'gf-pixel';
			}

			SONG.gf = gfCheck;
		}
		else
		{
			gfCheck = SONG.gf;
		}

		switch (gfCheck)
		{
			case 'gf-car':
				gfVersion = 'gf-car';
			case 'gf-christmas':
				gfVersion = 'gf-christmas';
			case 'gf-pixel':
				gfVersion = 'gf-pixel';
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					camChangeZoom(1.3, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
				}

			case "spooky":
				dad.y += 200;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 100);
			case "monster":
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 100);
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new DeltaTrail(dad, null, 4, 24 / 60, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		add(gf);

		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);
		add(shieldSprite);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		if (effectiveDownScroll)
		{
			strumLine = new FlxSprite(0, 570).makeGraphic(FlxG.width, 10);
		}
		else
		{
			strumLine = new FlxSprite(0, 30).makeGraphic(FlxG.width, 10);
		}
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON);

		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FileSystem.exists("assets/data/" + SONG.song.toLowerCase() + "/meta.txt"))
		{
			meta = new SongMetaTags(0, 144, SONG.song.toLowerCase());
			meta.cameras = [camHUD];
			add(meta);
		}

		healthBarBG = new FlxSprite(0, effectiveDownScroll ? FlxG.height * 0.1 : FlxG.height * 0.875).loadGraphic('assets/images/healthBar.png');
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar

		scoreTxt = new FlxText(healthBarBG.x - 105, (effectiveDownScroll ? FlxG.height * 0.1 - 72 : FlxG.height * 0.9 + 36), 800, "", 22);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 22, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		add(healthBar);
		add(iconP2);
		add(iconP1);
		add(scoreTxt);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camNotes];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		healthBar.visible = false;
		healthBarBG.visible = false;
		iconP1.visible = false;
		iconP2.visible = false;
		scoreTxt.visible = false;

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play('assets/sounds/Lights_Turn_On' + TitleState.soundExt);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play('assets/sounds/ANGRY' + TitleState.soundExt);
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		// FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		// FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);

		super.create();

		if (curStage.startsWith('school'))
		{
			shieldSprite.loadGraphic("assets/images/weeb/pixelUI/shield.png");
			shieldSprite.alpha = 0.85;
			shieldSprite.setGraphicSize(Std.int(shieldSprite.width * PlayState.daPixelZoom));
			shieldSprite.updateHitbox();
			shieldSprite.antialiasing = false;
		}
		else
		{
			shieldSprite.loadGraphic("assets/images/shield.png");
			shieldSprite.alpha = 0.85;
			shieldSprite.scale.x = shieldSprite.scale.y = 0.8;
			shieldSprite.updateHitbox();
		}
		shieldSprite.visible = false;
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;
		// trace(totalNotesHit + '/' + totalPlayed + '* 100 = ' + accuracy);
		if (accuracy >= 100.00)
		{
			accuracy = 100;
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = FlxAtlasFrames.fromSparrow('assets/images/weeb/senpaiCrazy.png', 'assets/images/weeb/senpaiCrazy.xml');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 5.5));
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		// senpaiEvil.x -= 120;
		senpaiEvil.y -= 115;

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play('assets/sounds/Senpai_Dies' + TitleState.soundExt, 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		inCutscene = false;

		if (musicThing != null)
			musicThing.pause();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		healthBar.visible = true;
		healthBarBG.visible = true;
		iconP1.visible = true;
		iconP2.visible = true;
		scoreTxt.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000 * (1 / Conductor.playbackSpeed), function(tmr:FlxTimer)
		{
			if (dadBeats.contains((swagCounter % 4)))
				dad.dance();

			gf.dance();

			if (bfBeats.contains((swagCounter % 4)))
				boyfriend.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready.png', "set.png", "go.png"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel.png',
				'weeb/pixelUI/set-pixel.png',
				'weeb/pixelUI/date-pixel.png'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel.png',
				'weeb/pixelUI/set-pixel.png',
				'weeb/pixelUI/date-pixel.png'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play('assets/sounds/intro3' + altSuffix + TitleState.soundExt, 0.6);
					if (meta != null)
					{
						meta.start();
					}
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[0]);
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro2' + altSuffix + TitleState.soundExt, 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[1]);
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro1' + altSuffix + TitleState.soundExt, 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[2]);
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/introGo' + altSuffix + TitleState.soundExt, 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			musicThing.play();
		}

		// FlxG.sound.music.onComplete = endSong;
		vocals.play();

		if (sectionStart)
		{
			musicThing.time = sectionStartTime;
			Conductor.songPosition = sectionStartTime;
			vocals.time = sectionStartTime;
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (!paused)
				resyncVocals();
		});

		effectTimer.start(5, function(timer)
		{
			if (paused)
				return;
			if (startingSong)
				return;
			if (endingSong)
				return;
			readChatData();
		}, 0);
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		// if (SONG.needsVoices)
		// {
		// 	vocals = new FlxSound().loadEmbedded("assets/music/" + curSong + "_Voices" + TitleState.soundExt);
		// }
		// else
		// 	vocals = new FlxSound();

		// FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		// for (section in noteData)
		for (section in noteData)
		{
			if (sectionStart && daBeats < sectionStartPoint)
			{
				daBeats++;
				continue;
			}

			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, false, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, false, oldNote, true,
						swagNote);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats++;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		// var markedForDeath:Array<Int> = [];

		// for (i in 1...unspawnNotes.length)
		// {
		// 	var coolNote = unspawnNotes[i];
		// 	var lastNote = unspawnNotes[i - 1];
		// 	if (coolNote.noteData == lastNote.noteData && Math.abs(coolNote.strumTime - lastNote.strumTime) < Conductor.stepCrochet/16)
		// 		markedForDeath.push(i);
		// }

		// for (i in 0...markedForDeath.length)
		// {
		// 	var killThisThing = unspawnNotes[i];
		// 	killThisThing.kill();
		// 	unspawnNotes.remove(killThisThing);
		// 	FlxDestroyUtil.destroy(killThisThing);
		// 	trace('Removed garbage');
		// }

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(50, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic('assets/images/weeb/pixelUI/arrows-pixels.png', true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}

				default:
					babyArrow.frames = FlxAtlasFrames.fromSparrow('assets/images/NOTE_assets.png', 'assets/images/NOTE_assets.xml');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				enemyStrums.add(babyArrow);
				babyArrow.animation.finishCallback = function(name:String)
				{
					if (name == "confirm")
					{
						babyArrow.animation.play('static', true);
						babyArrow.centerOffsets();
					}
				}
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (musicThing != null)
			{
				musicThing.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		PlayerSettings.gameControls();

		if (paused)
		{
			if (musicThing != null && !startingSong && musicThing.gamePaused)
			{
				musicThing.play();
				musicThing.gamePaused = false;
				vocals.gamePaused = false;
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			resumeMP4s();
			noiseSound.resume();
		}

		setBoyfriendInvuln(1 / 60);

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();
		Conductor.songPosition = musicThing.time + delayOffset;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	override public function update(elapsed:Float)
	{
		/*New keyboard input stuff. Disables the listener when using controller because controller uses the other input set thing I did.

			if(skipListener) {keyCheck();}

			if(FlxG.gamepads.anyJustPressed(ANY) && !skipListener) {
				skipListener = true;
				trace("Using controller.");
			}

			if(FlxG.keys.justPressed.ANY && skipListener) {
				skipListener = false;
				trace("Using keyboard.");
			}

			//============================================================= */

		keyCheck(); // Gonna stick with this for right now. I have the other stuff on standby in case this still is not working for people.

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		if (!endingSong && musicThing != null && musicThing.stopped)
		{
			musicThing.stop();
			vocals.stop();
			endSong();
		}

		switch (Config.accuracy)
		{
			case "none":
				scoreTxt.text = "Score:" + songScore;
			default:
				scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "%";
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			pauseMP4s();
			noiseSound.pause();
			musicThing.gamePaused = true;
			vocals.gamePaused = true;

			PlayerSettings.menuControls();

			openSubState(new PauseSubState());
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			PlayerSettings.menuControls();
			FlxG.switchState(new ChartingState());
			sectionStart = false;
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);
		}

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		// Heath Icons
		if (healthBar.percent < 20)
		{
			iconP1.animation.curAnim.curFrame = 1;
			if (Config.betterIcons)
			{ // Better Icons Win Anim
				iconP2.animation.curAnim.curFrame = 2;
			}
		}
		else if (healthBar.percent > 80)
		{
			iconP2.animation.curAnim.curFrame = 1;
			if (Config.betterIcons)
			{ // Better Icons Win Anim
				iconP1.animation.curAnim.curFrame = 2;
			}
		}
		else
		{
			iconP2.animation.curAnim.curFrame = 0;
			iconP1.animation.curAnim.curFrame = 0;
		}

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT)
		{
			PlayerSettings.menuControls();
			sectionStart = false;
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

			if (FlxG.keys.pressed.SHIFT)
			{
				FlxG.switchState(new AnimationDebug(SONG.player1));
			}
			else if (FlxG.keys.pressed.CONTROL)
			{
				FlxG.switchState(new AnimationDebug(gf.curCharacter));
			}
			else
			{
				FlxG.switchState(new AnimationDebug(SONG.player2));
			}
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000 * Conductor.playbackSpeed;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000 * Conductor.playbackSpeed;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFocus != "dad" && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam)
			{
				camFocusOpponent();
			}

			if (camFocus != "bf" && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam)
			{
				camFocusBF();
			}
		}

		FlxG.watch.addQuick("totalBeats: ", totalBeats);

		if (curSong == 'Fresh')
		{
			switch (totalBeats)
			{
				case 16:
					camZooming = true;
					bopSpeed = 2;
					dadBeats = [0, 2];
					bfBeats = [1, 3];
				case 48:
					bopSpeed = 1;
					dadBeats = [0, 1, 2, 3];
					bfBeats = [0, 1, 2, 3];
				case 80:
					bopSpeed = 2;
					dadBeats = [0, 2];
					bfBeats = [1, 3];
				case 112:
					bopSpeed = 1;
					dadBeats = [0, 1, 2, 3];
					bfBeats = [0, 1, 2, 3];
				case 163:
			}
		}

		// RESET = Quick Game Over Screen
		if (controls.RESET && !startingSong)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			if (effectTimer != null && effectTimer.active)
				effectTimer.cancel();

			vocals.pause();
			musicThing.pause();
			pauseMP4s();
			noiseSound.pause();

			PlayerSettings.menuControls();
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

			openSubState(new GameOverSubstate(boyfriend, camFollow));
			sectionStart = false;
		}

		if (unspawnNotes[0] != null)
		{
			// while (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			while (unspawnNotes.length > 0
				&& unspawnNotes[0].strumTime - Conductor.songPosition < (FlxG.height / camNotes.zoom) / 0.45 / FlxMath.roundDecimal(effectiveScrollSpeed, 2))
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				unspawnNotes.splice(0, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				/*if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
				}*/

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					// trace("DA ALT THO?: " + SONG.notes[Math.floor(curStep / 16)].altAnim);

					if (dad.canAutoAnim)
					{
						switch (Math.abs(daNote.noteData))
						{
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
						}
					}

					enemyStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
					});

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1 * volumeMultiplier;

					if (!daNote.isSustainNote)
					{
						daNote.kill();
					}
				}

				var shouldMove = false;
				if (!lagOn || (lagOn && curStep % 2 == 0))
					shouldMove = true;

				if (effectiveDownScroll && shouldMove)
				{
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(effectiveScrollSpeed, 2)));

					if (daNote.isSustainNote)
					{
						daNote.y -= daNote.height;
						daNote.y += 125;

						if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
							&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
						{
							// Clip to strumline
							var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
							swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ Note.swagWidth / 2
								- daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				}
				else if (shouldMove)
				{
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(effectiveScrollSpeed, 2)));

					if (daNote.isSustainNote)
					{
						if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
							&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
						{
							// Clip to strumline
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// MOVE NOTE TRANSPARENCY CODE BECAUSE REASONS
				if (daNote.tooLate)
				{
					if (!daNote.didLatePenalty)
					{
						if (!daNote.ignoreMiss)
						{
							noteMiss(daNote.noteData, (daNote.isAlert ? FlxG.random.float(0.25, 0.5) : 0.055), false, true, daNote.isAlert);
							vocals.volume = 0;
							daNote.didLatePenalty = true;
							if (!daNote.isGhosting)
								daNote.alpha = 0.3;
						}
					}
				}

				if (effectiveDownScroll ? (daNote.y > strumLine.y + daNote.height + 50) : (daNote.y < strumLine.y - daNote.height - 50))
				{
					if (daNote.tooLate || daNote.wasGoodHit)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
					}
				}
			});
		}

		enemyStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.animation.curAnim.name)
			{
				case "confirm":
					spr.centerOffsets();

					if (!curStage.startsWith('school'))
					{
						spr.offset.x -= 14;
						spr.offset.y -= 14;
					}

				default:
					spr.centerOffsets();
			}

			additionalOffset(spr);
		});

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		leftPress = false;
		leftRelease = false;
		downPress = false;
		downRelease = false;
		upPress = false;
		upRelease = false;
		rightPress = false;
		rightRelease = false;

		if (drainHealth)
		{
			health = Math.max(0.25, health - (FlxG.elapsed * 0.125 * dmgMultiplier));
		}

		for (i in 0...spellPrompts.length)
		{
			if (spellPrompts[i] == null)
			{
				continue;
			}
			else if (spellPrompts[i].ttl <= 0)
			{
				health -= 0.5 * dmgMultiplier;
				FlxG.sound.play('assets/sounds/spellfail' + TitleState.soundExt);
				camSpellPrompts.flash(FlxColor.RED, 1, null, true);
				spellPrompts[i].kill();
				FlxDestroyUtil.destroy(spellPrompts[i]);
				remove(spellPrompts[i]);
				spellPrompts.remove(spellPrompts[i]);
			}
			else if (!spellPrompts[i].alive)
			{
				remove(spellPrompts[i]);
				FlxDestroyUtil.destroy(spellPrompts[i]);
			}
		}

		for (timestamp in terminateTimestamps)
		{
			if (timestamp == null || !timestamp.alive)
				continue;

			if (timestamp.tooLate)
			{
				if (!timestamp.didLatePenalty)
				{
					timestamp.didLatePenalty = true;
					var healthToTake = health / 3 * dmgMultiplier;
					health -= healthToTake;
					boyfriend.playAnim('hit', true);
					FlxG.sound.play('assets/sounds/theshoe' + TitleState.soundExt);
					timestamp.kill();
					terminateTimestamps.resize(0);

					var theShoe = new FlxSprite();
					theShoe.loadGraphic("assets/images/theshoe.png");
					theShoe.x = boyfriend.x + boyfriend.width / 2 - theShoe.width / 2;
					theShoe.y = -FlxG.height / defaultCamZoom;
					add(theShoe);
					FlxTween.tween(theShoe, {y: boyfriend.y + boyfriend.height - theShoe.height}, 0.2, {
						onComplete: function(tween)
						{
							if (tween.executions >= 2)
							{
								theShoe.kill();
								FlxDestroyUtil.destroy(theShoe);
								tween.cancel();
								FlxDestroyUtil.destroy(tween);
							}
						},
						type: PINGPONG
					});
				}
			}
		}
	}

	function readChatData()
	{
		if (commands.length == 0)
			return;

		var choose = commands[Std.random(commands.length)];
		doEffect(choose);
	}

	function resetChatData()
	{
		commands = [];
	}

	var oldRate:Int = 60;

	function doEffect(effect:String)
	{
		if (paused)
			return;
		if (endingSong)
			return;

		var ttl:Float = 0;
		var onEnd:(Void->Void) = null;
		var alwaysEnd:Bool = false;
		var playSound:String = "";
		var playSoundVol:Float = 1;
		// trace(effect);
		switch (effect)
		{
			case 'colorblind':
				filters.push(filterMap.get("Grayscale").filter);
				filtersGame.push(filterMap.get("Grayscale").filter);
				playSound = "colorblind";
				playSoundVol = 0.8;
				ttl = 16;
				onEnd = function()
				{
					filters.remove(filterMap.get("Grayscale").filter);
					filtersGame.remove(filterMap.get("Grayscale").filter);
				}
			case 'blur':
				if (effectsActive[effect] == null || effectsActive[effect] <= 0)
				{
					filtersGame.push(filterMap.get("BlurLittle").filter);
					if (curStage.startsWith('school'))
						blurEffect.setStrength(2, 2);
					else
						blurEffect.setStrength(32, 32);
					strumLineNotes.forEach(function(sprite)
					{
						sprite.shader = blurEffect.shader;
					});
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						if (daNote.strumTime >= Conductor.songPosition)
							daNote.shader = blurEffect.shader;
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						else
							daNote.shader = blurEffect.shader;
					}
					boyfriend.shader = blurEffect.shader;
					dad.shader = blurEffect.shader;
					gf.shader = blurEffect.shader;
				}

				playSound = "blur";
				playSoundVol = 0.7;
				ttl = 12;
				onEnd = function()
				{
					strumLineNotes.forEach(function(sprite)
					{
						sprite.shader = null;
					});
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						if (daNote.strumTime >= Conductor.songPosition)
							daNote.shader = null;
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						else
							daNote.shader = null;
					}
					boyfriend.shader = null;
					dad.shader = null;
					gf.shader = null;
					blurEffect.setStrength(0, 0);
					filtersGame.remove(filterMap.get("BlurLittle").filter);
				}
			case 'lag':
				lagOn = true;
				playSound = "lag";
				playSoundVol = 0.7;
				ttl = 12;
				onEnd = function()
				{
					lagOn = false;
				}
			case 'mine':
				var startPoint:Int = FlxG.random.int(5, 9);
				var nextPoint:Int = FlxG.random.int(startPoint + 2, startPoint + 6);
				var lastPoint:Int = FlxG.random.int(nextPoint + 2, nextPoint + 6);
				addNote(1, startPoint, startPoint);
				addNote(1, nextPoint, nextPoint);
				addNote(1, lastPoint, lastPoint);
			case 'warning':
				var startPoint:Int = FlxG.random.int(5, 9);
				var nextPoint:Int = FlxG.random.int(startPoint + 2, startPoint + 6);
				var lastPoint:Int = FlxG.random.int(nextPoint + 2, nextPoint + 6);
				addNote(2, startPoint, startPoint, -1);
				addNote(2, nextPoint, nextPoint, -1);
				addNote(2, lastPoint, lastPoint, -1);
			case 'heal':
				addNote(3, 5, 9);
			case 'spin':
				for (daNote in unspawnNotes)
				{
					if (daNote == null)
						continue;
					if (daNote.strumTime >= Conductor.songPosition && !daNote.isSustainNote)
						daNote.spinAmount = (FlxG.random.bool() ? 1 : -1) * FlxG.random.float(333 * 0.8, 333 * 1.15);
				}
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					if (!daNote.isSustainNote)
						daNote.spinAmount = (FlxG.random.bool() ? 1 : -1) * FlxG.random.float(333 * 0.8, 333 * 1.15);
				}
				playSound = "spin";
				ttl = 15;
				onEnd = function()
				{
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						if (daNote.strumTime >= Conductor.songPosition && !daNote.isSustainNote)
						{
							daNote.spinAmount = 0;
							daNote.angle = 0;
						}
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						if (!daNote.isSustainNote)
						{
							daNote.spinAmount = 0;
							daNote.angle = 0;
						}
					}
				}
			case 'songslower':
				var desiredChangeAmount:Float = FlxG.random.float(0.1, 0.3);
				var changeAmount = Conductor.playbackSpeed - Math.max(Conductor.playbackSpeed - desiredChangeAmount, 0.2);
				vocals.speed = musicThing.speed = Conductor.playbackSpeed = Conductor.playbackSpeed - changeAmount;
				playSound = "songslower";
				ttl = 15;
				alwaysEnd = true;
				onEnd = function()
				{
					vocals.speed = musicThing.speed = Conductor.playbackSpeed = Conductor.playbackSpeed + changeAmount;
				};
			case 'songfaster':
				var changeAmount:Float = FlxG.random.float(0.1, 0.3);
				vocals.speed = musicThing.speed = Conductor.playbackSpeed = Conductor.playbackSpeed + changeAmount;
				playSound = "songfaster";
				ttl = 15;
				alwaysEnd = true;
				onEnd = function()
				{
					vocals.speed = musicThing.speed = Conductor.playbackSpeed = Conductor.playbackSpeed - changeAmount;
				};
			case 'scrollswitch':
				effectiveDownScroll = !effectiveDownScroll;
				for (daNote in unspawnNotes)
				{
					if (daNote == null)
						continue;
					daNote.updateFlip();
				}
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					daNote.updateFlip();
				}
				playSound = "scrollswitch";
				updateScrollUI();
			case 'scrollfaster':
				var changeAmount:Float = FlxG.random.float(0.4, 0.6);
				effectiveScrollSpeed += changeAmount;
				for (daNote in unspawnNotes)
				{
					if (daNote == null)
						continue;
					daNote.updatePrevScale();
				}
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					daNote.updatePrevScale();
				}
				playSound = "scrollfaster";
				ttl = 20;
				alwaysEnd = true;
				onEnd = function()
				{
					effectiveScrollSpeed -= changeAmount;
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						daNote.updatePrevScale();
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						daNote.updatePrevScale();
					}
				}
			case 'scrollslower':
				var desiredChangeAmount:Float = FlxG.random.float(0.4, 0.6);
				var changeAmount = effectiveScrollSpeed - Math.max(effectiveScrollSpeed - desiredChangeAmount, 0.2);
				effectiveScrollSpeed -= changeAmount;
				for (daNote in unspawnNotes)
				{
					if (daNote == null)
						continue;
					daNote.updatePrevScale();
				}
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					daNote.updatePrevScale();
				}
				playSound = "scrollslower";
				ttl = 20;
				alwaysEnd = true;
				onEnd = function()
				{
					effectiveScrollSpeed += changeAmount;
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						daNote.updatePrevScale();
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						daNote.updatePrevScale();
					}
				}
			case 'rainbow':
				for (daNote in unspawnNotes)
				{
					if (daNote == null)
						continue;
					if (daNote.strumTime >= Conductor.songPosition && !daNote.isSustainNote)
						daNote.setColorTransform(1, 1, 1, 1, FlxG.random.int(-255, 255), FlxG.random.int(-255, 255), FlxG.random.int(-255, 255));
					else if (daNote.strumTime >= Conductor.songPosition && daNote.isSustainNote)
						daNote.setColorTransform(1, 1, 1, 1, Std.int(daNote.rootNote.colorTransform.redOffset),
							Std.int(daNote.rootNote.colorTransform.greenOffset), Std.int(daNote.rootNote.colorTransform.blueOffset));
				}
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					if (!daNote.isSustainNote)
						daNote.setColorTransform(1, 1, 1, 1, FlxG.random.int(-255, 255), FlxG.random.int(-255, 255), FlxG.random.int(-255, 255));
					else if (daNote.isSustainNote)
						daNote.setColorTransform(1, 1, 1, 1, Std.int(daNote.rootNote.colorTransform.redOffset),
							Std.int(daNote.rootNote.colorTransform.greenOffset), Std.int(daNote.rootNote.colorTransform.blueOffset));
				}
				playSound = "rainbow";
				playSoundVol = 0.5;
				ttl = 20;
				onEnd = function()
				{
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						if (daNote.strumTime >= Conductor.songPosition)
							daNote.setColorTransform();
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						daNote.setColorTransform();
					}
				};
			case 'cover':
				var errorMessage = new FlxSprite();
				var random = FlxG.random.int(0, 13);
				var randomPosition:Bool = true;

				switch (random)
				{
					case 0:
						errorMessage.loadGraphic("assets/images/zzzzzzzz.png");
						errorMessage.scale.x = errorMessage.scale.y = 0.5;
						errorMessage.updateHitbox();
						playSound = "bell";
						playSoundVol = 0.6;
					case 1:
						errorMessage.loadGraphic("assets/images/scam.png");
						playSound = 'scam';
					case 2:
						errorMessage.loadGraphic("assets/images/funnyskeletonman.png");
						playSound = 'doot';
						errorMessage.scale.x = errorMessage.scale.y = 0.8;
					case 3:
						errorMessage.loadGraphic("assets/images/error.png");
						playSound = 'error';
						errorMessage.scale.x = errorMessage.scale.y = 0.8;
						errorMessage.antialiasing = true;
						errorMessage.updateHitbox();
					case 4:
						errorMessage.loadGraphic("assets/images/nopunch.png");
						playSound = 'nopunch';
						errorMessage.scale.x = errorMessage.scale.y = 0.8;
						errorMessage.antialiasing = true;
						errorMessage.updateHitbox();
					case 5:
						errorMessage.loadGraphic("assets/images/banana.png", true, 397, 750);
						errorMessage.animation.add("dance", [0, 1, 2, 3, 4, 5, 6, 7, 8], 9, true);
						errorMessage.animation.play("dance");
						playSound = 'banana';
						playSoundVol = 0.5;
						errorMessage.scale.x = errorMessage.scale.y = 0.5;
					case 6:
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('mark'), null, false, false).setDimensions(378, 362);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
					case 7:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('fireworks'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'firework';
					case 8:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('spiral'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'spiral';
					case 9:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('thingy'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'thingy';
					case 10:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('light'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'light';
					case 11:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('snow'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'snow';
						playSoundVol = 0.6;
					case 12:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('spiral2'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'spiral';
					case 13:
						randomPosition = false;
						errorMessage = new VideoHandlerMP4();
						cast(errorMessage, VideoHandlerMP4).playMP4(Paths.video('wheel'), null, false, false).setDimensions(1280, 720);
						addedMP4s.push(cast(errorMessage, VideoHandlerMP4));
						errorMessages.add(errorMessage);
						errorMessage.x = errorMessage.y = 0;
						errorMessage.blend = ADD;
						playSound = 'wheel';
				}

				if (randomPosition)
				{
					var position = FlxG.random.int(0, 4);
					switch (position)
					{
						case 0:
							errorMessage.x = (FlxG.width - FlxG.width / 4) - errorMessage.width / 2;
							errorMessage.screenCenter(Y);
							errorMessages.add(errorMessage);
						case 1:
							errorMessage.x = (FlxG.width - FlxG.width / 4) - errorMessage.width / 2;
							errorMessage.y = (effectiveDownScroll ? FlxG.height - errorMessage.height : 0);
							errorMessages.add(errorMessage);
						case 2:
							errorMessage.x = (FlxG.width - FlxG.width / 4) - errorMessage.width / 2;
							errorMessage.y = (effectiveDownScroll ? 0 : FlxG.height - errorMessage.height);
							errorMessages.add(errorMessage);
						case 3:
							errorMessage.screenCenter(XY);
							errorMessages.add(errorMessage);
						case 4:
							errorMessage.x = 0;
							errorMessage.y = 0;
							FlxTween.circularMotion(errorMessage, FlxG.width / 2 - errorMessage.width / 2, FlxG.height / 2 - errorMessage.height / 2,
								errorMessage.width / 2, 0, true, 6, true, {
									onStart: function(_)
									{
										errorMessages.add(errorMessage);
									},
									type: LOOPING
								});
					}
				}

				ttl = 12;
				alwaysEnd = true;
				onEnd = function()
				{
					errorMessage.kill();
					errorMessages.remove(errorMessage);
					FlxDestroyUtil.destroy(errorMessage);
				}

			case 'mixup':
				mixUp();
				playSound = "mixup";
				ttl = 7;
				onEnd = function()
				{
					mixUp(true);
				}
			case 'ghost':
				for (daNote in unspawnNotes)
				{
					if (daNote == null)
						continue;
					if (daNote.strumTime >= Conductor.songPosition && !daNote.isSustainNote)
						daNote.doGhost();
					else if (daNote.strumTime >= Conductor.songPosition && daNote.isSustainNote)
						daNote.doGhost(daNote.rootNote.ghostSpeed, daNote.rootNote.ghostSine);
				}
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					if (!daNote.isSustainNote)
						daNote.doGhost();
					else if (daNote.isSustainNote)
						daNote.doGhost(daNote.rootNote.ghostSpeed, daNote.rootNote.ghostSine);
				}
				playSound = "ghost";
				playSoundVol = 0.5;
				ttl = 15;
				onEnd = function()
				{
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						if (daNote.strumTime >= Conductor.songPosition)
							daNote.undoGhost();
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						daNote.undoGhost();
					}
				};
			case 'wiggle':
				xWiggle = [0, 0, 0, 0];
				yWiggle = [0, 0, 0, 0];
				for (i in [xWiggleTween, yWiggleTween])
				{
					for (j in i)
					{
						if (j != null && j.active)
							j.cancel();
					}
				}

				var xFrom:Array<Float> = [0, 0, 0, 0];
				var xTo:Array<Float> = [0, 0, 0, 0];
				var yFrom:Array<Float> = [0, 0, 0, 0];
				var yTo:Array<Float> = [0, 0, 0, 0];
				var xTime:Array<Float> = [0, 0, 0, 0];
				var yTime:Array<Float> = [0, 0, 0, 0];
				var disableX = false;
				var disableY = false;
				var random = FlxG.random.int(0, 7);
				switch (random)
				{
					case 0:
						var ranTime = FlxG.random.float(0.3, 0.9);
						var ranMove = FlxG.random.float(25, 50);
						for (i in 0...xFrom.length)
							xFrom[i] = -ranMove;
						for (i in 0...xTo.length)
							xTo[i] = ranMove;
						for (i in 0...xTime.length)
							xTime[i] = ranTime;
						disableY = true;
					case 1:
						var ranTime = FlxG.random.float(0.3, 0.9);
						var ranMove = FlxG.random.float(25, 50);
						for (i in 0...yFrom.length)
							yFrom[i] = -ranMove;
						for (i in 0...yTo.length)
							yTo[i] = ranMove;
						for (i in 0...yTime.length)
							yTime[i] = ranTime;
						disableX = true;
					case 2:
						var ranTime = FlxG.random.float(0.3, 0.9);
						var ranMove = FlxG.random.float(25, 50);
						for (i in 0...xFrom.length)
							xFrom[i] = -ranMove;
						for (i in 0...xTo.length)
							xTo[i] = ranMove;
						for (i in 0...xTime.length)
							xTime[i] = ranTime;
						for (i in 0...yFrom.length)
							yFrom[i] = -ranMove * (i % 2 == 0 ? 1 : -1);
						for (i in 0...yTo.length)
							yTo[i] = ranMove * (i % 2 == 0 ? 1 : -1);
						for (i in 0...yTime.length)
							yTime[i] = ranTime;
					case 3:
						var ranTime = FlxG.random.float(0.3, 0.9);
						var ranMove = FlxG.random.float(25, 50);
						for (i in 0...xFrom.length)
							xFrom[i] = -ranMove * (i % 2 == 0 ? -1 : 1);
						for (i in 0...xTo.length)
							xTo[i] = ranMove * (i % 2 == 0 ? -1 : 1);
						for (i in 0...xTime.length)
							xTime[i] = ranTime;
						for (i in 0...yFrom.length)
							yFrom[i] = -ranMove;
						for (i in 0...yTo.length)
							yTo[i] = ranMove;
						for (i in 0...yTime.length)
							yTime[i] = ranTime;
					case 4:
						var ranTime = FlxG.random.float(0.3, 0.9);
						var ranMove = FlxG.random.float(25, 50);
						for (i in 0...xFrom.length)
							xFrom[i] = -ranMove * (i % 2 == 0 ? -1 : 1);
						for (i in 0...xTo.length)
							xTo[i] = ranMove * (i % 2 == 0 ? -1 : 1);
						for (i in 0...xTime.length)
							xTime[i] = ranTime;
						for (i in 0...yFrom.length)
							yFrom[i] = -ranMove * (i % 2 == 0 ? 1 : -1);
						for (i in 0...yTo.length)
							yTo[i] = ranMove * (i % 2 == 0 ? 1 : -1);
						for (i in 0...yTime.length)
							yTime[i] = ranTime;
					case 5:
						var ranTime = FlxG.random.float(0.3, 0.9);
						var ranMoveX = FlxG.random.float(25, 50);
						var ranMoveY = FlxG.random.float(25, 50);
						for (i in 0...xFrom.length)
							xFrom[i] = -ranMoveX * (i % 2 == 0 ? -1 : 1);
						for (i in 0...xTo.length)
							xTo[i] = ranMoveX * (i % 2 == 0 ? -1 : 1);
						for (i in 0...xTime.length)
							xTime[i] = ranTime;
						for (i in 0...yFrom.length)
							yFrom[i] = -ranMoveY;
						for (i in 0...yTo.length)
							yTo[i] = ranMoveY;
						for (i in 0...yTime.length)
							yTime[i] = ranTime;
					case 6:
						var ranTime = FlxG.random.float(0.3, 0.9);
						for (i in 0...xFrom.length)
							xFrom[i] = -FlxG.random.float(25, 50) * (i % 2 == 0 ? -1 : 1);
						for (i in 0...xTo.length)
							xTo[i] = FlxG.random.float(25, 50) * (i % 2 == 0 ? -1 : 1);
						for (i in 0...xTime.length)
							xTime[i] = ranTime;
						for (i in 0...yFrom.length)
							yFrom[i] = -FlxG.random.float(25, 50) * (i % 2 == 0 ? 1 : -1);
						for (i in 0...yTo.length)
							yTo[i] = FlxG.random.float(25, 50) * (i % 2 == 0 ? 1 : -1);
						for (i in 0...yTime.length)
							yTime[i] = ranTime;
					case 7:
						var ranTime = FlxG.random.float(0.3, 0.9);
						for (i in 0...xFrom.length)
							xFrom[i] = FlxG.random.float(25, 50) * (FlxG.random.bool() ? 1 : -1);
						for (i in 0...xTo.length)
							xTo[i] = FlxG.random.float(25, 50) * (FlxG.random.bool() ? 1 : -1);
						for (i in 0...xTime.length)
							xTime[i] = ranTime;
						for (i in 0...yFrom.length)
							yFrom[i] = -FlxG.random.float(25, 50) * (FlxG.random.bool() ? 1 : -1);
						for (i in 0...yTo.length)
							yTo[i] = FlxG.random.float(25, 50) * (FlxG.random.bool() ? 1 : -1);
						for (i in 0...yTime.length)
							yTime[i] = ranTime;
				}

				for (i in 0...xWiggleTween.length)
				{
					if (!disableX)
					{
						xWiggleTween[i] = FlxTween.num(xFrom[i], xTo[i], xTime[i], {
							onUpdate: function(tween)
							{
								xWiggle[i] = cast(tween, NumTween).value;
							},
							type: PINGPONG
						});
					}
					if (!disableY)
					{
						yWiggleTween[i] = FlxTween.num(yFrom[i], yTo[i], yTime[i], {
							onUpdate: function(tween)
							{
								yWiggle[i] = cast(tween, NumTween).value;
							},
							type: PINGPONG
						});
					}
				}

				playSound = "wiggle";

				ttl = 20;
				onEnd = function()
				{
					xWiggle = [0, 0, 0, 0];
					yWiggle = [0, 0, 0, 0];

					for (i in [xWiggleTween, yWiggleTween])
					{
						for (j in i)
						{
							if (j != null && j.active)
								j.cancel();
						}
					}
				}
			case 'flashbang':
				playSound = "bang";
				if (flashbangTimer != null && flashbangTimer.active)
					flashbangTimer.cancel();
				var whiteScreen:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
				whiteScreen.scrollFactor.set();
				whiteScreen.cameras = [camUnderTop];
				add(whiteScreen);
				flashbangTimer.start(0.4, function(timer)
				{
					camUnderTop.flash(FlxColor.WHITE, 7, null, true);
					remove(whiteScreen);
					FlxG.sound.play('assets/sounds/ringing' + TitleState.soundExt, 0.4);
				});

			case 'nostrum':
				playerStrums.forEach(function(sprite)
				{
					sprite.visible = false;
				});
				playSound = "nostrum";
				ttl = 13;
				onEnd = function()
				{
					playerStrums.forEach(function(sprite)
					{
						sprite.visible = true;
					});
				}
			case 'jackspam':
				var startingPoint = FlxG.random.int(5, 9);
				var endingPoint = FlxG.random.int(startingPoint + 6, startingPoint + 12);
				var dataPicked = FlxG.random.int(0, 3);
				for (i in startingPoint...endingPoint)
				{
					addNote(0, i, i, dataPicked);
				}
			case 'spam':
				var startingPoint = FlxG.random.int(5, 9);
				var endingPoint = FlxG.random.int(startingPoint + 5, startingPoint + 10);
				for (i in startingPoint...endingPoint)
				{
					addNote(0, i, i);
				}
			case 'sever':
				var chooseFrom:Array<Int> = [];
				for (i in 0...severInputs.length)
				{
					if (!severInputs[i])
						chooseFrom.push(i);
				}

				var picked:Int = 0;
				if (chooseFrom.length <= 0)
					picked = FlxG.random.int(0, 3);
				else
					picked = chooseFrom[FlxG.random.int(0, chooseFrom.length - 1)];
				playerStrums.members[picked].alpha = 0;
				severInputs[picked] = true;

				var okayden:Array<Int> = [];
				for (i in 0...64)
				{
					okayden.push(i);
				}
				var explosion = new FlxSprite().loadGraphic("assets/images/explosion.png", true, 256, 256);
				explosion.animation.add("boom", okayden, 60, false);
				explosion.animation.finishCallback = function(name)
				{
					explosion.visible = false;
					explosion.kill();
					remove(explosion);
					FlxDestroyUtil.destroy(explosion);
				};
				explosion.cameras = [camHUD];
				explosion.x = playerStrums.members[picked].x + playerStrums.members[picked].width / 2 - explosion.width / 2;
				explosion.y = playerStrums.members[picked].y + playerStrums.members[picked].height / 2 - explosion.height / 2;
				explosion.animation.play("boom", true);
				add(explosion);

				playSound = "sever";
				ttl = 6;
				alwaysEnd = true;
				onEnd = function()
				{
					playerStrums.members[picked].alpha = 1;
					severInputs[picked] = false;
				}
			case 'shake':
				playSound = "shake";
				playSoundVol = 0.5;
				camHUD.shake(FlxG.random.float(0.03, 0.06), 9, null, true);
				camNotes.shake(FlxG.random.float(0.03, 0.06), 9, null, true);
			case 'poison':
				drainHealth = true;
				playSound = "poison";
				playSoundVol = 0.6;
				ttl = 5;
				boyfriend.color = 0xf003fc;
				onEnd = function()
				{
					drainHealth = false;
					boyfriend.color = 0xffffff;
				}
			case 'dizzy':
				if (effectsActive[effect] == null || effectsActive[effect] <= 0)
				{
					if (drunkTween != null && drunkTween.active)
					{
						drunkTween.cancel();
						FlxDestroyUtil.destroy(drunkTween);
					}
					drunkTween = FlxTween.num(0, 24, FlxG.random.float(1.2, 1.4), {
						onUpdate: function(tween)
						{
							camNotes.angle = (tween.executions % 4 > 1 ? 1 : -1) * cast(tween, NumTween).value + camAngle;
							camHUD.angle = (tween.executions % 4 > 1 ? 1 : -1) * cast(tween, NumTween).value + camAngle;
							camGame.angle = (tween.executions % 4 > 1 ? -1 : 1) * cast(tween, NumTween).value / 2 + camAngle;
						},
						type: PINGPONG
					});
				}

				playSound = "dizzy";
				ttl = 8;
				onEnd = function()
				{
					if (drunkTween != null && drunkTween.active)
					{
						drunkTween.cancel();
						FlxDestroyUtil.destroy(drunkTween);
					}
					camNotes.angle = camAngle;
					camHUD.angle = camAngle;
					camGame.angle = camAngle;
				}
			case 'noise':
				var noisysound:String = "";
				var noisysoundVol:Float = 1.0;
				switch (FlxG.random.int(0, 9))
				{
					case 0:
						noisysound = "dialup";
						noisysoundVol = 0.5;
					case 1:
						noisysound = "crowd";
						noisysoundVol = 0.3;
					case 2:
						noisysound = "airhorn";
						noisysoundVol = 0.6;
					case 3:
						noisysound = "copter";
						noisysoundVol = 0.5;
					case 4:
						noisysound = "magicmissile";
						noisysoundVol = 0.9;
					case 5:
						noisysound = "ping";
						noisysoundVol = 1.0;
					case 6:
						noisysound = "call";
						noisysoundVol = 1.0;
					case 7:
						noisysound = "knock";
						noisysoundVol = 1.0;
					case 8:
						noisysound = "fuse";
						noisysoundVol = 0.7;
					case 9:
						noisysound = "hallway";
						noisysoundVol = 0.9;
				}
				noiseSound.stop();
				noiseSound.loadEmbedded('assets/sounds/' + noisysound + TitleState.soundExt);
				noiseSound.volume = noisysoundVol;
				noiseSound.play(true);

			case 'flip':
				playSound = "flip";
				ttl = 5;
				camAngle = 180;
				camNotes.angle = camAngle;
				camHUD.angle = camAngle;
				camGame.angle = camAngle;
				onEnd = function()
				{
					camAngle = 0;
					camNotes.angle = camAngle;
					camHUD.angle = camAngle;
					camGame.angle = camAngle;
				}
			case 'invuln':
				playSound = "invuln";
				playSoundVol = 0.5;
				ttl = 5;
				if (boyfriend.curCharacter.contains("pixel"))
				{
					shieldSprite.x = boyfriend.x + boyfriend.width / 2 - shieldSprite.width / 2 - 150;
					shieldSprite.y = boyfriend.y + boyfriend.height / 2 - shieldSprite.height / 2 - 150;
				}
				else
				{
					shieldSprite.x = boyfriend.x + boyfriend.width / 2 - shieldSprite.width / 2;
					shieldSprite.y = boyfriend.y + boyfriend.height / 2 - shieldSprite.height / 2;
				}
				shieldSprite.visible = true;
				dmgMultiplier = 0;
				onEnd = function()
				{
					shieldSprite.visible = false;
					dmgMultiplier = 1.0;
				}

			// DD: Eh, maybe not this one. It disrupts the flow of the song.
			// case 'desync':
			// 	playSound = "delay";
			// 	delayOffset = FlxG.random.int(Std.int(Conductor.stepCrochet), Std.int(Conductor.stepCrochet)*3);
			// 	musicThing.time -= delayOffset;
			// 	resyncVocals();

			// 	ttl = 8;
			// 	onEnd = function()
			// 	{
			// 		musicThing.time += delayOffset;
			// 		delayOffset = 0;
			// 	}

			// DD: I don't like this one either.
			// case 'mute':
			// 	playSound = "delay";
			// 	volumeMultiplier = 0;
			// 	vocals.volume = 0;
			// 	ttl = 8;
			// 	onEnd = function()
			// 	{
			// 		volumeMultiplier = 1;
			// 	}

			case 'ice':
				var startPoint:Int = FlxG.random.int(5, 9);
				var nextPoint:Int = FlxG.random.int(startPoint + 2, startPoint + 6);
				var lastPoint:Int = FlxG.random.int(nextPoint + 2, nextPoint + 6);
				addNote(4, startPoint, startPoint, -1);
				addNote(4, nextPoint, nextPoint, -1);
				addNote(4, lastPoint, lastPoint, -1);

			case 'randomize':
				var available = [0, 1, 2, 3];
				FlxG.random.shuffle(available);
				switch (available)
				{
					case [0, 1, 2, 3]:
						available = [3, 2, 1, 0];
					default:
				}

				for (daNote in unspawnNotes)
				{
					if (daNote == null)
						continue;
					if (daNote.strumTime >= Conductor.songPosition)
					{
						daNote.noteData = available[daNote.noteData];
						daNote.refreshSprite();
					}
				}
				for (daNote in notes)
				{
					if (daNote == null)
						continue;
					else
					{
						daNote.noteData = available[daNote.noteData];
						daNote.refreshSprite();
					}
				}

				playSound = "randomize";
				playSoundVol = 0.7;
				ttl = 10;
				onEnd = function()
				{
					for (daNote in unspawnNotes)
					{
						if (daNote == null)
							continue;
						if (daNote.strumTime >= Conductor.songPosition)
						{
							daNote.noteData = daNote.trueNoteData;
							daNote.refreshSprite();
						}
					}
					for (daNote in notes)
					{
						if (daNote == null)
							continue;
						else
						{
							daNote.noteData = daNote.trueNoteData;
							daNote.refreshSprite();
						}
					}
				}

			case 'fakeheal':
				addNote(5, 5, 9);

			case 'spell':
				var spellThing = new SpellPrompt();
				spellPrompts.push(spellThing);
				playSound = "spell";
				playSoundVol = 0.66;

			case 'terminate':
				terminateStep = 3;

			default:
				return;
		}

		effectsActive[effect] = (effectsActive[effect] == null ? 0 : effectsActive[effect] + 1);

		if (playSound != "")
		{
			FlxG.sound.play('assets/sounds/' + playSound + TitleState.soundExt, playSoundVol);
		}

		new FlxTimer().start(ttl, function(tmr:FlxTimer)
		{
			effectsActive[effect]--;
			if (effectsActive[effect] < 0)
				effectsActive[effect] = 0;

			if (onEnd != null && (effectsActive[effect] <= 0 || alwaysEnd))
				onEnd();

			FlxDestroyUtil.destroy(tmr);
		});

		if (Assets.exists("assets/images/icons/" + effect + ".png"))
		{
			if (lagOn)
			{
				var icon = new FlxSprite().loadGraphic("assets/images/icons/" + effect + ".png");
				icon.cameras = [camTop];
				icon.screenCenter(X);
				icon.y = (effectiveDownScroll ? FlxG.height - icon.height - 10 : 10);
				add(icon);
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					icon.kill();
					remove(icon);
					FlxDestroyUtil.destroy(icon);
					FlxDestroyUtil.destroy(tmr);
				});
			}
			else
			{
				var icon = new FlxSprite().loadGraphic("assets/images/icons/" + effect + ".png");
				icon.cameras = [camTop];
				icon.screenCenter(X);
				icon.y = (effectiveDownScroll ? FlxG.height - icon.frameHeight - 10 : 10);
				icon.scale.x = icon.scale.y = 0.5;
				icon.updateHitbox();
				FlxTween.tween(icon, {"scale.x": 1, "scale.y": 1}, 0.1, {
					onUpdate: function(tween)
					{
						icon.updateHitbox();
						icon.screenCenter(X);
						icon.y = (effectiveDownScroll ? FlxG.height - icon.frameHeight - 10 : 10);
					}
				});
				add(icon);
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					icon.kill();
					remove(icon);
					FlxDestroyUtil.destroy(icon);
					FlxDestroyUtil.destroy(tmr);
				});
			}
		}

		resetChatData();
	}

	function addNote(type:Int = 0, min:Int = 0, max:Int = 0, ?specificData:Int)
	{
		if (startingSong)
			return;
		var pickSteps = FlxG.random.int(min, max);
		var pickTime = Conductor.songPosition + pickSteps * Conductor.stepCrochet;
		var pickData:Int = 0;

		if (SONG.notes.length <= Math.floor((curStep + pickSteps + 1) / 16))
			return;

		if (SONG.notes[Math.floor((curStep + pickSteps + 1) / 16)] == null)
			return;

		if (specificData == null)
		{
			if (SONG.notes[Math.floor((curStep + pickSteps + 1) / 16)].mustHitSection)
			{
				pickData = FlxG.random.int(0, 3);
			}
			else
			{
				// pickData = FlxG.random.int(4, 7);
				pickData = FlxG.random.int(0, 3);
			}
		}
		else if (specificData == -1)
		{
			var chooseFrom:Array<Int> = [];
			for (i in 0...severInputs.length)
			{
				if (!severInputs[i])
					chooseFrom.push(i);
			}

			if (chooseFrom.length <= 0)
				pickData = FlxG.random.int(0, 3);
			else
				pickData = chooseFrom[FlxG.random.int(0, chooseFrom.length - 1)];
		}
		else
		{

			if (SONG.notes[Math.floor((curStep + pickSteps + 1) / 16)].mustHitSection)
			{
				pickData = specificData % 4;
			}
			else
			{
				// pickData = specificData % 4 + 4;
				pickData = specificData % 4;
			}
		}
		var swagNote:Note = new Note(pickTime, pickData, false, null, false, null, type);
		swagNote.mustPress = true;
		swagNote.x += FlxG.width / 2;
		unspawnNotes.push(swagNote);
		unspawnNotes.sort(sortByShit);
	}

	function updateScrollUI()
	{
		strumLine.y = (effectiveDownScroll ? 570 : 30);
		healthBarBG.y = (effectiveDownScroll ? FlxG.height * 0.1 : FlxG.height * 0.875);
		healthBar.y = healthBarBG.y + 4;
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		strumLineNotes.forEach(function(sprite)
		{
			sprite.y = strumLine.y;
		});
		scoreTxt.y = (effectiveDownScroll ? FlxG.height * 0.1 - 72 : FlxG.height * 0.9 + 36);
	}

	var strumTweens:Array<FlxTween> = new Array<FlxTween>();

	function mixUp(reset:Bool = false)
	{
		var available = [0, 1, 2, 3];
		if (!reset)
		{
			FlxG.random.shuffle(available);
			switch (available)
			{
				case [0, 1, 2, 3]:
					available = [3, 2, 1, 0];
				default:
			}
		}

		notePositions = available;

		playerStrums.forEach(function(sprite)
		{
			if (strumTweens[sprite.ID] != null && strumTweens[sprite.ID].active)
				strumTweens[sprite.ID].cancel();
			strumTweens[sprite.ID] = FlxTween.tween(sprite, {x: 50 + Note.swagWidth * notePositions[sprite.ID] + 50 + (FlxG.width / 2)}, 0.25);
		});
		for (daNote in unspawnNotes)
		{
			if (daNote == null)
				continue;
			if (daNote.strumTime >= Conductor.songPosition && daNote.mustPress)
			{
				daNote.swapPositions();
			}
		}
		for (daNote in notes)
		{
			if (daNote == null)
				continue;
			if (daNote.mustPress)
			{
				daNote.swapPositions();
			}
		}
	}

	public function endSong():Void
	{
		if (endingSong)
			return;

		if (effectTimer != null && effectTimer.active)
			effectTimer.cancel();

		canPause = false;
		endingSong = true;
		musicThing.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic("assets/music/klaskiiLoop.ogg", 0.75);

				PlayerSettings.menuControls();
				// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
				// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

				FlxG.switchState(new StoryMenuState());
				sectionStart = false;

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play('assets/sounds/Lights_Shut_off' + TitleState.soundExt);
				}

				if (SONG.song.toLowerCase() == 'senpai')
				{
					transIn = null;
					transOut = null;
					prevCamFollow = camFollow;
				}

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				musicThing.pause();

				FlxG.switchState(new PlayState());

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
			}
		}
		else
		{
			PlayerSettings.menuControls();
			sectionStart = false;
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			// FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1 * volumeMultiplier;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * Conductor.shitZone)
		{
			daRating = 'shit';
			if (Config.accuracy == "complex")
			{
				totalNotesHit += 1 - Conductor.shitZone;
			}
			else
			{
				totalNotesHit += 1;
			}
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * Conductor.badZone)
		{
			daRating = 'bad';
			score = 100;
			if (Config.accuracy == "complex")
			{
				totalNotesHit += 1 - Conductor.badZone;
			}
			else
			{
				totalNotesHit += 1;
			}
		}
		else if (noteDiff > Conductor.safeZoneOffset * Conductor.goodZone)
		{
			daRating = 'good';
			if (Config.accuracy == "complex")
			{
				totalNotesHit += 1 - Conductor.goodZone;
			}
			else
			{
				totalNotesHit += 1;
			}
			score = 200;
		}
		if (daRating == 'sick')
			totalNotesHit += 1;

		// trace('hit ' + daRating);

		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic('assets/images/' + pixelShitPart1 + daRating + pixelShitPart2 + ".png");
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + pixelShitPart1 + 'combo' + pixelShitPart2 + '.png');
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2 + '.png');
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	public function keyDown(evt:KeyboardEvent):Void
	{
		if (skipListener)
		{
			return;
		}

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		switch (data)
		{
			case 0:
				if (leftHold)
				{
					return;
				}
				leftPress = true;
				leftHold = true;
			case 1:
				if (downHold)
				{
					return;
				}
				downPress = true;
				downHold = true;
			case 2:
				if (upHold)
				{
					return;
				}
				upPress = true;
				upHold = true;
			case 3:
				if (rightHold)
				{
					return;
				}
				rightPress = true;
				rightHold = true;
		}
	}

	public function keyUp(evt:KeyboardEvent):Void
	{
		if (skipListener)
		{
			return;
		}

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		switch (data)
		{
			case 0:
				leftRelease = true;
				leftHold = false;
			case 1:
				downRelease = true;
				downHold = false;
			case 2:
				upRelease = true;
				upHold = false;
			case 3:
				rightRelease = true;
				rightHold = false;
		}
	}

	private function keyCheck():Void
	{
		upTime = controls.UP ? upTime + 1 : 0;
		downTime = controls.DOWN ? downTime + 1 : 0;
		leftTime = controls.LEFT ? leftTime + 1 : 0;
		rightTime = controls.RIGHT ? rightTime + 1 : 0;

		upPress = upTime == 1;
		downPress = downTime == 1;
		leftPress = leftTime == 1;
		rightPress = rightTime == 1;

		upRelease = upHold && upTime == 0;
		downRelease = downHold && downTime == 0;
		leftRelease = leftHold && leftTime == 0;
		rightRelease = rightHold && rightTime == 0;

		upHold = upTime > 0;
		downHold = downTime > 0;
		leftHold = leftTime > 0;
		rightHold = rightTime > 0;

		/*THE FUNNY 4AM CODE!
			trace((leftHold?(leftPress?"^":"|"):(leftRelease?"^":" "))+(downHold?(downPress?"^":"|"):(downRelease?"^":" "))+(upHold?(upPress?"^":"|"):(upRelease?"^":" "))+(rightHold?(rightPress?"^":"|"):(rightRelease?"^":" ")));
			I should probably remove this from the code because it literally serves no purpose, but I'm gonna keep it in because I think it's funny.
			It just sorta prints 4 lines in the console that look like the arrows being pressed. Looks something like this:
			====
			^  | 
			| ^|
			| |^
			^ |
			==== */
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		var possibleNotes:Array<Note> = [];
		// var ignoreList:Array<Int> = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
			{
				// the sorting probably doesn't need to be in here? who cares lol
				possibleNotes.push(daNote);
				// possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
				haxe.ds.ArraySort.sort(possibleNotes, (a, b) -> Std.int(a.strumTime - b.strumTime));
				// ignoreList.push(daNote.noteData);
			}
		});

		var severIndex = -1;
		var severArray = [2, 3, 1, 0];
		for (checkThisChucklenuts in [upP, rightP, downP, leftP])
		{
			severIndex++;
			if (severInputs[severArray[severIndex]])
				continue;

			if (frozenInput > 0)
				continue;

			if (checkThisChucklenuts /*&& !boyfriend.stunned*/ && generatedMusic)
			{
				boyfriend.holdTimer = 0;
				if (possibleNotes.length > 0)
				{
					// var daNote = possibleNotes[0];
					var goodEnough:Bool = false;
					var goodEnoughIndex:Array<Int> = [];
					for (i in 0...possibleNotes.length)
					{
						if (controlArray[possibleNotes[i].noteData])
						{
							if (!goodEnough || (goodEnough && possibleNotes[i].strumTime == possibleNotes[goodEnoughIndex[0]].strumTime))
							{
								goodEnoughIndex.push(i);
								goodNoteHit(possibleNotes[i]);
								goodEnough = true;
							}
						}
					}
					for (i in goodEnoughIndex)
					{
						possibleNotes.remove(possibleNotes[i]);
					}
				}
				else
				{
					badNoteCheck();
				}
			}
		}

		if (FlxG.keys.justPressed.SPACE && terminateTimestamps.length > 0 && !terminateCooldown)
		{
			boyfriend.playAnim('dodge', true);
			terminateCooldown = true;

			for (i in 0...terminateTimestamps.length)
			{
				if (!terminateTimestamps[i].alive || terminateTimestamps[i] == null)
					continue;

				if (terminateTimestamps[i].alive && terminateTimestamps[i].canBeHit)
				{
					terminateTimestamps[i].wasGoodHit = true;
					terminateTimestamps[i].kill();
					terminateTimestamps.resize(0);
				}
			}

			new FlxTimer().start(Conductor.stepCrochet * 2 / 1000, function(tmr)
			{
				terminateCooldown = false;
				FlxDestroyUtil.destroy(tmr);
			});
		}

		var severIndex = -1;
		var severArray = [2, 3, 1, 0];
		var keyLock = [false, false, false, false];
		for (checkThisChucklenuts in [up, right, down, left])
		{
			severIndex++;
			if (severInputs[severArray[severIndex]])
				continue;

			if (frozenInput > 0)
				continue;

			if (checkThisChucklenuts /*&& !boyfriend.stunned*/ && generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
					{
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 0:
								if (left && !keyLock[0])
								{
									keyLock[0] = true;
									goodNoteHit(daNote);
								}
							case 1:
								if (down && !keyLock[1])
								{
									keyLock[1] = true;
									goodNoteHit(daNote);
								}
							case 2:
								if (up && !keyLock[2])
								{
									keyLock[2] = true;
									goodNoteHit(daNote);
								}
							case 3:
								if (right && !keyLock[3])
								{
									keyLock[3] = true;
									goodNoteHit(daNote);
								}
						}
					}
				});
			}
		}

		notes.forEachAlive(function(daNote:Note)
		{
			// Guitar Hero Type Held Notes
			if (daNote.isSustainNote && daNote.mustPress)
			{
				if (daNote.prevNote.tooLate && !daNote.prevNote.wasGoodHit)
				{
					daNote.tooLate = true;
					daNote.kill();
				}

				if (daNote.prevNote.wasGoodHit && !daNote.wasGoodHit)
				{
					switch (daNote.noteData)
					{
						case 0:
							if (leftRelease)
							{
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								vocals.volume = 0;
								daNote.tooLate = true;
								daNote.kill();
								boyfriend.holdTimer = 0;
							}
						case 1:
							if (downRelease)
							{
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								vocals.volume = 0;
								daNote.tooLate = true;
								daNote.kill();
								boyfriend.holdTimer = 0;
							}
						case 2:
							if (upRelease)
							{
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								vocals.volume = 0;
								daNote.tooLate = true;
								daNote.kill();
								boyfriend.holdTimer = 0;
							}
						case 3:
							if (rightRelease)
							{
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								vocals.volume = 0;
								daNote.tooLate = true;
								daNote.kill();
								boyfriend.holdTimer = 0;
							}
					}
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !upHold && !downHold && !rightHold && !leftHold)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing'))
				boyfriend.idleEnd();
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 2:
					if (upPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!upHold)
						spr.animation.play('static');
				case 3:
					if (rightPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!rightHold)
						spr.animation.play('static');
				case 1:
					if (downPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!downHold)
						spr.animation.play('static');
				case 0:
					if (leftPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!leftHold)
						spr.animation.play('static');
			}

			switch (spr.animation.curAnim.name)
			{
				case "confirm":
					// spr.alpha = 1;
					spr.centerOffsets();

					if (!curStage.startsWith('school'))
					{
						spr.offset.x -= 14;
						spr.offset.y -= 14;
					}

				/*case "static":
					spr.alpha = 0.5; //Might mess around with strum transparency in the future or something.
					spr.centerOffsets(); */

				default:
					// spr.alpha = 1;
					spr.centerOffsets();
			}

			additionalOffset(spr);
		});
	}

	function additionalOffset(spr:FlxSprite)
	{
		spr.offset.x += xWiggle[spr.ID % 4];
		spr.offset.y += yWiggle[spr.ID % 4];
	}

	private function keyShitAuto():Void
	{
		var hitNotes:Array<Note> = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.mustPress && daNote.strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.125)
			{
				hitNotes.push(daNote);
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !upHold && !downHold && !rightHold && !leftHold)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing'))
				boyfriend.idleEnd();
		}

		for (x in hitNotes)
		{
			boyfriend.holdTimer = 0;

			goodNoteHit(x);

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(x.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 14;
						spr.offset.y -= 14;
					}
					else
						spr.centerOffsets();

					additionalOffset(spr);
				}
			});
		}
	}

	function noteMiss(direction:Int = 1, ?healthLoss:Float = 0.04, ?playAudio:Bool = true, ?skipInvCheck:Bool = false, isAlert:Bool = false):Void
	{
		if (!boyfriend.stunned && !startingSong && (!boyfriend.invuln || skipInvCheck))
		{
			health -= healthLoss * Config.healthDrainMultiplier * dmgMultiplier;
			if (combo > 5)
			{
				gf.playAnim('sad');
			}
			misses += 1;
			combo = 0;

			songScore -= 100;

			if (playAudio)
			{
				FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));
			}

			if (isAlert)
			{
				FlxG.sound.play('assets/sounds/warning' + TitleState.soundExt);
				var fist:FlxSprite = new FlxSprite().loadGraphic("assets/images/thepunch.png");
				fist.x = FlxG.width / camGame.zoom;
				fist.y = boyfriend.y + boyfriend.height / 2 - fist.height / 2;
				add(fist);
				FlxTween.tween(fist, {x: boyfriend.x + boyfriend.frameWidth / 2}, 0.1, {
					onComplete: function(tween)
					{
						if (tween.executions >= 2)
						{
							fist.kill();
							FlxDestroyUtil.destroy(fist);
							tween.cancel();
							FlxDestroyUtil.destroy(tween);
						}
					},
					type: PINGPONG
				});
			}
			// FlxG.sound.play('assets/sounds/missnote1' + TitleState.soundExt, 1, false);
			// FlxG.log.add('played imss note');

			setBoyfriendInvuln(5 / 60);

			if (boyfriend.canAutoAnim)
			{
				if (isAlert)
				{
					boyfriend.playAnim('hit', true);
				}
				else
				{
					switch (direction)
					{
						case 2:
							boyfriend.playAnim('singUPmiss', true);
						case 3:
							boyfriend.playAnim('singRIGHTmiss', true);
						case 1:
							boyfriend.playAnim('singDOWNmiss', true);
						case 0:
							boyfriend.playAnim('singLEFTmiss', true);
					}
				}
			}

			updateAccuracy();
		}

		if (Main.flippymode)
		{
			System.exit(0);
		}
	}

	function noteMissWrongPress(direction:Int = 1, ?healthLoss:Float = 0.0475, dropCombo:Bool = false):Void
	{
		if (!startingSong && !boyfriend.invuln)
		{
			health -= healthLoss * Config.healthDrainMultiplier * dmgMultiplier;

			if (dropCombo)
			{
				if (combo > 5)
				{
					gf.playAnim('sad');
				}
				combo = 0;
			}

			songScore -= 25;

			FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));

			// FlxG.sound.play('assets/sounds/missnote1' + TitleState.soundExt, 1, false);
			// FlxG.log.add('played imss note');

			setBoyfriendInvuln(4 / 60);

			if (boyfriend.canAutoAnim)
			{
				switch (direction)
				{
					case 2:
						boyfriend.playAnim('singUPmiss', true);
					case 3:
						boyfriend.playAnim('singRIGHTmiss', true);
					case 1:
						boyfriend.playAnim('singDOWNmiss', true);
					case 0:
						boyfriend.playAnim('singLEFTmiss', true);
				}
			}
		}
	}

	function badNoteCheck()
	{
		if (Config.ghostTapType > 0 && !canHit)
		{
		}
		else
		{
			if (leftPress)
				noteMissWrongPress(0);
			if (upPress)
				noteMissWrongPress(2);
			if (rightPress)
				noteMissWrongPress(3);
			if (downPress)
				noteMissWrongPress(1);
		}
	}

	function setBoyfriendInvuln(time:Float = 5 / 60)
	{
		invulnCount++;
		var invulnCheck = invulnCount;

		boyfriend.invuln = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if (invulnCount == invulnCheck)
			{
				boyfriend.invuln = false;
			}
		});
	}

	function setCanMiss(time:Float = 10 / 60)
	{
		noMissCount++;
		var noMissCheck = noMissCount;

		canHit = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if (noMissCheck == noMissCount)
			{
				canHit = false;
			}
		});
	}

	function setBoyfriendStunned(time:Float = 5 / 60)
	{
		boyfriend.stunned = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			boyfriend.stunned = false;
		});
	}

	function goodNoteHit(note:Note):Void
	{
		if (note.specialNote)
		{
			specialNoteHit(note);
			return;
		}

		// Guitar Hero Styled Hold Notes
		if (note.isSustainNote && !note.prevNote.wasGoodHit)
		{
			noteMiss(note.noteData, 0.05, true, true);
			note.prevNote.tooLate = true;
			note.prevNote.kill();
			vocals.volume = 0;
		}
		else if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
			}
			else
				totalNotesHit += 1;

			if (note.noteData >= 0)
			{
				health += 0.015 * Config.healthMultiplier;
			}
			else
			{
				health += 0.0015 * Config.healthMultiplier;
			}

			if (boyfriend.canAutoAnim)
			{
				switch (note.noteData)
				{
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 0:
						boyfriend.playAnim('singLEFT', true);
				}
			}

			if (!note.isSustainNote)
			{
				setBoyfriendInvuln(2.5 / 60);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1 * volumeMultiplier;

			if (!note.isSustainNote)
			{
				note.kill();
			}

			updateAccuracy();
		}
	}

	function specialNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (note.isMine || note.isFakeHeal)
			{
				misses++;
				health -= FlxG.random.float(0.25, 0.5) * dmgMultiplier;
				if (note.isMine)
					FlxG.sound.play('assets/sounds/mine' + TitleState.soundExt);
				else if (note.isFakeHeal)
					FlxG.sound.play('assets/sounds/fakeheal' + TitleState.soundExt);
				var nope:FlxSprite = new FlxSprite(0, 0);
				nope.loadGraphic("assets/images/cross.png");
				nope.setGraphicSize(Std.int(nope.width * 4));
				nope.angle = 45;
				nope.updateHitbox();
				nope.alpha = 0.8;
				nope.cameras = [camNotes];

				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						nope.x = (spr.x + spr.width / 2) - nope.width / 2;
						nope.y = (spr.y + spr.height / 2) - nope.height / 2;
					}
				});

				add(nope);

				FlxTween.tween(nope, {alpha: 0}, 1, {
					onComplete: function(tween)
					{
						nope.kill();
						remove(nope);
						nope.destroy();
					}
				});
			}
			else if (note.isFreeze)
			{
				misses++;
				FlxG.sound.play('assets/sounds/freeze' + TitleState.soundExt);
				frozenInput++;
				playerStrums.forEach(function(sprite)
				{
					sprite.color = 0x0073b5;
				});
				new FlxTimer().start(2, function(timer)
				{
					frozenInput--;
					if (frozenInput <= 0)
					{
						playerStrums.forEach(function(sprite)
						{
							sprite.color = 0xffffff;
						});
					}
					FlxDestroyUtil.destroy(timer);
				});
			}
			else if (note.isAlert)
			{
				FlxG.sound.play('assets/sounds/dodge' + TitleState.soundExt);
				boyfriend.playAnim('dodge', true);
			}
			else if (note.isHeal)
			{
				health += FlxG.random.float(0.3, 0.6);
				FlxG.sound.play('assets/sounds/heal' + TitleState.soundExt);
				boyfriend.playAnim('hey', true);
			}

			if (boyfriend.canAutoAnim && !note.isAlert && !note.isHeal)
			{
				switch (note.noteData)
				{
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 0:
						boyfriend.playAnim('singLEFT', true);
				}
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1 * volumeMultiplier;

			if (!note.isSustainNote)
			{
				note.kill();
			}

			updateAccuracy();
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play('assets/sounds/carPass' + FlxG.random.int(0, 1) + TitleState.soundExt, 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play('assets/sounds/thunder_' + FlxG.random.int(1, 2) + TitleState.soundExt);
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		if (SONG.needsVoices)
		{
			if (vocals.time > Conductor.songPosition + 20 + delayOffset || vocals.time < Conductor.songPosition - 20 - delayOffset)
			{
				resyncVocals();
			}
		}

		/*if (dad.curCharacter == 'spooky' && totalSteps % 4 == 2)
			{
				// dad.dance();
		}*/

		super.stepHit();
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		// wiggleShit.update(Conductor.crochet);
		super.beatHit();

		if (curBeat % 4 == 0)
		{
			var sec = Math.floor(curBeat / 4);
			if (sec >= sectionHaveNotes.length)
			{
				sec = -1;
			}

			sectionHasBFNotes = sec >= 0 ? sectionHaveNotes[sec][0] : false;
			sectionHasOppNotes = sec >= 0 ? sectionHaveNotes[sec][1] : false;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			else
				Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (!sectionHasOppNotes)
				if (dadBeats.contains(curBeat % 4) && dad.canAutoAnim)
					dad.dance();
		}
		else
		{
			if (dadBeats.contains(curBeat % 4))
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat <= 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			uiBop(0.015, 0.03);
		}

		if (curSong.toLowerCase() == 'milf' && curBeat == 168)
		{
			dadBeats = [0, 1, 2, 3];
			bfBeats = [0, 1, 2, 3];
		}

		if (curSong.toLowerCase() == 'milf' && curBeat == 200)
		{
			dadBeats = [0, 2];
			bfBeats = [1, 3];
		}

		if (curBeat % (4 * bopSpeed) == 0 && camZooming)
		{
			uiBop();
		}

		if (curBeat % bopSpeed == 0)
		{
			iconP1.iconScale = iconP1.defualtIconScale * 1.25;
			iconP2.iconScale = iconP2.defualtIconScale * 1.25;

			iconP1.tweenToDefaultScale(0.2, FlxEase.quintOut);
			iconP2.tweenToDefaultScale(0.2, FlxEase.quintOut);

			gf.dance();
		}

		if (bfBeats.contains(curBeat % 4) && boyfriend.canAutoAnim)
			boyfriend.dance();

		if (totalBeats % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		switch (curStage)
		{
			case "school":
				bgGirls.dance();

			case "mall":
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case "limo":
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();

			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (totalBeats % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (totalBeats % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == "spooky" && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}

		switch (terminateStep)
		{
			case 3:
				var terminate = new TerminateTimestamp(Math.floor(Conductor.songPosition / Conductor.crochet) * Conductor.crochet + Conductor.crochet * 3);
				add(terminate);
				terminateTimestamps.push(terminate);
				terminateStep--;
			case 2 | 1 | 0:
				terminateMessage.loadGraphic("assets/images/terminate" + terminateStep + ".png");
				terminateMessage.screenCenter(XY);
				terminateMessage.cameras = [camTop];
				terminateMessage.visible = true;
				if (terminateStep > 0)
				{
					terminateSound.volume = 0.6;
					terminateSound.play(true);
				}
				else if (terminateStep == 0)
				{
					FlxG.sound.play('assets/sounds/beep2' + TitleState.soundExt, 0.85);
				}
				terminateStep--;
			case -1:
				terminateMessage.visible = false;
		}
	}

	var curLight:Int = 0;

	function sectionContainsBfNotes(section:Int):Bool
	{
		var notes = SONG.notes[section].sectionNotes;
		var mustHit = SONG.notes[section].mustHitSection;

		for (x in notes)
		{
			if (mustHit)
			{
				if (x[1] < 4)
				{
					return true;
				}
			}
			else
			{
				if (x[1] > 3)
				{
					return true;
				}
			}
		}

		return false;
	}

	function sectionContainsOppNotes(section:Int):Bool
	{
		var notes = SONG.notes[section].sectionNotes;
		var mustHit = SONG.notes[section].mustHitSection;

		for (x in notes)
		{
			if (mustHit)
			{
				if (x[1] > 3)
				{
					return true;
				}
			}
			else
			{
				if (x[1] < 4)
				{
					return true;
				}
			}
		}

		return false;
	}

	function camFocusOpponent()
	{
		var followX = dad.getMidpoint().x + 150;
		var followY = dad.getMidpoint().y - 100;
		// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

		switch (dad.curCharacter)
		{
			case "spooky":
				followY = dad.getMidpoint().y - 30;
			case "mom" | "mom-car":
				followY = dad.getMidpoint().y;
			case 'senpai':
				followY = dad.getMidpoint().y - 430;
				followX = dad.getMidpoint().x - 100;
			case 'senpai-angry':
				followY = dad.getMidpoint().y - 430;
				followX = dad.getMidpoint().x - 100;
			case 'spirit':
				followY = dad.getMidpoint().y;
		}

		/*if (dad.curCharacter == 'mom')
			vocals.volume = 1; */

		if (SONG.song.toLowerCase() == 'tutorial')
		{
			camChangeZoom(1.3, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
		}

		camMove(followX, followY, 1.9, FlxEase.quintOut, "dad");
	}

	function camFocusBF()
	{
		var followX = boyfriend.getMidpoint().x - 100;
		var followY = boyfriend.getMidpoint().y - 100;

		switch (curStage)
		{
			case 'spooky':
				followY = boyfriend.getMidpoint().y - 125;
			case 'limo':
				followX = boyfriend.getMidpoint().x - 300;
			case 'mall':
				followY = boyfriend.getMidpoint().y - 200;
			case 'school':
				followX = boyfriend.getMidpoint().x - 200;
				followY = boyfriend.getMidpoint().y - 225;
			case 'schoolEvil':
				followX = boyfriend.getMidpoint().x - 200;
				followY = boyfriend.getMidpoint().y - 225;
		}

		if (SONG.song.toLowerCase() == 'tutorial')
		{
			camChangeZoom(1, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
		}

		camMove(followX, followY, 1.9, FlxEase.quintOut, "bf");
	}

	function camMove(_x:Float, _y:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_focus:String = "",
			?_onComplete:Null<TweenCallback> = null):Void
	{
		if (_onComplete == null)
		{
			_onComplete = function(tween:FlxTween)
			{
			};
		}

		camTween.cancel();
		camTween = FlxTween.tween(camFollow, {x: _x, y: _y}, _time, {ease: _ease, onComplete: _onComplete});
		camFocus = _focus;
	}

	function camChangeZoom(_zoom:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void
	{
		if (_onComplete == null)
		{
			_onComplete = function(tween:FlxTween)
			{
			};
		}

		camZoomTween.cancel();
		camZoomTween = FlxTween.tween(FlxG.camera, {zoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
	}

	function uiChangeZoom(_zoom:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void
	{
		if (_onComplete == null)
		{
			_onComplete = function(tween:FlxTween)
			{
			};
		}

		uiZoomTween.cancel();
		uiZoomTween = FlxTween.tween(camHUD, {zoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});
	}

	function uiBop(?_camZoom:Float = 0.01, ?_uiZoom:Float = 0.02)
	{
		if (autoZoom)
		{
			camZoomTween.cancel();
			FlxG.camera.zoom = defaultCamZoom + _camZoom;
			camChangeZoom(defaultCamZoom, 0.6, FlxEase.quintOut);
		}

		if (autoUi)
		{
			uiZoomTween.cancel();
			camHUD.zoom = 1 + _uiZoom;
			uiChangeZoom(1, 0.6, FlxEase.quintOut);
		}
	}

	function inRange(a:Float, b:Float, tolerance:Float)
	{
		return (a <= b + tolerance && a >= b - tolerance);
	}

	function pauseMP4s()
	{
		for (i in 0...addedMP4s.length)
		{
			if (addedMP4s[i] == null)
				continue;
			if (addedMP4s[i].vlcBitmap == null)
				continue;
			if (!addedMP4s[i].vlcBitmap.isPlaying)
				continue;
			addedMP4s[i].pause();
		}
	}

	function resumeMP4s()
	{
		if (paused)
			return;

		for (i in 0...addedMP4s.length)
		{
			if (addedMP4s[i] == null)
				continue;
			if (addedMP4s[i].vlcBitmap == null)
				continue;
			if (addedMP4s[i].vlcBitmap.isPlaying)
				continue;
			addedMP4s[i].resume();
		}
	}

	override public function destroy()
	{
		FlxDestroyUtil.destroyArray(xWiggleTween);
		FlxDestroyUtil.destroyArray(yWiggleTween);
		super.destroy();
	}

	override public function onFocusLost():Void
	{
		vocals.pause();
		musicThing.pause();
		pauseMP4s();
		noiseSound.pause();
		super.onFocusLost();
	}

	override public function onFocus()
	{
		if (!startingSong && !paused && !endingSong)
		{
			vocals.play();
			musicThing.play();
		}
		resumeMP4s();
		noiseSound.resume();
		super.onFocus();
	}

	override public function switchTo(nextState:FlxState):Bool
	{
		musicThing.pause();
		vocals.pause();
		pauseMP4s();

		if (xWiggle != null && yWiggle != null && xWiggleTween != null && yWiggleTween != null)
		{
			xWiggle = [0, 0, 0, 0];
			yWiggle = [0, 0, 0, 0];
			for (i in [xWiggleTween, yWiggleTween])
			{
				for (j in i)
				{
					if (j != null && j.active)
						j.cancel();
				}
			}
		}

		if (drunkTween != null && drunkTween.active)
		{
			drunkTween.cancel();
		}

		if (effectTimer != null && effectTimer.active)
			effectTimer.cancel();

		return super.switchTo(nextState);
	}
}

class TerminateTimestamp extends FlxObject
{
	public var strumTime:Float = 0;
	public var canBeHit:Bool = false;
	public var wasGoodHit:Bool = false;
	public var tooLate:Bool = false;
	public var didLatePenalty:Bool = false;

	public function new(_strumTime:Float)
	{
		super();
		strumTime = _strumTime;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
			&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset);

		if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
			tooLate = true;
	}
}

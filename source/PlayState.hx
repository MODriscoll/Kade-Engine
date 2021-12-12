package;


import LuaClass.LuaCamera;
import LuaClass.LuaCharacter;
import lime.media.openal.AL;
import LuaClass.LuaNote;
import Song.Event;
import openfl.media.Sound;
#if sys
import sys.io.File;
import smTools.SMFile;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
#if cpp
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxRandom;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if desktop
import Discord.DiscordClient;
#end
#if cpp
import Sys;
import sys.FileSystem;
#end
import flixel.system.debug.log.LogStyle;

using StringTools;

import Note.NoteGhost;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var versusMode:Bool = false; // If CPU can damage the player

	public static var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public var visibleNotes:Array<Note> = [];

	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if cpp
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public var originalX:Float;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public static var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public static var cpuStrums:FlxTypedGroup<StaticArrow> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	private var camGame:FlxCamera;
	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = false; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	public static var trainSound:FlxSound;

	var songName:FlxText;

	public var currentSection:SwagSection;

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	public static var campaignScore:Int = 0;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public var randomVar = false;

	public static var Stage:Stage;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	public var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	// Flip characters
	private var cpuIsFlipping:Bool = false;
	private var cpuFlipStart:Float = -1.0;
	private var playerIsFlipping:Bool = false;
	private var playerFlipStart:Float = -1.0;

	// Flip duration for character sprites
	private var spriteFlipDuration:Float = 0.4;
	private var cpuSpriteFlipping:Bool = false;
	private var playerSpriteFlipping:Bool = false;

	// If the song has any flip events
	private var hasFlipEvents:Bool = false;

	// Experimental 'Ghost Note' for flips. I say mostly works (besides some visual issues
	// It can be kind of trippy. Was an idea to try and help players adjust when a flip occurs.
	public var flipNoteGhosts:FlxTypedGroup<NoteGhost>;

	// Flip VFX
	private var camFlipVFX:FlxCamera = null;
	private var flipVFXPool:FlxTypedGroup<FlipVFX> = null;
	private var numFlipVFXPerFlip:Int = 5;
	private var flipVFXVelY:Float = 2000; // Units per second

	// GF Cheer event
	private var gfIsCheering:Bool = false;
	private var gfBeatsToCheerFor:Int = 1;
	private var gfCheerNumBeats = 0;

	// BF Trinket event
	private var bfCollectedTrinket:Int = 0; // Set to num beats to cheer for (similar to gf cheer)

	// Trinket unlocks
	private var numTrinketsToCollect = 5; // If less than this trinkets exist, extra hard mode cannot be unlocked
	private var numTrinketsCollected = 0;

	// If to make Boyfriend/GF cheer when song finishes
	private var cheerOnVictory:Bool = true;

	// Events that have yet to be processed
	var remainingEvents:Array<Song.Event> = null;

	// If the character icons should 'beat' with the idle animations
	// If false, they beat every beat hit
	var iconsBeatWithCharacters:Bool = false;

	var setCameraZoom:Float = 1;

	// If camera zoom is being manually controlled
	// (So don't adjust zoom based on flip state)
	private var camZoomManuallyControlled:Bool = false;

	// 0-0
	public static var wtfMode:Bool = false;
	private static var wtfTimer:Float = 0;

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{
		FlxG.mouse.visible = false;
		instance = this;

		previousRate = songMultiplier - 0.05;

		if (previousRate < 1.00)
			previousRate = 1;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;
		
		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;
		PlayStateChangeables.enableFlip = FlxG.save.data.enableFlip;
		PlayStateChangeables.flipDuration = FlxG.save.data.flipDuration;
		PlayStateChangeables.enableGhostNotesForFlip = FlxG.save.data.enableGhostNotesForFlip;

		wtfTimer = 0;

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
			case 'pushing-onwards' | 'pushing-onwards-inst':
				songLowercase = 'pushingonwards';
		}

		// For some hardcoded crap
		var isPushingOnwards:Bool = songLowercase == 'pushingonwards';

		removedVideo = false;

		#if cpp
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (isSM)
			executeModchart = FileSystem.exists(pathToSm + "/modchart.lua");
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(songLowercase + "/modchart"));


		if (executeModchart)
			songMultiplier = 1;

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUD.zoom = PlayStateChangeables.zoom;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		// Moving cam order setup till after song initialization (for FlipVFX cam)

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Conductor.bpm = SONG.bpm;

		if (SONG.eventObjects == null)
			{
				SONG.eventObjects = [new Song.Event("Init BPM",0,SONG.bpm,"BPM Change")];
			}

		TimingStruct.clearTimings();

		remainingEvents = SONG.eventObjects.copy();

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			if (i.type == "BPM Change")
			{
                var beat:Float = i.position;

                var endBeat:Float = Math.POSITIVE_INFINITY;

				var bpm = i.value;

                TimingStruct.addTiming(beat,bpm,endBeat, 0); // offset in this case = start time since we don't have a offset
				
                if (currentIndex != 0)
                {
                    var data = TimingStruct.AllTimings[currentIndex - 1];
                    data.endBeat = beat;
                    data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
                }

				currentIndex++;
			}
			else if (i.type == "Flip Character")
			{
				hasFlipEvents = true;
			}
		}

		recalculateAllSectionTimes();

		// Game cam for stage
		FlxG.cameras.reset(camGame);

		// HUD elements
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);

		if (helperHasFlipEvents())
		{
			camFlipVFX = new FlxCamera();
			camFlipVFX.bgColor.alpha = 0;
			camFlipVFX.zoom = 1;

			FlxG.cameras.add(camFlipVFX);
		}	

		FlxCamera.defaultCameras = [camGame];

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		switch(songLowercase)
		{
			//if the song has dialogue, so we don't accidentally try to load a nonexistant file and crash the game
			case 'senpai' | 'roses' | 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/$songLowercase/dialogue'));
		}

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		if (SONG.stage == null)
		{
			switch (storyWeek)
			{
				case 2:
					stageCheck = 'halloween';
				case 3:
					stageCheck = 'philly';
				case 4:
					stageCheck = 'limo';
				case 5:
					if (songLowercase == 'winter-horrorland')
					{
						stageCheck = 'mallEvil';
					}
					else
					{
						stageCheck = 'mall';
					}
				case 6:
					if (songLowercase == 'thorns')
					{
						stageCheck = 'schoolEvil';
					}
					else
					{
						stageCheck = 'school';
					}
					// i should check if its stage (but this is when none is found in chart anyway)
			}
		}
		else
		{
			stageCheck = SONG.stage;
		}

		if (isStoryMode)
			songMultiplier = 1;

		var bfCheck:String = SONG.player1;
		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
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
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		// Again, I was bored
		if (isPushingOnwards && bfCheck == 'bf' && !isStoryMode)
		{
			var now:Date = Date.now();
			if (now.getMonth() == 11)
			{
				var chance:Float = 0;
				if (now.getDate() >= 0)
					chance = 5;
				if (now.getDate() >= 10)
					chance = 10;
				if (now.getDate() >= 20)
					chance = 20;
				if (now.getDate() == 24 || now.getDate() == 25)
					chance = 1000;
				if (now.getDate() > 28)
					chance = 0;

				if (FlxG.random.bool(chance))
				{
					bfCheck = 'bf-christmas';
					gfCheck = 'gf-christmas';
				}
			}
		}

		gf = new Character(400, 130, gfCheck);

		if (gf.frames == null)
		{
			#if debug
			FlxG.log.warn(["Couldn't load gf: " + gfCheck + ". Loading default gf"]);
			#end
			gf = new Character(770, 450, 'gf');
		}

		boyfriend = new Boyfriend(770, 450, bfCheck);

		if (boyfriend.frames == null)
		{
			#if debug
			FlxG.log.warn(["Couldn't load boyfriend: " + bfCheck + ". Loading default boyfriend"]);
			#end
			boyfriend = new Boyfriend(770, 450, 'bf');
		}

		dad = new Character(100, 100, SONG.player2);

		if (dad.frames == null)
		{
			#if debug
			FlxG.log.warn(["Couldn't load opponent: " + SONG.player2 + ". Loading default opponent"]);
			#end
			dad = new Character(100, 100, 'dad');
		}

		if (!PlayStateChangeables.Optimize)
			{
				Stage = new Stage(SONG.stage);
				for (i in Stage.toAdd)
				{
					add(i);
				}
				for (index => array in Stage.layInFront)
				{
					switch (index)
					{
						case 0:
							add(gf);
							gf.scrollFactor.set(0.95, 0.95);
							for (bg in array)
								add(bg);
						case 1:
							// Moved here so evil trail is added before spirit is (so it appears behind)
							if (dad.curCharacter == 'spirit' && FlxG.save.data.distractions)
							{
								// trailArea.scrollFactor.set();
								if (!PlayStateChangeables.Optimize)
								{
									var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
									// evilTrail.changeValuesEnabled(false, false, false, false);
									// evilTrail.changeGraphic()
									add(evilTrail);
								}
								// evilTrail.scrollFactor.set(1.1, 1.1);
							}
							add(dad);
							for (bg in array)
								add(bg);
						case 2:					
							{
								var spookyGhost = boyfriend.trySpawnSpookyGhost();
								if (spookyGhost != null)
									add(spookyGhost);
							}		
							add(boyfriend);				
							for (bg in array)
								add(bg);
					}
				}
			}
		else
		{
			Stage = new Stage("stage");
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (dad.curCharacter)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
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
				/* Move to just before Dad is added
				if (FlxG.save.data.distractions)
				{
					// trailArea.scrollFactor.set();
					if (!PlayStateChangeables.Optimize)
					{
						var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
						// evilTrail.changeValuesEnabled(false, false, false, false);
						// evilTrail.changeGraphic()
						add(evilTrail);
					}
					// evilTrail.scrollFactor.set(1.1, 1.1);
				}
				*/

				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'viridian':
				dad.x -= 50;
				dad.y += 175;
				camPos.set(dad.getGraphicMidpoint().x + 250, dad.getGraphicMidpoint().y);
		}

		// REPOSITIONING PER STAGE
		if (!PlayStateChangeables.Optimize)
		switch (Stage.curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				if (FlxG.save.data.distractions)
				{
					resetFastCar();
				}

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
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'spaceship':
				boyfriend.x += 200;
				//gf.x += 75;
		}

		dad.saveOriginPos();
		boyfriend.saveOriginPos();
		gf.saveOriginPos();


		switch (Stage.curStage)
		{
			case 'spaceship':
				boyfriend.offsetFlipPosition(0, -700);
				dad.offsetFlipPosition(0, -575);
			default:
				boyfriend.offsetFlipPosition(0, -500);
				dad.offsetFlipPosition(0, -500);
		}

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		var doof = null;

		if (isStoryMode)
		{
			doof = new DialogueBox(false, dialogue);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;
		}

		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		if (wtfMode)
			strumLine.y = 50 + ((FlxG.height - 215) * 0.5);

		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StaticArrow>();
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		generateStaticArrows(0);
		generateStaticArrows(1);

		// startCountdown();

		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.song);

		// only need flip vfx pool if cam exists
		if (camFlipVFX != null)
		{
			// Initialize pool
			flipVFXPool = new FlxTypedGroup<FlipVFX>();
			{
				// This should be enough (as in we don't need to spawn any during play)
				for (i in 0...(numFlipVFXPerFlip * 2))
				{
					var temp:FlipVFX = new FlipVFX(-1280, -1280);
					temp.active = false;
					temp.alive = false;
					flipVFXPool.add(temp);
				}
			}

			add(flipVFXPool);
			flipVFXPool.cameras = [camFlipVFX];
		}

		#if cpp
		// pre lowercasing the song name (startCountdown)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState(isStoryMode);
			luaModchart.executeState('start', [songLowercase]);
		}
		#end

		if (executeModchart)
			{
				new LuaCamera(camGame,"camGame").Register(ModchartState.lua);
				new LuaCamera(camHUD,"camHUD").Register(ModchartState.lua);
				new LuaCamera(camSustains,"camSustains").Register(ModchartState.lua);
				new LuaCamera(camSustains,"camNotes").Register(ModchartState.lua);
				new LuaCharacter(dad,"dad").Register(ModchartState.lua);
				new LuaCharacter(gf,"gf").Register(ModchartState.lua);
				new LuaCharacter(boyfriend,"boyfriend").Register(ModchartState.lua);
			}
		var index = 0;

		if (startTime != 0)
			{
				var toBeRemoved = [];
				for(i in 0...notes.members.length)
				{
					var dunceNote:Note = notes.members[i];
	
					if (dunceNote.strumTime - startTime <= 0)
						toBeRemoved.push(dunceNote);
					else 
					{
						// Seems to be fine now

						//if (PlayStateChangeables.useDownscroll)
						{
							var isDownScroll:Bool = PlayStateChangeables.useDownscroll != (dunceNote.mustPress ? boyfriend.isFlipped : dad.isFlipped);
							var noteYOff:Float = isDownScroll ? -dunceNote.noteYOff : dunceNote.noteYOff;

							if (dunceNote.mustPress)
								dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
									* (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2)) + noteYOff; // Originally - for downscroll
							else
								dunceNote.y = (cpuStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
									* (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2)) + noteYOff; // Originally - for downscroll
						}
						//else
						if (false)
						{
							//if (dunceNote.mustPress)
							//	dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
							//		* (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
							//			2)) + dunceNote.noteYOff;
							//else
							//	dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
							//		* (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
							//			2)) + dunceNote.noteYOff;
						}
					}
				}
	
				for(i in toBeRemoved)
					notes.members.remove(i);
			}

		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		var camLerpSpeed:Float = 0.04;

		var useDynamicCamLerpSpeed:Bool = true;
		if (useDynamicCamLerpSpeed)
			camLerpSpeed *= (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()); // Something KadEngine does (too make speed slower at higher framerates)

		FlxG.log.add("camLerpSpeed: " + camLerpSpeed);
		FlxG.camera.follow(camFollow, LOCKON, camLerpSpeed);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		setCamZoom(Stage.camZoom, true);
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 1);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}

		var additonalHealthBarOffsetY = helperHasFlipEvents() ? 20 : 0;
		healthBarBG = new FlxSprite(0, (FlxG.height * 0.9) + additonalHealthBarOffsetY).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50 - additonalHealthBarOffsetY;

		if (helperHasFlipEvents())
		{
			healthBarBG.scale.x *= 0.6;
			healthBarBG.updateHitbox();
		}

		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();

		if(FlxG.save.data.colour)
        {
			healthBar.createFilledBar(dad.characterColor, boyfriend.characterColor);
         /*switch (SONG.player2)
           {
             case 'gf':
             healthBar.createFilledBar(0xFFFF0000, 0xFF0097C4);
             case 'dad' | 'mom-car' | 'parents-christmas':
             healthBar.createFilledBar(0xFF5A07F5, 0xFF0097C4);
             case 'spooky':
              healthBar.createFilledBar(0xFFF57E07, 0xFF0097C4);
             case 'monster-christmas' | 'monster':
              healthBar.createFilledBar(0xFFF5DD07, 0xFF0097C4);
             case 'pico':
              healthBar.createFilledBar(0xFF52B514, 0xFF0097C4);
             case 'senpai' | 'senpai-angry':
              healthBar.createFilledBar(0xFFF76D6D, 0xFF0097C4);
             case 'spirit':
              healthBar.createFilledBar(0xFFAD0505, 0xFF0097C4);
			 case 'viridian':
			  healthBar.createFilledBar(0xFF40E0D0, 0xFF0097C4);
            }*/
        }
        else
		{
			dad.characterColor = 0xFFFF0000;
			boyfriend.characterColor = 0xFF66FF33;
         	healthBar.createFilledBar(dad.characterColor, boyfriend.characterColor);		
		}
        // healthBar
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ (50 - additonalHealthBarOffsetY) , 0,
			SONG.song
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty)
			+ (songMultiplier != 1 ? " (x" + FlxMath.roundDecimal(songMultiplier, 2) + ")" : "")
			+ (versusMode ? " (Vs)" : "")
			+ (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : ""), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		// Add after Icons, so it draws on top
		//add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + (50 - additonalHealthBarOffsetY), 0, "", 20);

		scoreTxt.screenCenter(X);

		originalX = scoreTxt.x;

		scoreTxt.scrollFactor.set();

		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		// Add after Icons, so it draws on top
		//add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		if (loadRep)
		{
			add(replayTxt);
		}
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 2;
		botPlayState.borderQuality = 1;
		if (PlayStateChangeables.botPlay && !loadRep)
		{
			add(botPlayState);
			botPlayState.cameras = [camHUD];
		}

		var iconScale:Float = helperHasFlipEvents() ? 0.70 : 1;

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		if (helperHasFlipEvents())
		{
			//iconP1.scale.scale(iconScale);
			iconP1.setGraphicSize(Std.int(150 * iconScale));
			iconP1.updateHitbox();
		}
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dad.curCharacter, false);
		if (helperHasFlipEvents())
		{
			//iconP2.scale.scale(iconScale);
			iconP2.setGraphicSize(Std.int(150 * iconScale));
			iconP2.updateHitbox();
		}
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		// Hardcoded :/
		iconsBeatWithCharacters = isPushingOnwards;

		// Add after icons, so it draws on top
		add(scoreTxt);
		add(kadeEngineWatermark);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		flipNoteGhosts.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		if (isStoryMode)
			doof.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];

		healthBar.visible = !wtfMode;
		healthBarBG.visible = !wtfMode;
		iconP1.visible = !wtfMode;
		iconP2.visible = !wtfMode;
		scoreTxt.visible = !wtfMode;

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		trace('starting');

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						camZoomManuallyControlled = true;
						setCamZoom(1.5, true);

						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);

							var onUpdateZoom = function(val:Float)
							{
								setCamZoom(val, true);
							};
							
							FlxTween.num(setCameraZoom, Stage.camZoom, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
									camZoomManuallyControlled = false;
								}
							}, onUpdateZoom.bind());
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					new FlxTimer().start(1, function(timer) {
						startCountdown();
					});
			}
		}
		else
		{
			new FlxTimer().start(1, function(timer) {
				startCountdown();
			});
		}

		if (!loadRep)
			rep = new Replay("na");

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'roses'
			|| StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
		{
			remove(black);

			if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
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

					if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
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
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
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
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];

	#if cpp
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		inCutscene = false;

		appearStaticArrows();
		//generateStaticArrows(0);
		//generateStaticArrows(1);



		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			gf.dance();
			if ((swagCounter + 1) % idleBeat == 0)
			{
				dad.dance();
				boyfriend.playAnim('idle');
			}
			else if (dad.curCharacter == "gf" || dad.curCharacter == "spooky")
			{
				dad.dance();
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			var week6Bullshit:String = null;

			if (SONG.noteStyle == 'pixel')
			{
				introAlts = introAssets.get('pixel');
				altSuffix = '-pixel';
				week6Bullshit = 'week6';
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0], week6Bullshit));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (SONG.noteStyle == 'pixel')
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
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1], week6Bullshit));
					set.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
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
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2], week6Bullshit));
					go.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
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
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}
	
	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

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

		keys[data] = false;
	}

	public var closestNotes:Array<Note> = [];
	

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(evt.keyCode);

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
		{
			//trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			//trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		closestNotes = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit)
				closestNotes.push(daNote);
		}); // Collect notes that can be hit

		closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		var dataNotes = [];
		for(i in closestNotes)
			if (i.noteData == data)
				dataNotes.push(i);

		//trace("notes able to hit for " + key.toString() + " " + dataNotes.length);

		if (dataNotes.length != 0)
		{
			var coolNote = null;
			var closestSpikeNote = null;
			var closestSpikeNoteDiff:Float = 9999999;

			for (i in dataNotes)
			{
				if (i.isSustainNote)
					continue;

				if (i.playerCanSkipThisNote())
				{
					var noteDiff:Float = (i.strumTime - Conductor.songPosition);
					noteDiff = noteDiff < 0 ? -noteDiff : noteDiff;

					if (noteDiff < closestSpikeNoteDiff)
					{
						closestSpikeNote = i;
						closestSpikeNoteDiff = noteDiff;
					}
				}
				else
				{
					coolNote = i;
					break;
				}
			}

			if (closestSpikeNote != null)
			{
				if (coolNote == null)
					coolNote = closestSpikeNote;
				else
				{
					var noteDiff:Float = (coolNote.strumTime - Conductor.songPosition);
					noteDiff = noteDiff < 0 ? -noteDiff : noteDiff;
					if (noteDiff > closestSpikeNoteDiff)
						coolNote = closestSpikeNote;
				}
			}

			if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
			{
				return;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime ) < 2)
					{
						trace('found a stacked/really close note ' + (note.strumTime  - coolNote.strumTime ));
						// just fuckin remove it since it's a stacked note and shouldn't be there

						if (note.ghost != null)
							flipNoteGhosts.remove(note.ghost, true);

						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.judgeNote(coolNote);
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.20;
		}
	}

	var songStarted = false;

	public var doAnything = false;


	public static var songMultiplier = 1.0;
	public var previousRate = songMultiplier;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.music.play();
		vocals.play();


		// Song check real quick
		switch (curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog':
				allowedToHeadbang = true;
			default:
				allowedToHeadbang = false;
		}

		if (useVideo)
			GlobalVideo.get().resume();

		if (executeModchart)
			luaModchart.executeState("songStart",[null]);

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		

		/*@:privateAccess
		{
			var aux = AL.createAux();
			var fx = AL.createEffect();
			AL.effectf(fx,AL.PITCH,songMultiplier);
			AL.auxi(aux, AL.EFFECTSLOT_EFFECT, fx);
			var instSource = FlxG.sound.music._channel.__source;

			var backend:lime._internal.backend.native.NativeAudioSource = instSource.__backend;

			AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
			if (vocals != null)
			{
				var vocalSource = vocals._channel.__source;

				backend = vocalSource.__backend;
				AL.source3i(backend.handle, AL.AUXILIARY_SEND_FILTER, aux, 1, AL.FILTER_NULL);
			}

			trace("pitched to " + songMultiplier);
		}*/

		#if cpp
		@:privateAccess
		{
			FlxG.sound.music._channel.__source.length = Std.int(FlxG.sound.music.length / songMultiplier);
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
			{
				vocals._channel.__source.length = Std.int(vocals.length / songMultiplier);
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			}
		}
		trace("pitched inst and vocals to " + songMultiplier);
		#end

		for(i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		// So user in game knows the genius behind the song :)
		// Ideally, each song could provide data of what to say here
		if (FlxG.save.data.songBanners && StringTools.startsWith(curSong, 'Pushing Onwards') && !wtfMode)
		{
			var bannerBG:FlxSprite = new FlxSprite(0, FlxG.height * 0.6).makeGraphic(FlxG.width, 70, FlxColor.BLACK);
			
			// The following lines is specific to this song, so just leave it hardcoded
			var lineOne:FlxText = new FlxText(0, bannerBG.y + 5, 0, "Pushing Onwards Remix by TechnoClassic", 32);
			lineOne.x = bannerBG.x + ((bannerBG.width - lineOne.width) * 0.5);
			lineOne.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

			var lineTwo:FlxText = new FlxText(0, bannerBG.y + 36.25, 0, "Check out the original remix at TechnoClassics Youtube Channel!", 24);
			lineTwo.x = bannerBG.x + ((bannerBG.width - lineTwo.width) * 0.5);
			lineTwo.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT);

			add(bannerBG);
			add(lineOne);
			add(lineTwo);
			bannerBG.cameras = [camHUD];
			lineOne.cameras = [camHUD];
			lineTwo.cameras = [camHUD];

			var desiredBGAlphaValue:Float = 0.7;
			bannerBG.alpha = 0; // We tween in first
			lineOne.alpha = 0;
			lineTwo.alpha = 0;

			// Ugh
			FlxTween.tween(bannerBG, {alpha: desiredBGAlphaValue}, 1, {
				onComplete: function(tween:FlxTween)
				{
					lineOne.alpha = 1;
					lineTwo.alpha = 1;

					new FlxTimer().start(4, function(tmr:FlxTimer)
					{
						FlxTween.tween(bannerBG, {alpha: 0}, 1, {
							onComplete: function(tween:FlxTween)
							{
								remove(bannerBG);
								remove(lineOne);
								remove(lineTwo);
							},
							onUpdate: function (tween:FlxTween)
							{
								lineOne.alpha = bannerBG.alpha / desiredBGAlphaValue;
								lineTwo.alpha = bannerBG.alpha / desiredBGAlphaValue;
							}
						});
					});
				},
				onUpdate: function (tween:FlxTween)
				{
					lineOne.alpha = bannerBG.alpha / desiredBGAlphaValue;
					lineTwo.alpha = bannerBG.alpha / desiredBGAlphaValue;
				}
			});
			
		}
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		#if sys
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			#if sys
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
		}

		//FlxG.sound.music.onComplete = endSong;
		FlxG.sound.music.pause();

		if (SONG.needsVoices)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.song));
		if (!PlayState.isSM)
			FlxG.sound.cache(Paths.inst(PlayState.SONG.song));


		
		// Song duration in a float, useful for the time left feature
		// music.length still works since our pitch hacks affects a value FlxSound doens't read
		songLength = FlxG.sound.music.length / 1000;

		Conductor.crochet = ((60 / (SONG.bpm) * 1000)) / songMultiplier;
		Conductor.stepCrochet = Conductor.crochet / 4;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 1);
			songPosBar.numDivisions = 250;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}


		notes = new FlxTypedGroup<Note>();
		add(notes);
		flipNoteGhosts = new FlxTypedGroup<NoteGhost>();
		add(flipNoteGhosts);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if cpp
		// pre lowercasing the song name (generateSong)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}

		var songPath = 'assets/data/' + songLowercase + '/';
		
		#if sys
		if (isSM && !isStoryMode)
			songPath = pathToSm;
		#end

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var trinketNotes:Array<Note> = [];

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				// Don't spawn trinkets in free play
				var isTrinketNote = songNotes[5] != null ? songNotes[5] == NoteTypes.TRINKET : false;
				#if !debug
				if (isTrinketNote && !isStoryMode)
					continue;
				#end

				var daStrumTime:Float = songNotes[0] - FlxG.save.data.offset - songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = true;

				if (songNotes[1] > 3 && section.mustHitSection)
					gottaHitNote = false;
				else if (songNotes[1] < 4 && !section.mustHitSection)
					gottaHitNote = false;
				

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote,false,false,false,songNotes[4], songNotes[5]);

				if (wtfMode)
					swagNote.wtfType = FlxG.random.bool();

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(songNotes[2])));
				swagNote.scrollFactor.set(0, 0);

				swagNote.isAlt = songNotes[3];
				unspawnNotes.push(swagNote);
		
				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}

				// Don't allow trinkets to have any sustain notes
				if (swagNote.isTrinket())
				{
					trinketNotes.push(swagNote);
					continue;
				}

				// Don't allow spikes to have any sustain notes
				if (swagNote.isSpike())
					continue;

				var susLength:Float = swagNote.sustainLength;
				susLength = susLength / Conductor.stepCrochet;				

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					sustainNote.isAlt = songNotes[3];

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;

					sustainNote.wtfType = swagNote.wtfType;
					sustainNote.flipY = sustainNote.wtfType;

					type++;
				}
			}
			daBeats += 1;
		}

		// Randomly select which trinkets to actually spawn in
		if (trinketNotes.length > 0 && trinketNotes.length > numTrinketsToCollect)
		{
			FlxG.log.add('' + trinketNotes.length + ' Trinket Notes detected. Shuffiling and only using ' + numTrinketsToCollect);

			var random:FlxRandom = new FlxRandom(Std.int(Sys.time()));
			random.shuffle(trinketNotes);

			for (i in numTrinketsToCollect...trinketNotes.length)
			{
				unspawnNotes.remove(trinketNotes[i]);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

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
			var babyArrow:StaticArrow = new StaticArrow(0, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			if (SONG.noteStyle == null)
			{
				switch (storyWeek)
				{
					case 6:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.add('static', [i]);
					babyArrow.animation.add('pressed', [4 + i, 8 + i], 12, false);
					babyArrow.animation.add('confirm', [12 + i, 16 + i], 24, false);

					for (j in 0...4)
					{
						babyArrow.animation.add('dirCon' + j, [12 + j, 16 + j], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);	
						babyArrow.animation.addByPrefix('dirCon' + j, dataSuffix[j].toLowerCase() + ' confirm', 24, false);
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				//babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize)
				babyArrow.x -= 275;

			babyArrow.baseX = babyArrow.x;
			babyArrow.baseY = babyArrow.y + 10; // The tween still needs to happen

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode)
				babyArrow.alpha = 1;
		});
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if desktop
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.time = Conductor.songPosition;
		vocals.play();
		vocals.time = Conductor.songPosition;

		@:privateAccess
		{
			FlxG.sound.music._channel.__source.length = Std.int(FlxG.sound.music.length / songMultiplier);
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
			{
				vocals._channel.__source.length = Std.int(vocals.length / songMultiplier);
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			}
		}

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	public var pastScrollChanges:Array<Song.Event> = [];
	public var pastFlipChanges:Array<Song.Event> = [];
	public var pastCheers:Array<Song.Event> = [];
	public var pastIdleBeats:Array<Song.Event> = [];


	var currentLuaIndex = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (unspawnNotes[0] != null)
			{
	
				if (unspawnNotes[0].strumTime - Conductor.songPosition < 14000 * songMultiplier)
				{
					var dunceNote:Note = unspawnNotes[0];
					notes.add(dunceNote);

					if (dunceNote.isSustainNote && !wtfMode)
					{
						if (dunceNote.mustPress)
							dunceNote.flipY = PlayStateChangeables.useDownscroll != boyfriend.isFlipped;
						else
							dunceNote.flipY = PlayStateChangeables.useDownscroll != dad.isFlipped;
					}

					if (executeModchart)
					{
						new LuaNote(dunceNote,currentLuaIndex);			
						dunceNote.luaID = currentLuaIndex;
					}		
					
					if (executeModchart)
					{
						if (!dunceNote.isSustainNote)
							dunceNote.cameras = [camNotes];
						else
							dunceNote.cameras = [camSustains];
					}
					else
					{
						dunceNote.cameras = [camHUD];
					}
	
					var index:Int = unspawnNotes.indexOf(dunceNote);
					unspawnNotes.splice(index, 1);
					currentLuaIndex++;
				}
			}


		#if cpp
		if (FlxG.sound.music.playing)
			@:privateAccess
			{
				FlxG.sound.music._channel.__source.length = Std.int(FlxG.sound.music.length / songMultiplier);
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
				if (vocals.playing)
				{
					vocals._channel.__source.length = Std.int(vocals.length / songMultiplier);
					lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
				}
			}
		#end

		if (generatedMusic)
			{
				if (songStarted && !endingSong)
				{
					// Song ends abruptly on slow rate even with second condition being deleted, 
					// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
					// so no reason to delete it at all
					if (unspawnNotes.length == 0 && notes.length == 0 && (FlxG.sound.music.length - Conductor.songPosition) <= 100)
					{
						endSong();
					}
				}
			}


			if (updateFrame == 4)
				{
					TimingStruct.clearTimings();
		
						var currentIndex = 0;
						for (i in SONG.eventObjects)
						{
							if (i.type == "BPM Change")
							{
								var beat:Float = i.position;
		
								var endBeat:Float = Math.POSITIVE_INFINITY;
		
								var bpm = i.value;

								TimingStruct.addTiming(beat,bpm,endBeat, 0); // offset in this case = start time since we don't have a offset
								
								if (currentIndex != 0)
								{
									var data = TimingStruct.AllTimings[currentIndex - 1];
									data.endBeat = beat;
									data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
									var step = ((60 / data.bpm) * 1000) / 4;
									TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
									TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
								}
		
								currentIndex++;
							}
						}
		
						updateFrame++;
				}
				else if (updateFrame != 5)
					updateFrame++;
		

		if (FlxG.sound.music.playing)
		{

				var timingSeg = TimingStruct.getTimingAtBeat(curDecimalBeat);
		
				if (timingSeg != null)
				{
		
					var timingSegBpm = timingSeg.bpm;
		
					if (timingSegBpm != Conductor.bpm)
					{
						trace("BPM CHANGE to " + timingSegBpm);
						Conductor.changeBPM(timingSegBpm, false);
						Conductor.crochet = ((60 / (timingSegBpm) * 1000)) / songMultiplier;
						Conductor.stepCrochet = Conductor.crochet / 4;
					}
		
				}

			var newScroll = 1.0;

			var it:Int = 0;
			while (it < remainingEvents.length)
			{
				var i = remainingEvents[it];

				var wasProcessed:Bool = false;
				switch(i.type)
				{
					case "Scroll Speed Change":
						if (i.position <= curDecimalBeat && !pastScrollChanges.contains(i))
						{
							pastScrollChanges.push(i);
							trace("SCROLL SPEED CHANGE to " + i.value);
							newScroll = i.value;

							wasProcessed = true;
						}
					case "Flip Character":
						if (curDecimalBeat >= i.position && !pastFlipChanges.contains(i))
						{
							var flipType:Int = Math.floor(i.value);

							var flipDad:Bool = flipType == 0;
							var flipBf:Bool = flipType == 1;
							if (flipType >= 2)
							{
								flipDad = true;
								flipBf = true;
							}

							// This checks flipEnabled setting
							flipCharactersImpl(flipDad, flipBf);

							pastFlipChanges.push(i);

							wasProcessed = true;
						}
					case "GF Cheer":
						// This would be nice to have
						if (curDecimalBeat >= i.position && !pastCheers.contains(i))
						{
							var scoreRequired:Int = Math.floor(i.value);
							if (scoreRequired <= 0.0 || songScore >= scoreRequired ||
								PlayStateChangeables.botPlay)
							{
								gf.playAnim('cheer');
								gfCheerNumBeats = 0;
								gfIsCheering = true;
							}
							
							pastCheers.push(i);

							wasProcessed = true;
						}
					case "Idle Beat":
						if (curDecimalBeat >= i.position && !pastIdleBeats.contains(i))
						{
							idleBeat = Math.floor(i.value > 0 ? i.value : 1);
							pastIdleBeats.push(i);

							wasProcessed = true;
						}
				}

				if (wasProcessed)
				{
					trace('event processed: ' + i.type);
					remainingEvents.remove(i);
				}
				else
					++it;
			}

			if (newScroll != 0)
				PlayStateChangeables.scrollSpeed *= newScroll;
		}
	
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}
		}

		#if cpp
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat,3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			
			luaModchart.executeState('update', [elapsed]);

			for (key => value in luaModchart.luaWiggles) 
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

			PlayStateChangeables.useDownscroll = luaModchart.getVar("downscroll","bool");

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}

			camNotes.zoom = camHUD.zoom;
			camNotes.x = camHUD.x;
			camNotes.y = camHUD.y;
			camNotes.angle = camHUD.angle;
			camSustains.zoom = camHUD.zoom;
			camSustains.x = camHUD.x;
			camSustains.y = camHUD.y;
			camSustains.angle = camHUD.angle;
		}
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
				iconP1.swapOldIcon();
		if (!PlayStateChangeables.Optimize)
		switch (Stage.curStage)
		{
			case 'philly':
				if (trainMoving && !PlayStateChangeables.Optimize)
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


		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job

		scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;

		if (controls.PAUSE && startedCountdown && canPause && !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
				clean();
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (wtfMode && !paused)
			wtfTimer += elapsed;

		if (FlxG.keys.justPressed.SEVEN && songStarted)
		{
			songMultiplier = 1;
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				#if sys
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				#end
				removedVideo = true;
			}
			cannotDie = true;

			FlxG.switchState(new ChartingState());
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var iconScale:Float = helperHasFlipEvents() ? 0.70 : 1.0;
		{
			var minSize = 150 * iconScale;
			var maxSize = 180 * iconScale;

			var t:Float = 1;
			// Only beat when song is playing
			if (songStarted && !endingSong)
			{
				if (!iconsBeatWithCharacters || getCurBeatNowPlusOne() % idleBeat == 0)
				{
					if ((Conductor.bpm * songMultiplier) >= 210) // Is this considered a high bpm?
						t = FlxEase.quadOut(getCurBeatTime());
					else
						t = FlxEase.quartOut(getCurBeatTime());
				}
			}

			// The following commented lines would scale the health icons based on who is winning
			// Though, the current icon sprites aren't really set up to make it look nice
			
			var p1IconScale:Float = 1;
			var p2IconScale:Float = 1;
			if (healthBar.percent > 80)
			{
				//p1IconScale = 1.1;
				//p2IconScale = 0.9;
			}
			else if (healthBar.percent < 20)
			{
				//p1IconScale = 0.9;
				//p2IconScale = 1.1;
			}

			iconP1.setGraphicSize(Std.int(FlxMath.lerp(maxSize, minSize, t) * p1IconScale));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(maxSize, minSize, t) * p2IconScale));

			iconP1.updateHitbox();
			iconP2.updateHitbox();

			//iconP1.y = healthBar.y - (minSize * p1IconScale * 0.5);
			//iconP2.y = healthBar.y - (minSize * p2IconScale * 0.5);

			// Update color of health bar (right now this is a simple 'flash')
			// I've been this under optimize as I'm unsure of the performance cost (it seems to be fine though)
			if (!PlayStateChangeables.Optimize && FlxG.save.data.flashing)
			{
				// This assumes RIGHT_TO_LEFT as the fill direction (healthBar.fillDirection)

				var i:Float = 1;
				if ((getCurBeatNowPlusOne()) % (idleBeat * 2) == 0)
					i = t; // Follow the normal zoom behavior

				var lightFactor:Float = 0.4;

				var opponentBarGraphic = healthBar.backFrames.parent;
				if (opponentBarGraphic != null)
				{
					var barColor = dad.characterColor.getLightened((1 - i) * lightFactor);

					// Temp Hack since lighten doesn't work well with viridians color
					// (And I don't want to pick the beat color for every character)
					if (dad.curCharacter == 'viridian')
						barColor = FlxColor.interpolate(dad.characterColor, 0xFF078AB2, (1 - i));

					opponentBarGraphic.bitmap.fillRect(new Rectangle(
						0, 0, healthBar.width, healthBar.height), barColor);
				}

				var playerBarGraphic = healthBar.frontFrames.parent;
				if (playerBarGraphic != null)
				{
					var barColor = boyfriend.characterColor.getLightened((1 - i) * lightFactor);
					playerBarGraphic.bitmap.fillRect(new Rectangle(
						healthBar.width - healthBar.barWidth, 0, healthBar.barWidth, healthBar.barHeight), barColor);
				}
			}
		}

		var iconOffset:Int = Std.int(26 * iconScale);
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}

			FlxG.switchState(new AnimationDebug(dad.curCharacter));
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.EIGHT && songStarted)
		{
			paused = true;
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}
			if (!PlayStateChangeables.Optimize)
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				for (bg in Stage.toAdd)
				{
					remove(bg);
				}
				for (array in Stage.layInFront)
				{
					for (bg in array)
						remove(bg);
				}
				remove(boyfriend);
				remove(dad);
				remove(gf);
			});
			FlxG.switchState(new StagePositioningDebug(SONG.stage, gf.curCharacter, boyfriend.curCharacter, dad.curCharacter));
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(boyfriend.curCharacter));
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		
		if(FlxG.keys.justPressed.TWO && songStarted) { //Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length) 
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime - 500 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						if (daNote.ghost != null)
							flipNoteGhosts.remove(daNote.ghost, true);
					
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						usedTimeTravel = false;
					});
			}
		}
		#end

		// Moved in front of next statement as we depend on the 'old' songPosition value (so before we change it right after this)
		if (camZooming && FlxG.save.data.camzoom && Conductor.bpm < 320)
		{
			if (Conductor.bpm > 320) // if we don't do this it'll be really annoying
			{
				camZooming = false;
			}

			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;
	
			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;

			// Only beat when song is playing
			if (songStarted && !endingSong)
			{
				var additionalZoomMultiplier:Float = 1;

				var forceZoomNow:Bool = false;
				// HARDCODING FOR MILF ZOOMS!
				if (curSong.toLowerCase() == 'milf' && getCurBeatNow() >= 168 && getCurBeatNow() < 200)
				{
					forceZoomNow = true;
					additionalZoomMultiplier = 1.6;
				}
				
				// I'm too lazy to add another event for this
				// (iconsBeatWithCharacters ~ if Pushing Onwards)
				if (iconsBeatWithCharacters)
				{
					if (getCurBeatNow() >= 104 && getCurBeatNow() < 200)
					{
						additionalZoomMultiplier = 1.15;
					}
					else if (getCurBeatNow() >= 264 && getCurBeatNow() < 424)
					{
						forceZoomNow = getCurBeatNow() < 392; // Second rush section, have the cam zoom every beat
						if (getCurBeatNow() >= 392 || (getCurBeatNowPlusOne()) % 2 == 0)
							additionalZoomMultiplier = 1.3;
					}
					else if (getCurBeatNow() >= 424)
					{
						additionalZoomMultiplier = 1.15;
					}
				}

				{
					var camZoomOnBeatDuration = 0.5; // In seconds

					var beatTime:Float = forceZoomNow ? 1 : idleBeat * 2;
					// Basically, convert BeatDuration into normalized value relative to time between beats (I think thats the right terms)
					var t:Float = ((curDecimalBeat + 1.0) % beatTime) / ((camZoomOnBeatDuration * 1000) / Conductor.crochet);
					t = t < 0 ? 0 : t > 1 ? 1 : t;
					t = FlxEase.quadOut(t);

					var additionalCamZoom:Float = (0.015 / songMultiplier) * additionalZoomMultiplier;
					var additionaHUDZoom:Float = (0.03 / songMultiplier) * additionalZoomMultiplier;

					if (!executeModchart)
					{
						// Do not call setCamZoom as we do not want to update the fixed value
						FlxG.camera.zoom = FlxMath.lerp(setCameraZoom + additionalCamZoom, setCameraZoom, t);
						camHUD.zoom = FlxMath.lerp(PlayStateChangeables.zoom + additionaHUDZoom, PlayStateChangeables.zoom, t);
					}
					else
					{
						// Do not call setCamZoom as we do not want to update the fixed value
						FlxG.camera.zoom = FlxMath.lerp(setCameraZoom + additionalCamZoom, setCameraZoom, t);
						camHUD.zoom = FlxMath.lerp(PlayStateChangeables.zoom + additionaHUDZoom, PlayStateChangeables.zoom, t);				
					}
				}

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;

				if (camFlipVFX != null)
					camFlipVFX.zoom = camHUD.zoom;
			}			
		}
		else
		{
			FlxG.camera.zoom = setCameraZoom;
			camHUD.zoom = PlayStateChangeables.zoom;
			
			camNotes.zoom = camHUD.zoom;
			camSustains.zoom = camHUD.zoom;

			if (camFlipVFX != null)
				camFlipVFX.zoom = camHUD.zoom;
		}

		if (startingSong)
		{
			// There is some issue where the music starts playing before we actually call songStart
			// Let's just make sure it's not playing
			if (FlxG.sound.music.playing && !songStarted)
			{
				FlxG.log.advanced('music was playing before song started. forcing it to stop', LogStyle.WARNING, false);
				FlxG.sound.music.stop();
			}

			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = Conductor.songPosition;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000 * songMultiplier;
			Conductor.rawPosition = FlxG.sound.music.time;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = 1 - ((FlxG.sound.music.length - Conductor.songPosition) / FlxG.sound.music.length);

			currentSection = getSectionByTime(Conductor.songPosition);

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

		if (generatedMusic && currentSection != null)
		{

			// Make sure Girlfriend cheers only for certain songs
			if (allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Philly Nice':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'Blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}

			#if cpp
			if (luaModchart != null)
				luaModchart.setVar("mustHit", currentSection.mustHitSection);
			#end

			if (!endingSong)
			{
				// TODO: Currently the offset results in the camera dipping a bit before going to the correct
				// location when flipping. This is due to using the current position for camFollow.setPos
				// We should use the originPos or flipPos instead
				if (!currentSection.mustHitSection)
				{
					if (camFollow.x != (dad.getMidpoint().x + 150) ||
						camFollow.y != (dad.getMidpoint().y + (dad.isFlipped ? 100 : -100)))
					{
						var offsetX = 0;
						var offsetY = 0;
						#if cpp
						if (luaModchart != null)
						{
							offsetX = luaModchart.getVar("followXOffset", "float");
							offsetY = luaModchart.getVar("followYOffset", "float");
						}
						#end
						var camFollowOffsetY = -100;// + offsetY;
						if (dad.isFlipped)
							camFollowOffsetY = -camFollowOffsetY;
						camFollow.setPosition(dad.getMidpoint().x + 150/* + offsetX*/, dad.getMidpoint().y + camFollowOffsetY);
						#if cpp
						if (luaModchart != null)
							luaModchart.executeState('playerTwoTurn', []);
						#end
						// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

						switch (dad.curCharacter)
						{
							case 'mom' | 'mom-car':
								camFollow.y = dad.getMidpoint().y;
							case 'senpai' | 'senpai-angry':
								camFollow.y = dad.getMidpoint().y - 430;
								camFollow.x = dad.getMidpoint().x - 100;
						}
					}
				}

				// TODO: Currently the offset results in the camera dipping a bit before going to the correct
				// location when flipping. This is due to using the current position for camFollow.setPos
				// We should use the originPos or flipPos instead
				if (currentSection.mustHitSection)
				{
					if (camFollow.x != (boyfriend.getMidpoint().x - 100) ||
						camFollow.y != (boyfriend.getMidpoint().y + (boyfriend.isFlipped ? 100 : -100)))
					{
						var offsetX = 0;
						var offsetY = 0;
						#if cpp
						if (luaModchart != null)
						{
							offsetX = luaModchart.getVar("followXOffset", "float");
							offsetY = luaModchart.getVar("followYOffset", "float");
						}
						#end
						var camFollowOffsetY = -100;// + offsetY;
						if (boyfriend.isFlipped)
							camFollowOffsetY = -camFollowOffsetY;
						camFollow.setPosition(boyfriend.getMidpoint().x - 100/* + offsetX*/, boyfriend.getMidpoint().y + camFollowOffsetY);

						#if cpp
						if (luaModchart != null)
							luaModchart.executeState('playerOneTurn', []);
						#end

						switch (Stage.curStage)
						{
							case 'limo':
								camFollow.x = boyfriend.getMidpoint().x - 300;
							case 'mall':
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'school':
								camFollow.x = boyfriend.getMidpoint().x - 200;
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'schoolEvil':
								camFollow.x = boyfriend.getMidpoint().x - 200;
								camFollow.y = boyfriend.getMidpoint().y - 200;
						}
					}
				}

				if (dad.isFlipped != boyfriend.isFlipped)
				{
					var halfwayPos:Float = (dad.getMidpoint().y - 100) + (boyfriend.getMidpoint().y - 100) * 0.5;
					camFollow.setPosition(camFollow.x, halfwayPos);
				}
			}
		}

		//FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("curBPM (multiplied)", Conductor.bpm * songMultiplier);
		FlxG.watch.addQuick("curStep", curStep);
		FlxG.watch.addQuick("curBeat", curBeat);
		//FlxG.watch.addQuick('curBeatNow', getCurBeatNow()); // curBeat should now match up to this with recent changes to fix songMultiplier
		FlxG.watch.addQuick('curBeatTime', getCurBeatTime()); 
		FlxG.watch.addQuick('music time', FlxG.sound.music.time);
		FlxG.watch.addQuick('music|songPos diff', FlxG.sound.music.time - Std.int(Conductor.songPosition));
		FlxG.watch.addQuick('vocals time', vocals.time);
		FlxG.watch.addQuick('music|vocals diff', SONG.needsVoices ? (FlxG.sound.music.time - vocals.time) : 0);
		//FlxG.watch.addQuick("inst Volume", FlxG.sound.music.volume);
		//FlxG.watch.addQuick("vocals Volume", vocals.volume);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel) 
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else 
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end
				// God i love futabu!! so fucking much (From: McChomk)
				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			if (FlxG.keys.justPressed.R)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();
			 
                if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else 
				{
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}


		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			// Cam Zoom is based upon sprite flip, not arrows flip
			var desiredCamZoomLerp = 0.0;
			if ((dad.isFlipped && !cpuSpriteFlipping) ||
				(boyfriend.isFlipped && !playerSpriteFlipping))
			{
				desiredCamZoomLerp = 1.0;
			}

			var cpuFlipTime:Float = 0.0; // Arrow flip, not sprite
			if (cpuIsFlipping || cpuSpriteFlipping)
			{
				if (cpuIsFlipping)
				{
					var endInterpTime:Float = cpuFlipStart + (PlayStateChangeables.flipDuration * 1000.0);
					var interpTime:Float = 	(endInterpTime - songTime) / (PlayStateChangeables.flipDuration * 1000.0);
					cpuFlipTime = interpTime;
					interpTime = dad.isFlipped ? (1.0 - interpTime) : interpTime;

					if (interpTime < 0.0)
						interpTime = 0.0;
					else if (interpTime > 1.0)
						interpTime = 1.0;

					var strumTargetflipPos:Float = PlayStateChangeables.useDownscroll ? 50 : FlxG.height - 165;
					var strumsFlipPos:Float = FlxMath.lerp(strumLine.y, strumTargetflipPos, interpTime);
					for (i in cpuStrums)
					{
						i.y = strumsFlipPos;
					}

					if (songTime >= endInterpTime)
						cpuIsFlipping = false;
				}

				if (cpuSpriteFlipping)
				{
					var endInterpTime:Float = cpuFlipStart + (spriteFlipDuration * 1000.0);
					var interpTime:Float = 	(endInterpTime - songTime) / (spriteFlipDuration * 1000.0);
					interpTime = dad.isFlipped ? (1.0 - interpTime) : interpTime;

					if (interpTime < 0.0)
						interpTime = 0.0;
					else if (interpTime > 1.0)
						interpTime = 1.0;

					dad.x = FlxMath.lerp(dad.originXPos, dad.flipXPos, interpTime);
					dad.y = FlxMath.lerp(dad.originYPos, dad.flipYPos, interpTime);

					if (songTime >= endInterpTime)
						cpuSpriteFlipping = false;

					desiredCamZoomLerp = interpTime > desiredCamZoomLerp ? interpTime : desiredCamZoomLerp;
				}
			}

			var playerFlipTime:Float = 0.0; // Arrow flip, not sprite
			if (playerIsFlipping || playerSpriteFlipping)
			{
				if (playerIsFlipping)
				{
					var endInterpTime:Float = playerFlipStart + (PlayStateChangeables.flipDuration * 1000.0);
					var interpTime:Float = 	(endInterpTime - songTime) / (PlayStateChangeables.flipDuration * 1000.0);
					playerFlipTime = interpTime;
					interpTime = boyfriend.isFlipped ? (1.0 - interpTime) : interpTime;

					if (interpTime < 0.0)
						interpTime = 0.0;
					else if (interpTime > 1.0)
						interpTime = 1.0;

					var strumTargetflipPos:Float = PlayStateChangeables.useDownscroll ? 50 : FlxG.height - 165;
					var strumsFlipPos:Float = FlxMath.lerp(strumLine.y, strumTargetflipPos, interpTime);
					for (i in playerStrums)
					{
						i.y = strumsFlipPos;
					}

					if (songTime >= endInterpTime)
						playerIsFlipping = false;
				}

				if (playerSpriteFlipping)
				{
					var endInterpTime:Float = playerFlipStart + (spriteFlipDuration * 1000.0);
					var interpTime:Float = 	(endInterpTime - songTime) / (spriteFlipDuration * 1000.0);
					interpTime = boyfriend.isFlipped ? (1.0 - interpTime) : interpTime;

					if (interpTime < 0.0)
						interpTime = 0.0;
					else if (interpTime > 1.0)
						interpTime = 1.0;

					boyfriend.x = FlxMath.lerp(boyfriend.originXPos, boyfriend.flipXPos, interpTime);
					boyfriend.y = FlxMath.lerp(boyfriend.originYPos, boyfriend.flipYPos, interpTime);

					if (songTime >= endInterpTime)
						playerSpriteFlipping = false;

					desiredCamZoomLerp = interpTime > desiredCamZoomLerp ? interpTime : desiredCamZoomLerp;
				}
			}

			if (!endingSong && !camZoomManuallyControlled)
			{
				if (desiredCamZoomLerp > 0)
				{
					setCamZoom(FlxMath.lerp(Stage.camZoom, Stage.flippedCamZoom, desiredCamZoomLerp));
				}
				else
				{
					setCamZoom(Stage.camZoom);
				}
			}

			
			// Assuming flips do not happen in wtfMode
			if (wtfMode)
			{
				// songTime
				var a:Float = 20;
				var b:Float = 60;
				var s:Float = 4.5;

				for (i in 0...cpuStrums.members.length)
				{
					var arrow:StaticArrow = cpuStrums.members[i];

					var t:Float = wtfTimer + (2 * i);

					arrow.x = arrow.baseX + a * (Math.cos(t));
					arrow.y = arrow.baseY + b * (Math.sin(t * s));
				}

				for (i in 0...playerStrums.members.length)
				{
					var arrow:StaticArrow = playerStrums.members[i];

					var t:Float = wtfTimer + (2 * i);

					arrow.x = arrow.baseX + a * (Math.cos(t));
					arrow.y = arrow.baseY + b * (Math.sin(t * s));
				}
			}

			var notesToRemove:Array<Note> = new Array<Note>();
			notes.forEachAlive(function(daNote:Note)
			{
				// Destroy flip ghost notes if off-screen while not flipping
				if (daNote.ghost != null &&
					daNote.ghost.visible)
				{
					if ((daNote.mustPress && !playerIsFlipping) ||
						(!daNote.mustPress && !cpuIsFlipping))
					{
						if (!daNote.ghost.isOnScreen(camHUD))
						{
							// I tried removing it and destroying it here,
							// but that doesn't work (and the screen gets covered).
							// Just set it to invisible and let it be destroyed with its owner
							daNote.ghost.visible = false;
							daNote.ghost.active = false;
						}
					}
					else if (daNote.mustPress)
						daNote.ghost.alpha = daNote.alpha * playerFlipTime;
					else
						daNote.ghost.alpha = daNote.alpha * cpuFlipTime;
				}

				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)

				if (!daNote.modifiedByLua)
				{
					if (daNote.mustPress)
					{
						var isUpscroll = wtfMode ? !daNote.wtfType : PlayStateChangeables.useDownscroll == boyfriend.isFlipped;
						if (isUpscroll)
							{
								daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * ((Conductor.songPosition - daNote.strumTime) / 1) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))) + daNote.noteYOff;
							}
							else
							{
						daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
							+ 0.45 * ((Conductor.songPosition - daNote.strumTime) / 1) * 
							(FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2) )) 
							- daNote.noteYOff;
							}
					}
					else
					{
						var isUpscroll = wtfMode ? !daNote.wtfType : PlayStateChangeables.useDownscroll == dad.isFlipped;
						if (isUpscroll)
							{
								daNote.y = (cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y
							- 0.45 * ((Conductor.songPosition - daNote.strumTime) / 1) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2))) + daNote.noteYOff;
							}
							else
							{
								daNote.y = (cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y
							+ 0.45 * ((Conductor.songPosition - daNote.strumTime) / 1) * (FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2))) - daNote.noteYOff;
							}
						
					}

					var isDownScrollNow:Bool = false;
					if (wtfMode)
						isDownScrollNow = daNote.wtfType;
					else
						isDownScrollNow = PlayStateChangeables.useDownscroll != (daNote.mustPress ? boyfriend.isFlipped : dad.isFlipped);

					if (daNote.isSustainNote)
					{
						if (isDownScrollNow)
						{
							// Remember = minus makes notes go up, plus makes them go down (This was ripped from a pull request, look for it again :/)
							if (daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote != null)
							{
								daNote.y += daNote.prevNote.height;
							}
							else
							{
								daNote.y += daNote.height / 2;
							}
						}
						else
						{
							daNote.y -= daNote.height / 2;
						}
						
						var passesThisStatement:Bool = false;
						{
							var strumLineY = daNote.mustPress ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y : cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y;
	
							if (isDownScrollNow)
								passesThisStatement = daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (/*strumLine.y*/strumLineY + Note.swagWidth / 2);
							else
								passesThisStatement = daNote.y + daNote.offset.y * daNote.scale.y <= (/*strumLine.y*/strumLineY + Note.swagWidth / 2);
						}
	
						if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit || holdArray[Math.floor(Math.abs(daNote.noteData))])
							&& passesThisStatement)//daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
						{
							var yToUse:Float = daNote.mustPress ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y : cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y;
	
							// Clip to strumline
							
							if (isDownScrollNow)
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (yToUse
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
	
								daNote.clipRect = swagRect;
							} 
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (yToUse
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
	
								daNote.clipRect = swagRect;
							}			
						}
					}
	
					var noteGhost:NoteGhost = daNote.ghost;
					if (noteGhost != null && noteGhost.visible)
					{
						var yToUse:Float = daNote.mustPress ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y : cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].y;
						var delta:Float = daNote.y - yToUse;

						noteGhost.x = daNote.x;
						noteGhost.y = yToUse - delta;
						noteGhost.angle = daNote.angle;

						if (daNote.isSustainNote)
						{
							// Clip to strumline
							if (!isDownScrollNow)
							{
								
								var swagRect = new FlxRect(0, 0, noteGhost.frameWidth * 2, noteGhost.frameHeight * 2);
								swagRect.height = (yToUse
									+ Note.swagWidth / 2
									- noteGhost.y) / noteGhost.scale.y;
								swagRect.y = noteGhost.frameHeight - swagRect.height;
	
								noteGhost.clipRect = swagRect;
							} 
							else
							{
								var swagRect = new FlxRect(0, 0, noteGhost.width / noteGhost.scale.x, noteGhost.height / noteGhost.scale.y);
								swagRect.y = (yToUse
									+ Note.swagWidth / 2
									- noteGhost.y) / noteGhost.scale.y;
								swagRect.height -= swagRect.y;
	
								noteGhost.clipRect = swagRect;
							}
						}

						// Basically if on the other side of the arrow, hide it
						if ((delta <= 0) != isDownScrollNow)
							noteGhost.visible = false;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.botShouldAvoidNote())
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (currentSection != null)
					{
						if (currentSection.CPUAltAnim)
							altAnim = '-alt';
					}
					
					if (daNote.isAlt)
					{
						altAnim = '-alt';
						trace("YOO WTF THIS IS AN ALT NOTE????");
					}

					// Damage player if playing versus mode
					if (versusMode && !daNote.isSustainNote)
					{
						health -= (0.01 + (0.005 * storyDifficulty));

						// Don't allow CPU to end the game
						if (health < 0.001)
							health = 0.001;
					}

					// Accessing the animation name directly to play it
					if (!daNote.isParent && daNote.parent != null)
					{
						if (daNote.spotInLine != daNote.parent.children.length - 1)
						{
							var singData:Int = Std.int(Math.abs(daNote.noteData));
							dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);

							if (FlxG.save.data.cpuStrums)
							{
								cpuStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
									/*
									if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
									*/
								});
							}

							#if cpp
							if (luaModchart != null)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							#end

							dad.holdTimer = 0;

							if (SONG.needsVoices && !boyfriend.newStunned)
								vocals.volume = 1;
						}
					}
					else
					{
						var singData:Int = Std.int(Math.abs(daNote.noteData));
							dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);

							if (FlxG.save.data.cpuStrums)
							{
								cpuStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
									/*
									if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
									*/
								});
							}

							#if cpp
							if (luaModchart != null)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							#end

							dad.holdTimer = 0;

							if (SONG.needsVoices && !boyfriend.newStunned)
								vocals.volume = 1;
					}
					daNote.active = false;

					if (daNote.ghost != null)
					{
						daNote.ghost.active = false;
						flipNoteGhosts.remove(daNote.ghost, true);
					}

					daNote.kill();
					notesToRemove.push(daNote);//notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
				}

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (SONG.noteStyle == 'pixel')
						daNote.x -= 11;
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					if (daNote.ghost != null)
						flipNoteGhosts.remove(daNote.ghost, true);

					daNote.kill();
					notesToRemove.push(daNote);//notes.remove(daNote, true);
					daNote.destroy();
				}
				else if ((daNote.mustPress && !PlayStateChangeables.useDownscroll || daNote.mustPress 
					&& PlayStateChangeables.useDownscroll)
					&& daNote.mustPress && daNote.strumTime / 1 - Conductor.songPosition / 1 < -(166 * Conductor.timeScale) && songStarted)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							if (daNote.ghost != null)
								flipNoteGhosts.remove(daNote.ghost, true);

							daNote.kill();
							notesToRemove.push(daNote);//notes.remove(daNote, true);
						}
						else
						{
							if (loadRep && daNote.isSustainNote)
							{
								// im tired and lazy this sucks I know i'm dumb
								if (findByTime(daNote.strumTime) != null)
									totalNotesHit += 1;
								else
								{
									if (theFunne && !daNote.isSustainNote)
									{
										noteMiss(daNote.noteData, daNote);
									}
									if (daNote.isParent)
									{
										health -= 0.15 * (storyDifficulty >= 3 ? 2 : 1); // give a health punishment for failing a LN
										trace("hold fell over at the start");
										for (i in daNote.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
									}
									else
									{
										if (!daNote.wasGoodHit
											&& daNote.isSustainNote
											&& daNote.sustainActive
											&& daNote.spotInLine != daNote.parent.children.length)
										{
											//health -= 0.05; // give a health punishment for failing a LN
											trace("hold fell over at " + daNote.spotInLine);
											for (i in daNote.parent.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
											if (daNote.parent.wasGoodHit)
												misses++;
											updateAccuracy();
										}
										else if (!daNote.wasGoodHit
											&& !daNote.isSustainNote)
										{
											health -= 0.15 * (storyDifficulty >= 3 ? 2 : 1);
										}
									}
								}
							}
							else
							{
								if (theFunne && !daNote.isSustainNote)
								{
									if (PlayStateChangeables.botPlay)
									{
										daNote.rating = "bad";
										goodNoteHit(daNote);
									}
									else
										noteMiss(daNote.noteData, daNote);
								}

								// Is optional to hit trinket or spikes
								if (daNote.playerCanSkipThisNote())
								{
									daNote.alpha = 0.3;
								}
								else if (daNote.isParent && daNote.visible)
								{
									health -= 0.15 * (storyDifficulty >= 3 ? 2 : 1); // give a health punishment for failing a LN
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										//health -= 0.05; // give a health punishment for failing a LN
										var remaining = daNote.parent.children.length - daNote.spotInLine;
										trace("hold fell over at " + daNote.spotInLine + ' (remaining = ' + remaining + ')');
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										//if (daNote.parent.wasGoodHit)
										// Don't miss if leaving the small bit at the end
										if (remaining >= 2)
											noteMiss(daNote.noteData, daNote);
										//updateAccuracy();
									}
									else if (!daNote.wasGoodHit
										&& !daNote.isSustainNote)
									{
										health -= 0.15 * (storyDifficulty >= 3 ? 2 : 1);
									}
								}
							}
						}

						if (daNote.ghost != null)
						{
							daNote.ghost.visible = false;
							flipNoteGhosts.remove(daNote.ghost, true);
						}

						daNote.visible = false;
						daNote.kill();
						notesToRemove.push(daNote);//notes.remove(daNote, true);
					}
					// Anything that the CPU should avoid
					else if (!daNote.mustPress && daNote.strumTime / 1 - Conductor.songPosition / 1 < -(166 * Conductor.timeScale) && songStarted)
					{
						if (daNote.ghost != null)
						{
							daNote.ghost.visible = false;
							flipNoteGhosts.remove(daNote.ghost, true);
						}

						daNote.visible = false;
						daNote.kill();
						notesToRemove.push(daNote);//notes.remove(daNote, true);
					}
			});

			// Quite a 'big' change, doesn't seem to break anything
			// Reason why we do this as by removing it in the for loop, it causes notes to be skipped (not processed)
			// since forEachAlive isn't built to handle removing elements during the iteration. Issues this was causing
			// was (for example) 'Dad' flickering between different sing animations if singing multiple sustain notes at once
			for (i in 0...notesToRemove.length)
			{
				notes.remove(notesToRemove[i], true);
			}
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:StaticArrow)
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static');
					spr.centerOffsets();
				}
			});
			if (PlayStateChangeables.botPlay)
			{
				playerStrums.forEach(function(spr:StaticArrow)
					{
						if (spr.animation.finished)
						{
							spr.playAnim('static');
							//spr.centerOffsets();
						}
					});
			}
		}

		if (!inCutscene && songStarted)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		super.update(elapsed);
	}

	public function getSectionByTime(ms:Float):SwagSection
		{
	
			for (i in SONG.notes)
			{
				var start = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.startTime)));
				var end = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.endTime)));


				if (ms >= start && ms < end)
				{
					return i;
				}
			}
	
	
			return null;
		}

		function recalculateAllSectionTimes()
			{
		
					trace("RECALCULATING SECTION TIMES");
		
					for (i in 0...SONG.notes.length) // loops through sections
					{
						var section = SONG.notes[i];
		
						var currentBeat = 4 * i;
		
						var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);
		
						if (currentSeg == null)
							return;
		
						var start:Float = (currentBeat - currentSeg.startBeat) / ((currentSeg.bpm) / 60);
		
						section.startTime = (currentSeg.startTime + start) * 1000;
		
						if (i != 0)
							SONG.notes[i - 1].endTime = section.startTime;
						section.endTime = Math.POSITIVE_INFINITY;
					}
			}
		

	function endSong():Void
	{
		endingSong = true;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		if (useVideo)
		{
			GlobalVideo.get().stop();
			FlxG.stage.window.onFocusOut.remove(focusOut);
			FlxG.stage.window.onFocusIn.remove(focusIn);
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}


		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if cpp
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore)
			{
				case 'Dad-Battle':
					songHighscore = 'Dadbattle';
				case 'Philly-Nice':
					songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			clean();
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);
				campaignMisses += misses;
				campaignSicks += sicks;
				campaignGoods += goods;
				campaignBads += bads;
				campaignShits += shits;

				if (numTrinketsCollected >= numTrinketsToCollect)
				{
					if (Unlocks.unlockDiffForSong(SONG.song, storyDifficulty + 1))
					{
						trace('Unlocked new difficulty for song: ' + SONG.song);
						FlxG.save.flush();
					}		
				}

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					if (FlxG.save.data.scoreScreen)
					{
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
								cheerForResults();
							});
					}
					else
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						Conductor.changeBPM(102);
						FlxG.switchState(new StoryMenuState());
						clean();
					}

					#if cpp
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore)
					{
						NGio.unlockMedal(60961);
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
					switch (songFormat)
					{
						case 'Dad-Battle':
							songFormat = 'Dadbattle';
						case 'Philly-Nice':
							songFormat = 'Philly';
					}

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

					trace('LOADING NEXT SONG');
					trace(poop);

					if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
					clean();
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (FlxG.save.data.scoreScreen) 
				{
					openSubState(new ResultsScreen());
					new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
							cheerForResults();
						});
				}
				else
				{
					FlxG.switchState(new FreeplayState());
					clean();
				}
			}
		}
	}

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	public function getRatesScore(rate:Float, score:Float):Float
	{
		var rateX:Float = 1;
		var lastScore:Float = score;
		var pr =  rate - 0.05;
		if (pr < 1.00)
			pr = 1;
		
		while(rateX <= pr)
		{
			if (rateX > pr)
				break;
			lastScore = score + ((lastScore * rateX) * 0.022);
			rateX += 0.05;
		}

		var actualScore = Math.round(score + (Math.floor((lastScore * pr)) * 0.022));

		return actualScore;
	}


	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		if (daNote.isTrinket())
			return;

		if (daNote.isSpike())
		{
			if (!PlayStateChangeables.botPlay && (daNote.rating =='good' || daNote.rating == 'sick'))
			{
				health -= (FlxG.save.data.spikeInstantDeath ? 999 : 0.5);
				noteMiss(daNote.noteData, daNote, true);
			}
			return;
		}

		var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = Ratings.judgeNote(daNote);

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.1 * (storyDifficulty >= 3 ? 2 : 1);
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.06 * (storyDifficulty >= 3 ? 2 : 1);
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		if (songMultiplier >= 1.05)
			score = getRatesScore(songMultiplier, score);

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);

			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
			var pixelShitPart3:String = null;

			if (SONG.noteStyle == 'pixel')
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
				pixelShitPart3 = 'week6';
			}

			var originalAnim:Bool = FlxG.save.data.originalRatingsAnim;
			var showInWorldSpace:Bool = FlxG.save.data.worldSpaceRatings;
			var ratingsScale:Float = showInWorldSpace ? 1 + (1 - setCameraZoom) : 1;
			ratingsScale = ratingsScale < 0.7 ? 0.7 : ratingsScale > 1.3 ? 1.3 : ratingsScale;

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2, pixelShitPart3));
			rating.screenCenter();

			if (showInWorldSpace)
			{
				// TODO: Could have Stage define these points (for both normal and flipped)
				// Cause this assumes gf is bascially inbetween both bf/dad
				rating.x = gf.getMidpoint().x - 100;
				rating.y = gf.getMidpoint().y + 50;

				// I hope this just works in general (this gf sheet seems different from the others)
				if (gf.curCharacter == 'gf-pixel')
				{
					rating.x = gf.x;
					rating.y = gf.y + 100;
				}

				// This really justifies the stage defining the points
				if (Stage.curStage == 'limo')
					rating.y -= 150;

				if (dad.isFlipped || boyfriend.isFlipped)
					rating.y -= 500;
			}
			else
			{
				rating.y -= 50;
				rating.x = coolText.x - 125;
	
				if (FlxG.save.data.changedHit)
				{
					rating.x = FlxG.save.data.changedHitX;
					rating.y = FlxG.save.data.changedHitY;
				}
			}


			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			if (!originalAnim)
				rating.velocity.y -= 45;

			var msTiming = HelperFunctions.truncateFloat(noteDiff / songMultiplier, 3);
			if (PlayStateChangeables.botPlay && !loadRep)
				msTiming = 0;

			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = Std.int(20 * ratingsScale);

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!PlayStateChangeables.botPlay || loadRep)
				add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2, pixelShitPart3));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + (100 * ratingsScale);
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + (100 * ratingsScale); // For World Space, we overwrite this in the numScore loop
			currentTimingShown.y = rating.y + (100 * ratingsScale);
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay || loadRep)
				add(rating);

			if (SONG.noteStyle != 'pixel')
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7 * ratingsScale));
				rating.antialiasing = FlxG.save.data.antialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7 * ratingsScale));
				comboSpr.antialiasing = FlxG.save.data.antialiasing;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7 * ratingsScale));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7 * ratingsScale));
			}

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			var cameraToUse:FlxCamera = showInWorldSpace ? FlxG.camera : camHUD;
			currentTimingShown.cameras = [cameraToUse];
			comboSpr.cameras = [cameraToUse];
			rating.cameras = [cameraToUse];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var fadeOutDuration:Float = 0.2;

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, pixelShitPart3));
				numScore.screenCenter();
				numScore.x = rating.x + ((43 * ratingsScale) * daLoop) - 50;
				numScore.y = rating.y + (100 * ratingsScale);
				numScore.cameras = [cameraToUse];

				if (SONG.noteStyle != 'pixel')
				{
					numScore.antialiasing = FlxG.save.data.antialiasing;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5 * ratingsScale));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom * ratingsScale));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				if (showInWorldSpace)
					currentTimingShown.x = numScore.x + numScore.width + 20;

				add(numScore);

				visibleCombos.push(numScore);

				FlxTween.tween(numScore, {alpha: 0}, fadeOutDuration, {
					onComplete: function(tween:FlxTween)
					{
						visibleCombos.remove(numScore);
						numScore.destroy();
					},
					onUpdate: function (tween:FlxTween)
					{
						if (!visibleCombos.contains(numScore))
						{
							tween.cancel();
							numScore.destroy();
						}
					},
					startDelay: Conductor.crochet * 0.002
				});

				if (visibleCombos.length > seperatedScore.length + 20)
				{
					for(i in 0...seperatedScore.length - 1)
					{
						visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
					}
				}

				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			// Important, thisTiming assumes the previous currentTimingShown is removed manually above
			var thisTiming = currentTimingShown;
			
			var tweenDelay = Conductor.crochet * 0.001;
			// Optimize since again I'm unsure of the impact all these dynamic captures may have
			if (originalAnim || PlayStateChangeables.Optimize)
			{
				FlxTween.tween(rating, {alpha: 0}, fadeOutDuration, {
					onUpdate: function(tween:FlxTween)
					{
						// This handles changing alpha, removing is done in the following tween
						if (thisTiming == currentTimingShown && currentTimingShown != null)
							currentTimingShown.alpha = rating.alpha;
						//timeShown++;
					},
					startDelay: tweenDelay
				});
			
				FlxTween.tween(comboSpr, {alpha: 0}, fadeOutDuration, {
					onComplete: function(tween:FlxTween)
					{
						coolText.destroy();
						comboSpr.destroy();
						if (thisTiming == currentTimingShown && currentTimingShown != null)
						{
							remove(currentTimingShown);
							currentTimingShown = null;
							thisTiming = null;
						}
						rating.destroy();
					},
					startDelay: tweenDelay
				});
			}
			else
			{
				var baseWidth = rating.width;
				var baseHeight = rating.height;

				// Do it this way since we need to call setGraphicsize
				var onUpdateRatingSize = function(val:Float)
				{
					rating.setGraphicSize(Std.int(baseWidth * val), Std.int(baseHeight * val));
				};
			
				// The tween delay acts as the duration for rescaling the ratings graphic
				FlxTween.num(0.8, 1, tweenDelay, {
					ease: FlxEase.backOut,
					onComplete: function(tween:FlxTween)
					{
						FlxTween.tween(rating, {alpha: 0}, fadeOutDuration, {
							onUpdate: function(tween:FlxTween)
							{
								// This handles changing alpha, removing is done in the following tween
								if (thisTiming == currentTimingShown && currentTimingShown != null)
									currentTimingShown.alpha = rating.alpha;
								//timeShown++;
							}
						});
					
						FlxTween.tween(comboSpr, {alpha: 0}, fadeOutDuration, {
							onComplete: function(tween:FlxTween)
							{
								coolText.destroy();
								comboSpr.destroy();
								if (thisTiming == currentTimingShown && currentTimingShown != null)
								{
									remove(currentTimingShown);
									currentTimingShown = null;
									thisTiming = null;
								}
								rating.destroy();
							}
						});
					}
				}, onUpdateRatingSize.bind());
			}

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];
		#if cpp
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length) {
				if (pressArray[i] == true) {
				luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};
			
			for (i in 0...releaseArray.length) {
				if (releaseArray[i] == true) {
				luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};
			
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);

					if (note.ghost != null)
						flipNoteGhosts.remove(note.ghost, true);

					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false,false,false,false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.judgeNote(coolNote);
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
					{
						boyfriend.playAnim('idle');
						boyfriend.newStunned = false;
					}
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there
		}
		if (PlayStateChangeables.botPlay)
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.botShouldAvoidNote())
				return;

			var diff = -((daNote.strumTime - Conductor.songPosition ) / songMultiplier);

			daNote.rating = Ratings.judgeNote(daNote);
			if (daNote.mustPress && daNote.rating == "sick" || (diff > 0 && daNote.mustPress))
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
					if (loadRep)
					{
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = 0;
							if (FlxG.save.data.cpuStrums)
							{
								playerStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
									/*
									if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								*/
								});
							}
						}
					}
					else
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = 0;
						if (FlxG.save.data.cpuStrums)
							{
								playerStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
									/*
									if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								*/
								});
							}
					}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
			{
				boyfriend.playAnim('idle');
				boyfriend.newStunned = false;
			}
		}

		if (!PlayStateChangeables.botPlay)
		{
			playerStrums.forEach(function(spr:StaticArrow)
			{
				if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed' && !spr.animation.curAnim.name.startsWith('dirCon'))
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('static', false);
			});
		}
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public var fuckingVolume:Float = 1;
	public var useVideo = false;

	public static var webmHandler:WebmHandler;

	public var playingDathing = false;

	public var videoSprite:FlxSprite;

	public function focusOut()
	{
		if (paused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	public function focusIn()
	{
		// nada
	}

	public function backgroundVideo(source:String) // for background videos
	{
		#if false // cpp
		useVideo = true;

		FlxG.stage.window.onFocusOut.add(focusOut);
		FlxG.stage.window.onFocusIn.add(focusIn);

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		//WebmPlayer.SKIP_STEP_LIMIT = 90;
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		add(videoSprite);
		add(gf);
		add(boyfriend);
		add(dad);

		trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	function noteMiss(direction:Int = 1, daNote:Note, wasHitSpike:Bool = false):Void
	{
		// ignore trinket nodes (as they are optional)
		if (daNote != null && daNote.isTrinket())
			return;

		// only process this if spike was actually hit (this is called for a hit spike)
		if (daNote != null && daNote.isSpike() && !wasHitSpike)
			return;

		vocals.volume = 0;

		if (!boyfriend.stunned)
		{		
			boyfriend.newStunned = true;

			//health -= 0.2;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			if (daNote != null)
			{
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
					]);
					saveJudge.push("miss");
				}
			}
			else if (!loadRep)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					-(166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166)
				]);
				saveJudge.push("miss");
			}

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			if (daNote != null)
			{
				if (daNote.isSpike())
					songScore -= 100;
				else if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;
			
			if(FlxG.save.data.missSounds)
				{
					FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.4));
					// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
					// FlxG.log.add('played imss note');
				}


			// Hole switch statement replaced with a single line :)
			boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			#if cpp
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	/*function badNoteCheck()
			{
				// just double pasting this shit cuz fuk u
				// REDO THIS SYSTEM!
				var upP = controls.UP_P;
				var rightP = controls.RIGHT_P;
				var downP = controls.DOWN_P;
				var leftP = controls.LEFT_P;

				if (leftP)
					noteMiss(0);
				if (upP)
					noteMiss(2);
				if (rightP)
					noteMiss(3);
				if (downP)
					noteMiss(1);
				updateAccuracy();
			}
	 */
	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		
		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.judgeNote(note);

		/* if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note, false);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note, false);
					}
				}
		}*/

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));

			/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false); */
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -((note.strumTime - Conductor.songPosition) / songMultiplier);


		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.judgeNote(note);

		if (note.rating == "miss")
			return;

		if (note.playerCanSkipThisNote())
		{
			// Ignore skippable notes only if pressed too late
			if (noteDiff > 0 && (note.rating == "bad" || note.rating == "shit"))
				return;
		}

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note);

				// Just double check if player
				if (note.isTrinket() && note.mustPress)
				{
					++numTrinketsCollected;

					FlxG.sound.play(Paths.sound('trinket'), 0.35);

					// Is nice to have, but feels like GF should cheer too, but that might be
					// confusing with the gf cheer event.
					if (boyfriend.animation.getByName('hey') != null && !boyfriend.isSigning())
					{
						boyfriend.playAnim('hey', true);
						bfCollectedTrinket = 2;
					}

					if (!PlayStateChangeables.botPlay)
					{
						playerStrums.forEach(function(spr:StaticArrow)
						{
							pressArrow(spr, spr.ID, note);
						});
					}

					if (note.ghost != null)
						flipNoteGhosts.remove(note.ghost, true);

					note.kill();
					notes.remove(note, true);
					note.destroy();
					return;
				}
				else if (!note.isSpike())
				{
					combo += 1;
				}
			}
			
			var altAnim:String = "";
			if (note.isAlt)
				{
					altAnim = '-alt';
					trace("Alt note on BF");
				}

			if (!note.isTrinket() && !note.isSpike())
				boyfriend.playAnim('sing' + dataSuffix[note.noteData] + altAnim, true);

			vocals.volume = 1;
			boyfriend.newStunned = false;


			#if cpp
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			if (!PlayStateChangeables.botPlay)
			{
				playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, note);
				});
			}

			if (!note.isSustainNote)
			{
				if (note.ghost != null)
					flipNoteGhosts.remove(note.ghost, true);

				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
			{
				note.wasGoodHit = true;
			}
			if (!note.isSustainNote)
				updateAccuracy();
		}
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (!FlxG.save.data.stepMania)
			{
				spr.playAnim('confirm', true);
			}
			else
			{
				spr.playAnim('dirCon' + daNote.originColor, true);
				spr.localAngle = daNote.originAngle;
			}
		}
	}
	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (FlxG.save.data.distractions)
		{
			var fastCar = Stage.swagBacks['fastCar'];
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (FlxG.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			Stage.swagBacks['fastCar'].velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if (FlxG.save.data.distractions)
		{
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;
				gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				var phillyTrain = Stage.swagBacks['phillyTrain'];
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
	}

	function trainReset():Void
	{
		if (FlxG.save.data.distractions)
		{
			gf.playAnim('hairFall');
			Stage.swagBacks['phillyTrain'].x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		Stage.swagBacks['halloweenBG'].animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();

		if (!endingSong && (FlxG.sound.music.time > Conductor.songPosition + 100 || FlxG.sound.music.time < Conductor.songPosition - 100))
		{
			// Most likey being called when rate is below 1
			resyncVocals();
		}
		// Some cases where vocals reset but not the music
		else if (!endingSong && SONG.needsVoices && (vocals.time > FlxG.sound.music.time + 100 || vocals.time < FlxG.sound.music.time - 100))
		{
			vocals.time = Conductor.songPosition;
			vocals.play();
		}

		if (!PlayStateChangeables.Optimize)
		for (step in Stage.slowBacks.keys())
		{
			if (step == curStep)
			{
				if (Stage.hideLastBG)
				{
					for (bg in Stage.swagBacks)
					{
						if (!Stage.slowBacks[step].contains(bg))
							FlxTween.tween(bg, {alpha: 0}, Stage.tweenDuration);
					}
					for (bg in Stage.slowBacks[step])
					{
						FlxTween.tween(bg, {alpha: 1}, Stage.tweenDuration);
					}
				}
				else
				{
					for (bg in Stage.slowBacks[step])
						bg.visible = !bg.visible;
				}
			}
		}

		#if cpp
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}


	
		#end
	
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if cpp
		if (executeModchart && luaModchart != null)
		{
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if (curSong == 'Tutorial' && dad.curCharacter == 'gf' && currentSection != null)
		{
			if (currentSection.mustHitSection)
				dad.dance();
			else
			{
				if (curBeat == 73 || curBeat % 4 == 0 || curBeat % 4 == 1)
					dad.playAnim('danceLeft', true);
				else
					dad.playAnim('danceRight', true);
			}
		}
		else if (gfIsCheering)
		{
			if (gf.animation.curAnim != null && gf.animation.curAnim.name.startsWith('cheer'))
			{
				++gfCheerNumBeats;

				if (gfCheerNumBeats >= gfBeatsToCheerFor && gf.animation.curAnim.finished)
				{
					gfIsCheering = false;
				}
			}
			else
			{
				gfIsCheering = false;
			}	
		}

		if (currentSection != null && !endingSong)
		{
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (!dad.isSigning() && dad.curCharacter != 'gf')
				if ((getCurBeatNowPlusOne() % idleBeat == 0 || idleToBeat) || dad.curCharacter == "spooky")
				{
					var force:Bool = idleToBeat || dad.animation.curAnim.name.startsWith("idle");

					// Basically, we need to force idle during pushing onwards rush sections. Senpais default
					// idle animation is too long that it takes up more than 2 beats (when playing senpai (the song))
					// Could the idle animation for senpai be cut down perhaps?
					if (force && dad.curCharacter == 'senpai')
						force = dad.animation.curAnim.finished;

					dad.dance(force, currentSection.CPUAltAnim);
				}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		/*
		if (FlxG.save.data.camzoom && Conductor.bpm < 340)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && (curBeat + 1) % (idleBeat * 2) == 0)//curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015 / songMultiplier;
				camHUD.zoom += 0.03 / songMultiplier;
			}
		}
		*/

		/*
		var iconScale:Float = helperHasFlipEvents() ? 0.70 : 1.0;
		if (Conductor.bpm < 340)
		{	
			iconP1.setGraphicSize(Std.int((iconP1.width + 30) * iconScale));
			iconP2.setGraphicSize(Std.int((iconP2.width + 30) * iconScale));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		else
		{
	
			iconP1.setGraphicSize(Std.int((iconP1.width + 4) * iconScale));
			iconP2.setGraphicSize(Std.int((iconP2.width + 4) * iconScale));
	
			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		*/

		if (!endingSong && currentSection != null)
		{
			if (!gfIsCheering && curBeat % gfSpeed == 0)
			{
				gf.dance();
			}

			if (bfCollectedTrinket > 0)
				--bfCollectedTrinket;

			if (!boyfriend.isSigning() && (getCurBeatNowPlusOne() % idleBeat == 0 || idleToBeat) && bfCollectedTrinket <= 0)
			{
				var force:Bool = idleToBeat || boyfriend.animation.curAnim.name.startsWith("idle");
				boyfriend.playAnim('idle' + ((currentSection.playerAltAnim && boyfriend.animation.getByName('idle-alt') != null) ? '-alt' : ''), force);//idleToBeat);
			}

			/*if (!dad.animation.curAnim.name.startsWith("sing"))
			{
				dad.dance();
			}*/

			if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			{
				boyfriend.playAnim('hey', true);
			}

			if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				boyfriend.playAnim('hey', true);
				dad.playAnim('cheer', true);
			}

			if (!PlayStateChangeables.Optimize)
			switch (Stage.curStage)
			{
				case 'school':
					if (FlxG.save.data.distractions && Stage.swagBacks['bgGirls'] != null)
					{
						Stage.swagBacks['bgGirls'].dance();
					}

				case 'mall':
					if (FlxG.save.data.distractions)
					{
						for (bg in Stage.animatedBacks)
							bg.animation.play('idle', true);
					}

				case 'limo':
					if (FlxG.save.data.distractions)
					{
						Stage.swagGroup['grpLimoDancers'].forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});

						if (FlxG.random.bool(10) && fastCarCanDrive)
							fastCarDrive();
					}
				case "philly":
					if (FlxG.save.data.distractions)
					{
						if (!trainMoving)
							trainCooldown += 1;

						if (getCurBeatNowPlusOne() % 4 == 0)
						{
							var phillyCityLights = Stage.swagGroup['phillyCityLights'];
							phillyCityLights.forEach(function(light:FlxSprite)
							{
								light.visible = false;
							});

							var prevLight = curLight;
							while (phillyCityLights.length > 1 && curLight == prevLight)
								curLight = FlxG.random.int(0, phillyCityLights.length - 1);

							phillyCityLights.members[curLight].visible = true;
							// phillyCityLights.members[curLight].alpha = 1;
							
						}
					}

					if (curBeat % 8 == 4 && FlxG.random.bool(Conductor.bpm > 320 ? 150 : 30) && !trainMoving && trainCooldown > 8)
					{
						if (FlxG.save.data.distractions)
						{
							trainCooldown = FlxG.random.int(-4, 0);
							trainStart();
						}
					}
				case 'spaceship':
					if (FlxG.save.data.distractions)
					{
						if (getCurBeatNowPlusOne() % idleBeat == 0)
						{
							Stage.swagGroup['starsL1'].forEach(function(star:SpaceStar)
							{
								star.beatHit(songTime);
							});

							Stage.swagGroup['starsL2'].forEach(function(star:SpaceStar)
							{
								star.beatHit(songTime);
							});
						}
					}
			}

			if (!PlayStateChangeables.Optimize)
			if (Stage.halloweenLevel && FlxG.random.bool(Conductor.bpm > 320 ? 100 : 10) && curBeat > lightningStrikeBeat + lightningOffset)
			{
				if (FlxG.save.data.distractions)
				{
					lightningStrikeShit();
				}
			}
		}
	}

	public var cleanedSong:SwagSong;

	function poggers(?cleanTheSong = false)
		{
			var notes = [];

			if (cleanTheSong)
			{
				cleanedSong = SONG;
		
				for(section in cleanedSong.notes)
				{
					
					var removed = [];
		
					for(note in section.sectionNotes)
					{
						// commit suicide
						var old = note[0];
						if (note[0] < section.startTime)
						{
							notes.push(note);
							removed.push(note);
						}
						if (note[0] > section.endTime)
						{
							notes.push(note);
							removed.push(note);
						}
					}
		
					for(i in removed)
					{
						section.sectionNotes.remove(i);
					}
				}
		
				for(section in cleanedSong.notes)
				{
		
					var saveRemove = [];
		
					for(i in notes)
					{
						if (i[0] >= section.startTime && i[0] < section.endTime)
						{
							saveRemove.push(i);
							section.sectionNotes.push(i);
						}
					}
		
					for(i in saveRemove)
						notes.remove(i);
				}
		


				trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);


				SONG = cleanedSong;
			}
			else
			{
		
				for(section in SONG.notes)
				{
					
					var removed = [];
		
					for(note in section.sectionNotes)
					{
						// commit suicide
						var old = note[0];
						if (note[0] < section.startTime)
						{
							notes.push(note);
							removed.push(note);
						}
						if (note[0] > section.endTime)
						{
							notes.push(note);
							removed.push(note);
						}
					}
		
					for(i in removed)
					{
						section.sectionNotes.remove(i);
					}
				}
		
				for(section in SONG.notes)
				{
		
					var saveRemove = [];
		
					for(i in notes)
					{
						if (i[0] >= section.startTime && i[0] < section.endTime)
						{
							saveRemove.push(i);
							section.sectionNotes.push(i);
						}
					}
		
					for(i in saveRemove)
						notes.remove(i);
				}
		


				trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);


				SONG = cleanedSong;
			}
		}

	var curLight:Int = 0;

	// Returns false if flipping is disabled
	function helperHasFlipEvents():Bool
	{
		return PlayStateChangeables.enableFlip && hasFlipEvents;
	}

	// Returns if flip ghost notes should be used
	function helperUseFlipGhostForNotes():Bool
	{
		return PlayStateChangeables.enableGhostNotesForFlip && helperHasFlipEvents();
	}

	// Tweens zoom in for boyfriend/gf cheer when results creen pops up
	function cheerForResults():Void
	{
		if (!cheerOnVictory)
			return;

		// Some sprite sheets may not have a hey animation
		if (boyfriend.animation.getByName('hey') == null)
			return;

		// Focus on boyfriend
		camFollow.setPosition(boyfriend.getMidpoint().x, boyfriend.getMidpoint().y);
		{
			camZoomManuallyControlled = true;

			var onUpdateZoom = function(val:Float)
			{
				setCamZoom(val, true);
			};

			var onZoomComplete = function(tween:FlxTween)
			{
				boyfriend.playAnim('hey', true);
				gf.playAnim('cheer', true);
			};

			FlxTween.num(setCameraZoom, 1.2, 1,
				{ ease: FlxEase.quadIn, type: ONESHOT, onComplete: onZoomComplete }, onUpdateZoom.bind());
		}
	}

	function flipCharactersImpl(flipDad:Bool, flipBf:Bool)
	{
		if (!flipDad && !flipBf)
			return;

		if (PlayStateChangeables.enableFlip)
		{
			if (flipDad)
			{
				dad.flipSelf();
				cpuIsFlipping = !wtfMode;
				cpuSpriteFlipping = true;
				cpuFlipStart = songTime;

				if (cpuIsFlipping)
				{
					var flipUp = dad.isFlipped == PlayStateChangeables.useDownscroll;
					// Assuming 4 keys
					var leftSideKey = cpuStrums.members[0];
					var rightSideKey = cpuStrums.members[3];
					spawnFlipVFXAround(flipUp, leftSideKey.x - 50, rightSideKey.x + rightSideKey.width + 50);
				}
			}

			if (flipBf)
			{
				boyfriend.flipSelf();
				playerIsFlipping = !wtfMode;
				playerSpriteFlipping = true;
				playerFlipStart = songTime;

				if (playerIsFlipping)
				{
					var flipUp = boyfriend.isFlipped == PlayStateChangeables.useDownscroll;
					// Assuming 4 keys
					var leftSideKey = playerStrums.members[0];
					var rightSideKey = playerStrums.members[3];
					spawnFlipVFXAround(flipUp, leftSideKey.x - 50, rightSideKey.x + rightSideKey.width + 50);
				}
			}

			if (!wtfMode)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if ((!daNote.mustPress && !flipDad) ||
						(daNote.mustPress && !flipBf))
					{
						return;
					}

					// !! Do this first before setting up flip ghost (as we need flipY correct)
					if (daNote.isSustainNote)
					{
						if (daNote.mustPress)
							daNote.flipY = PlayStateChangeables.useDownscroll != boyfriend.isFlipped;
						else
							daNote.flipY = PlayStateChangeables.useDownscroll != dad.isFlipped;
					}

					if (PlayStateChangeables.enableGhostNotesForFlip)
						if (daNote.setupGhostForFlip())
							flipNoteGhosts.add(daNote.ghost);
				});
			}
		}
	}

	function setCamZoom(newCamZoom:Float, updateCamNow:Bool = false)
	{
		setCameraZoom = newCamZoom;
		if (updateCamNow)
			FlxG.camera.zoom = setCameraZoom;
	}

	function spawnFlipVFXAround(goUp:Bool, xMin:Float, xMax:Float)
	{
		if (flipVFXPool == null)
			return;

		if (numFlipVFXPerFlip <= 0 || !FlxG.save.data.flipVFX)
			return;

		// Assumes xMin < xMax and vfx.width < jump

		var distance:Float = xMax - xMin;
		var jump:Float = distance / numFlipVFXPerFlip;

		for (i in 0...numFlipVFXPerFlip)
		{
			var vfx:FlipVFX = flipVFXPool.getFirstDead();
			if (vfx == null)
			{
				vfx = new FlipVFX(0, 0);
				flipVFXPool.add(vfx);
			}

			vfx.alive = true;
			vfx.active = true;

			// More evenly distributed
			var minXPos = jump * i;
			var maxXPos:Float = (jump * (i + 1)) - vfx.width;
			maxXPos = maxXPos < minXPos ? minXPos : maxXPos;

			vfx.x = FlxG.random.float(xMin + minXPos, xMin + maxXPos);
			if (goUp)
			{
				vfx.y = FlxG.random.float(1, 750) + FlxG.height;
				vfx.velocity.y = -flipVFXVelY;
			}
			else
			{
				vfx.y = -FlxG.random.float(1, 750) - vfx.height;
				vfx.velocity.y = flipVFXVelY;
			}

			vfx.flipY = !goUp;
		}
	}
}
//u looked :O -ides

package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;

using StringTools;

// A 'Fake' note, just meant to help represent a note when flipping
class NoteGhost extends FlxSprite
{
	// Note this ghost note belongs to
	public var ogNote:Note = null;

	public function new(ogNote:Note)
	{
		super();

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		this.ogNote = ogNote;

		scale = ogNote.scale;
		width = ogNote.width;
		height = ogNote.height;
		color = ogNote.color;
		scrollFactor = ogNote.scrollFactor;

		frames = ogNote.frames;
		animation.copyFrom(ogNote.animation);

		updateHitbox();
	}
}

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;
	
	public var charterSelected:Bool = false;

	public var rStrumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var originColor:Int = 0; // The sustain note's original note's color
	public var noteSection:Int = 0;

	public var luaID:Int = 0;

	public var isAlt:Bool = false;

	public var noteCharterObject:FlxSprite;

	public var noteScore:Float = 1;

	public var noteYOff:Int = 0;

	public var beat:Float = 0;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside Note.hx
	public var originAngle:Float = 0; // The angle the OG note of the sus note had (?)

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	public var quantityColor:Array<Int> = [RED_NOTE, 2, BLUE_NOTE, 2, PURP_NOTE, 2, GREEN_NOTE, 2];
	public var arrowAngles:Array<Int> = [180, 90, 270, 0];

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var children:Array<Note> = [];

	// Type of note this is (see NoteTypes)
	public var noteType:Int = NoteTypes.NORMAL;

	// When flipping, this is our 'Ghost' note (interpolates the opposite of us)
	// Requires ghost notes for flipping enabled
	public var ghost:NoteGhost = null;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, ?isAlt:Bool = false, ?bet:Float = 0, 
		?noteType:Int = NoteTypes.NORMAL)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		beat = bet;

		if (noteType == null)
			noteType = NoteTypes.NORMAL;

		this.noteType = noteType;

		this.isAlt = isAlt;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (inCharter)
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}
		else
		{
			this.strumTime = strumTime;
			#if sys
			if (PlayState.isSM)
			{
				rStrumTime = strumTime;
			}
			else
				rStrumTime = strumTime;
			#else
			rStrumTime = strumTime;
			#end
		}


		if (this.strumTime < 0 )
			this.strumTime = 0;

		if (!inCharter)
			y += FlxG.save.data.offset + PlayState.songOffset;

		this.noteData = noteData;

		var daStage:String = PlayState.Stage.curStage;

		//defaults if no noteStyle was found in chart
		var noteVisTypeCheck:String = 'normal';

		if (inCharter)
		{
			frames = Paths.getSparrowAtlas('NOTE_assets');

			for (i in 0...4)
			{
				animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
				animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
				animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails

				animation.addByPrefix(dataColor[i] + 'Spike', dataColor[i] + ' spike'); // Spikes
			}

			animation.addByPrefix('trinket', 'trinket', 24, false);

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();

			antialiasing = FlxG.save.data.antialiasing;
		}
		else
		{
			if (isTrinket())
			{
				frames = Paths.getSparrowAtlas('NOTE_assets');
				animation.addByPrefix('trinket', 'trinket', 24, false);

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();

				antialiasing = FlxG.save.data.antialiasing;
			}
			else if (isSpike())
			{
				frames = Paths.getSparrowAtlas('NOTE_assets');

				for (i in 0...4)
				{
					animation.addByPrefix(dataColor[i] + 'Spike', dataColor[i] + ' spike'); // Spikes
				}

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();

				antialiasing = FlxG.save.data.antialiasing;
			}
			else
			{
				if (PlayState.SONG.noteStyle == null) {
					switch(PlayState.storyWeek) {case 6: noteVisTypeCheck = 'pixel';}
				} else {noteVisTypeCheck = PlayState.SONG.noteStyle;}
			
				switch (noteVisTypeCheck)
				{
					case 'pixel':
						loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
						if (isSustainNote)
							loadGraphic(Paths.image('weeb/pixelUI/arrowEnds', 'week6'), true, 7, 6);

						for (i in 0...4)
						{
							animation.add(dataColor[i] + 'Scroll', [i + 4]); // Normal notes
							animation.add(dataColor[i] + 'hold', [i]); // Holds
							animation.add(dataColor[i] + 'holdend', [i + 4]); // Tails
						}

						setGraphicSize(Std.int(width * PlayState.daPixelZoom));
						updateHitbox();
					default:
						frames = Paths.getSparrowAtlas('NOTE_assets');

						for (i in 0...4)
						{
							animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
							animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
							animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
						}

						setGraphicSize(Std.int(width * 0.7));
						updateHitbox();

						antialiasing = FlxG.save.data.antialiasing;
				}
			}
		}

		x += swagWidth * noteData;
		playNoteAnim();
		originColor = noteData; // The note's origin color will be checked by its sustain notes

		if (FlxG.save.data.stepMania && !isSustainNote && !PlayState.instance.executeModchart)
		{
			var col:Int = 0;

			var beatRow = Math.round(beat * 48);

			// STOLEN ETTERNA CODE (IN 2002)

			if (beatRow % (192 / 4) == 0)
				col = quantityColor[0];
			else if (beatRow % (192 / 8) == 0)
				col = quantityColor[2];
			else if (beatRow % (192 / 12) == 0)
				col = quantityColor[4];
			else if (beatRow % (192 / 16) == 0)
				col = quantityColor[6];
			else if (beatRow % (192 / 24) == 0)
				col = quantityColor[4];
			else if (beatRow % (192 / 32) == 0)
				col = quantityColor[4];


			animation.play(dataColor[col] + 'Scroll');
			localAngle -= arrowAngles[col];
			localAngle += arrowAngles[noteData];
			originAngle = localAngle;
			originColor = col;
		}
		
		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		// then what is this lol
		// BRO IT LITERALLY SAYS IT FLIPS IF ITS A TRAIL AND ITS DOWNSCROLL
		//if (FlxG.save.data.downscroll && sustainNote) 
		//	flipY = true;
		// This snippet ^ now done in when spawning in note

		
		var stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed, 2));

		// we can't divide step height cuz if we do uh it'll fucking lag the shit out of the game

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			originColor = prevNote.originColor; 
			originAngle = prevNote.originAngle;

			animation.play(dataColor[originColor] + 'holdend'); // This works both for normal colors and quantization colors
			updateHitbox();

			x -= width / 2;

			//if (noteVisTypeCheck == 'pixel')
			//	x += 30;
			if (inCharter)
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(dataColor[prevNote.originColor] + 'hold');
				prevNote.updateHitbox();


				prevNote.scale.y *= (stepHeight + 1) / prevNote.height; // + 1 so that there's no odd gaps as the notes scroll
				prevNote.updateHitbox();
				prevNote.noteYOff = Math.round(-prevNote.offset.y);

				// prevNote.setGraphicSize();

				noteYOff = Math.round(-offset.y);
			}
		}
	}

	override public function destroy()
	{
		super.destroy();

		if (ghost != null)
			ghost.destroy();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!modifiedByLua)
			angle = modAngle + localAngle;
		else
			angle = modAngle;

		if (!modifiedByLua)
		{
			if (!sustainActive)
			{
				alpha = 0.3;
			}
		}

		if (mustPress)
		{
			if (isSustainNote)
			{
				if (strumTime - Conductor.songPosition  <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1) * 0.5))
					&& strumTime - Conductor.songPosition  >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime - Conductor.songPosition  <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1)))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
			/*if (strumTime - Conductor.songPosition < (-166 * Conductor.timeScale) && !wasGoodHit)
				tooLate = true;*/
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate && !wasGoodHit)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}

		if (isTrinket())
		{
			var r:Int = 200 - FlxG.random.int(0, 64);
			var g:Int = 200 - FlxG.random.int(0, 128);
			var b:Int = 164 + FlxG.random.int(0, 60);
			color = FlxColor.fromRGB(r, g, b);
		}
		
		if (ghost != null && ghost.visible)
			ghost.color = color;
	}

	override function kill()
	{
		super.kill();

		if (ghost != null)
			ghost.kill();
	}

	public function playNoteAnim()
	{
		if (isTrinket())
			animation.play('trinket');
		else if (isSpike())
			animation.play(dataColor[noteData] + 'Spike');
		else
			animation.play(dataColor[noteData] + 'Scroll');
	}

	// Small check if bots (both CPU and BotPlay) should avoid this note
	public function botShouldAvoidNote():Bool
	{
		return isTrinket() || isSpike();
	}

	// If the player is allowed to skip hitting this note without penalty
	public function playerCanSkipThisNote():Bool
	{
		return isTrinket() || isSpike();
	}

	// Helper for if this note is a trinket
	public function isTrinket():Bool
	{
		return noteType == NoteTypes.TRINKET;
	}

	// Helper for if this note is a spike
	public function isSpike():Bool
	{
		return noteType == NoteTypes.SPIKE;
	}

	// Helper for creating a ghost note for when flipping
	// This returns if the ghost was just created and needs to be added to the fixed group
	public function setupGhostForFlip():Bool
	{
		var justCreated:Bool = false;
		if (ghost == null)
		{
			ghost = new NoteGhost(this);
			justCreated = true;
		}

		ghost.flipY = isSustainNote ? !flipY : flipY;
		ghost.alpha = alpha;
		ghost.visible = true;
		ghost.active = true;
		return justCreated;
	}
}

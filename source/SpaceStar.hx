package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;

class SpaceStar extends FlxSprite
{
	// This is half the limit (-Half, Half)
	public static var spaceshipLimitX:Float = 1700;
	public static var spaceshipLimitY:Float = 750;

	// Stage offset for spaceship (specifically stars)
	public static var spaceshipOffsetX:Float = 800;
	public static var spaceshipOffsetY:Float = 300;

	private var beatTime:Float = -1.0;
	private var timeSinceBeat = 0.0;
	private var originalWidth:Float;
	private var originalHeight:Float;
	private var beatWidth:Float;
	private var beatHeight:Float;
	private var rotateOnBeat:Bool;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		loadGraphic(Paths.image('spaceship_star', 'week7'));

		// To be on the safe side (I'm not sure if this engine does collision detection automatically)
		allowCollisions = 0;
	}

	override function update(elapsed:Float)
	{
		// Assuming speed is a positive value, we want to move to the left
		if (x <= (-spaceshipLimitX + spaceshipOffsetX))
		{
			x += spaceshipLimitX * 2;

			var randY:Float = FlxG.random.float(-SpaceStar.spaceshipLimitY, SpaceStar.spaceshipLimitY);
			y = randY + SpaceStar.spaceshipOffsetY;
		}

		if (beatTime >= 0)
		{
			var t:Float = 1.0;
			var beatDuration:Float = Conductor.crochet * 0.001;

			timeSinceBeat += elapsed;
			if (timeSinceBeat < beatDuration)
			{
				t = FlxEase.cubeOut(timeSinceBeat / beatDuration);
			}
			else
			{
				beatTime = -1.0;
			}

			var newWidth:Int = Std.int(FlxMath.lerp(beatWidth, originalWidth, t));
			var newHeight:Int = Std.int(FlxMath.lerp(beatHeight, originalHeight, t));
			setGraphicSize(newWidth, newHeight);

			//if (rotateOnBeat)
			//	angle = FlxMath.lerp(0, 180, t); // Stars are currently just grey squares
		}

		super.update(elapsed);
	}

	public function initStar(randScale:Float, beatScale:Float, rotateOnBeat:Bool)
	{
		originalWidth = width * randScale;
		originalHeight = height * randScale;
		beatWidth = originalWidth * beatScale;
		beatHeight = originalHeight * beatScale;

		setGraphicSize(Std.int(originalWidth), Std.int(originalHeight));

		this.rotateOnBeat = rotateOnBeat;
	}

	public function beatHit(songTime:Float)
	{
		beatTime = songTime;
		timeSinceBeat = 0.0;
		setGraphicSize(Std.int(beatWidth), Std.int(beatHeight));
	}
}

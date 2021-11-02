package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;

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

	public function new(x:Float, y:Float)
	{
		super(x, y);

		loadGraphic(Paths.image('spaceship_star', 'week7'));
	}

	override function update(elapsed:Float)
	{
		// Assuming speed is a positive value, we want to move to the left
		if (x <= (-spaceshipLimitX + spaceshipOffsetX))
		{
			x += spaceshipLimitX * 2;
		}

		if (beatTime >= 0)
		{
			var t:Float = 1.0;

			timeSinceBeat += elapsed;
			if (timeSinceBeat < 0.25)
			{
				t = timeSinceBeat / 0.25;
				t = 1 - (--t) * t * t * t;
			}
			else
			{
				beatTime = -1.0;
			}

			var newWidth:Int = Std.int(FlxMath.lerp(beatWidth, originalWidth, t));
			var newHeight:Int = Std.int(FlxMath.lerp(beatHeight, originalHeight, t));
			setGraphicSize(newWidth, newHeight);
		}

		super.update(elapsed);
	}

	public function initStar(randScale:Float, beatScale:Float)
	{
		originalWidth = width * randScale;
		originalHeight = height * randScale;
		beatWidth = originalWidth * beatScale;
		beatHeight = originalHeight * beatScale;

		setGraphicSize(Std.int(originalWidth), Std.int(originalHeight));
	}

	public function beatHit(songTime:Float)
	{
		beatTime = songTime;
		timeSinceBeat = 0.0;
		setGraphicSize(Std.int(beatWidth), Std.int(beatHeight));
	}
}

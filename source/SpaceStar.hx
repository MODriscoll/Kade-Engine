package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;

class SpaceStar extends FlxSprite
{
	// This is half the limit (-Half, Half)
	public static var spaceshipLimitX:Float = 2000;
	public static var spaceshipLimitY:Float = 750;

	// Stage offset for spaceship (specifically stars)
	public static var spaceshipOffsetX:Float = 1000;
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

class LaboratoryBGBox extends FlxSprite
{
	// This is half the limit (-Half, Half)
	public static var limitX:Float = 2500;
	public static var limitY:Float = 1500;

	public var speed:Float = 2400;

	// FlxTimer seems to be paused when game over ends (prob due to entering a sub-state)
	// I still want these to be active during the game over screen
	private var resetTimer:Float = -1.0;

	private var beatTime:Float = -1.0;
	private var timeSinceBeat:Float = 0.0;
	private var baseWidth:Float;
	private var baseHeight:Float;
	private var beatScale:Float = 1.2;

	private var velCustom:FlxPoint = new FlxPoint(0, 0);

	public function new(x:Float, y:Float, speed:Float)
	{
		super(x, y);
		this.speed = speed;

		loadGraphic(Paths.image('laboratory_bg_box', 'week7'));
		baseWidth = width;
		baseHeight = height * 1.25; // resetBox call will properly update our size

		// To be on the safe side (I'm not sure if this engine does collision detection automatically)
		allowCollisions = 0;

		resetBox(true);

		// We handle this ourselves
		moves = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (resetTimer > 0)
		{
			resetTimer -= elapsed;
			if (resetTimer <= 0)
			{
				alpha = 1;
				resetBox();

				resetTimer = -1;
			}
		}
		else if (isOutOfBounds())
		{
			alpha = 0; // This actually disables drawing, it doesn't just draw transparent pixels
			resetTimer = FlxG.random.float(0.1, 0.6);
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
		
			var curScale:Float = FlxMath.lerp(beatScale, 1, t);
			var newWidth:Int = Std.int(baseWidth * curScale);
			var newHeight:Int = Std.int(baseHeight * curScale);
			setGraphicSize(newWidth, newHeight);
		}

		// Would normally use velocity, but we to move ourselves based off the center point
		{
			var curPos = getMidpoint();
			var curX:Float = curPos.x + (velCustom.x * elapsed);
			var curY:Float = curPos.y + (velCustom.y * elapsed);

			x = curX - (width * 0.5);
			y = curY - (height * 0.5);
		}
	}

	function resetBox(fullReset:Bool = false)
	{
		var dir = FlxG.random.int(0, 3);
		switch (dir)
		{
			case 0: // Left
			{
				angle = 0;
				updateHitbox();

				x = fullReset ? FlxG.random.float(-limitX * 0.8, limitX * 0.8) : (limitX - (baseWidth * 0.6));
				y = FlxG.random.float(-limitY * 0.8, limitY * 0.8);
				velCustom.set(-speed, 0);
			}
			case 1: // Right
			{
				angle = 0;
				updateHitbox();

				x = fullReset ? FlxG.random.float(-limitX * 0.8, limitX * 0.8) : (-limitX - (baseWidth * 0.4));
				y = FlxG.random.float(-limitY * 0.8, limitY * 0.8);
				velCustom.set(speed, 0);
			}
			case 2: // Up
			{
				angle = 90;
				updateHitbox();

				x = FlxG.random.float(-limitX * 0.8, limitX * 0.8);
				y = fullReset ? FlxG.random.float(-limitY * 0.8, limitY * 0.8) : (limitY - (baseHeight * 0.6));
				velCustom.set(0, -speed);
			}
			case 3: // Down
			{
				angle = 90;
				updateHitbox();

				x = FlxG.random.float(-limitX * 0.8, limitX * 0.8);
				y = fullReset ? FlxG.random.float(-limitY * 0.8, limitY * 0.8) : (-limitY - (baseHeight * 0.4));
				velCustom.set(0, speed);
			}
		}

		beatTime = -1;
		setGraphicSize(Std.int(baseWidth), Std.int(baseHeight));
	}

	function isOutOfBounds():Bool
	{
		var midPoint:FlxPoint = getMidpoint();
		return Math.abs(midPoint.x) > limitX || Math.abs(midPoint.y) > limitY;
	}

	public function initBox(beatScale:Float)
	{
		this.beatScale = beatScale;
	}

	public function beatHit(songTime:Float)
	{
		beatTime = songTime;
		timeSinceBeat = 0.0;
		setGraphicSize(Std.int(baseWidth), Std.int(baseHeight));
	}
}
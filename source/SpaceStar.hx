package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class SpaceStar extends FlxSprite
{
	// This is half the limit (-Half, Half)
	public static var spaceshipLimitX:Float = 1600;
	public static var spaceshipLimitY:Float = 750;

	// Stage offset for spaceship (specifically stars)
	public static var spaceshipOffsetX:Float = 800;
	public static var spaceshipOffsetY:Float = 300;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		loadGraphic(Paths.image('spaceship_star', 'week7'));

		// Update is called manually for us (updatePos)
		active = false;
	}

	public function updatePos(speed:Float, deltaTime:Float)
	{
		// Assuming speed is a positive value, we want to move to the left
		x += -speed * deltaTime;
		if (x <= (-spaceshipLimitX + spaceshipOffsetX))
		{
			x += spaceshipLimitX * 2;
		}
	}
}

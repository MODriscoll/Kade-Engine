package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class FlipVFX extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		// TODO: Make a custom sprite for this, for now
		makeGraphic(64, 64, FlxColor.RED);
		alpha = 0.6;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Math.abs(y - (FlxG.height * 0.5)) >= 3000) // 3000 should be plenty
		{
			active = false;
			alive = false;
		}
	}
}

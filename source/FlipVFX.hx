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

		loadGraphic(Paths.image('flip_vfx', 'week7'));
		setGraphicSize(Std.int(width * 1.2), Std.int(height * 1.2));
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

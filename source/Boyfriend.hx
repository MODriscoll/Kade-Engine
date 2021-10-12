package;

import flixel.math.FlxAngle.FlxSinCos;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	// I tried using trails but it made bf update at twice the speed
	private var spookyGhost:Boyfriend = null;

	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				playAnim('idle', true, false, 10);
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);

		if (spookyGhost != null)
		{
			spookyGhost.angle = angle;
			// Since offset is used for anims, we need to manually offset via position here
			spookyGhost.x = x + (300 * FlxMath.fastCos(angle * Math.PI / 180.0));
			spookyGhost.y = y + (300 * FlxMath.fastSin(angle * Math.PI / 180.0));
			spookyGhost.flipX = flipX;
			spookyGhost.flipY = flipY;	
		}
	}

	override function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		super.playAnim(AnimName, Force, Reversed, Frame);

		if (spookyGhost != null)
			spookyGhost.playAnim(AnimName, Force, Reversed, Frame);
	}

	public function trySpawnSpookyGhost():Boyfriend
	{
		if (PlayStateChangeables.Optimize)
			return null;

		// TODO: Higher chance on spawning closer to halloween
		var ghostChance = 0.1;
		if (!FlxG.random.bool(ghostChance))
			return null;

		spookyGhost = new Boyfriend(x + 300, y, curCharacter);
		spookyGhost.alpha = 0.4;
		return spookyGhost;
	}
}

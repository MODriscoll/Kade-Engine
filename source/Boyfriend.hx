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
	// To fix vocals sound when missing shit
	public var newStunned:Bool = false;

	// I tried using trails but it made bf update at twice the speed
	private var spookyGhost:Boyfriend = null;
	private var spookyGhostTimer:Float = 0;

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

			if (animation.curAnim.name.endsWith('miss'))
			{
				if ((animation.curAnim.finished || animation.curAnim.curFrame > 13) && !debugMode)
				{
					newStunned = false;
					playAnim('idle', true, false, 10);
				}
			}
			else
			{
				newStunned = false;
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);

		if (spookyGhost != null)
		{
			spookyGhostTimer += elapsed;

			spookyGhost.angle = angle;
			
			spookyGhost.flipX = flipX;
			spookyGhost.flipY = flipY;

			// Since offset is used for anims, we need to manually offset via position here

			var cRot = FlxMath.fastCos(angle * Math.PI / 180.0);
			var sRot = FlxMath.fastSin(angle * Math.PI / 180.0);

			var ghostX = x + (300 * cRot);
			var ghostY = y + (300 * sRot);
			{
				var a:Float = 75;
				var b:Float = 25;
				var s:Float = 3;

				var levX = a * Math.cos(spookyGhostTimer);
				var levY = b * Math.sin(spookyGhostTimer * s);
				ghostX += (cRot * levX) - (sRot * levY);
				ghostY += (sRot * levX) + (cRot * levY);
			}

			spookyGhost.x = ghostX;
			spookyGhost.y = ghostY;
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

		var ghostChance = 0.1;

		// Higher chance on Halloween
		var now:Date = Date.now();
		if (now.getDate() == 31 && now.getMonth() == 9)
			ghostChance = 10;
				
		#if cpp
		var args:Array<String> = Sys.args();
		for (i in 0...args.length)
		{
			var arg:String = args[i].toLowerCase();
			if (arg.startsWith('-'))
				arg = arg.substr(1);

			if (arg == 'spookyghost')
				ghostChance = 1000;
		}
		#end

		if (!FlxG.random.bool(ghostChance))
			return null;

		spookyGhost = new Boyfriend(x + 300, y, curCharacter);
		spookyGhost.alpha = 0.4;
		return spookyGhost;
	}
}

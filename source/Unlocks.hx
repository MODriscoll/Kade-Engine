package;

import flixel.FlxG;

class SongDiffUnlockData
{
	public function new(diff:Int, isUnlocked:Bool = false)
	{
		this.diff = diff;
		this.isUnlocked = isUnlocked;
	}

	public var diff:Int = 0;
	public var isUnlocked:Bool = false;
}

class Unlocks
{
	static public var extraHardDiff:Int = 3;

	static public function hasUnlockedDiffForSong(songName:String, diff:Int):Bool
	{
		songName = songName.toLowerCase();

		if (FlxG.save.data.songsDiffUnlocks == null)
			return true;

		var songsDiffUnlocks:Map<String, Array<SongDiffUnlockData>> = FlxG.save.data.songsDiffUnlocks;
		if (!songsDiffUnlocks.exists(songName))
			return true;

		var data:Array<SongDiffUnlockData> = songsDiffUnlocks[songName];
		if (data == null)
			return true;

		for (i in data)
			if (i.diff == diff)
				return i.isUnlocked;

		return true;
	}

	// returns if this call actually resulted in diff going from locked->unlocked
	static public function unlockDiffForSong(songName:String, diff:Int):Bool
	{
		songName = songName.toLowerCase();

		if (FlxG.save.data.songsDiffUnlocks == null)
			return false;

		var songsDiffUnlocks:Map<String, Array<SongDiffUnlockData>> = FlxG.save.data.songsDiffUnlocks;
		if (!songsDiffUnlocks.exists(songName))
			return false;

		var data:Array<SongDiffUnlockData> = songsDiffUnlocks[songName];
		if (data == null)
			return false;

		for (i in data)
			if (i.diff == diff)
			{
				var wasJustUnlocked:Bool = !i.isUnlocked;
				i.isUnlocked = true;
				return wasJustUnlocked;
			}

		return false;
	}

	static public function initUnlocks()
	{
		if (FlxG.save.data.songsDiffUnlocks != null)
			return;

		var diffsToUnlock:Map<String, Array<SongDiffUnlockData>> = [];

		// pushing onwards
		{
			var data:Array<SongDiffUnlockData> = [];
			data.push(new SongDiffUnlockData(extraHardDiff, false));

			diffsToUnlock['pushing onwards'] = data;
		}

		FlxG.save.data.songsDiffUnlocks = diffsToUnlock;
	}

	static public function resetUnlocks()
	{
		FlxG.save.data.songsDiffUnlocks = null;
		initUnlocks();
	}
}

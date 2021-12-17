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

class AltStageUnlockData
{
	public function new(name:String, isUnlocked:Bool = false)
	{
		this.name = name;
		this.isUnlocked = isUnlocked;
	}

	public var name:String = '';
	public var isUnlocked:Bool = false;
}

class Unlocks
{
	static public var extraHardDiff:Int = 3;

	static public function hasUnlockedDiffForSong(songName:String, diff:Int):Bool
	{
		songName = songName.toLowerCase();
		if (StringTools.endsWith(songName, '-inst'))
			songName = songName.substr(0, -5);

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
		if (FlxG.save.data.songsDiffUnlocks == null)
			return false;

		songName = songName.toLowerCase();
		
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

	static public function hasUnlockedStageForSong(songName:String, stageName:String):Bool
	{
		songName = songName.toLowerCase();
		if (StringTools.endsWith(songName, '-inst'))
			songName = songName.substr(0, -5);

		if (FlxG.save.data.altStageUnlocks == null)
			return true;

		var altStageUnlocks:Map<String, Array<AltStageUnlockData>> = FlxG.save.data.altStageUnlocks;
		if (!altStageUnlocks.exists(songName))
			return true;

		var data:Array<AltStageUnlockData> = altStageUnlocks[songName];
		if (data == null)
			return true;

		for (i in data)
			if (i.name == stageName)
				return i.isUnlocked;

		return true;
	}

	// returns if this call actually resulted in stage going from locked->unlocked
	static public function unlockStageForSong(songName:String, stageName:String):Bool
	{
		if (FlxG.save.data.altStageUnlocks == null)
			return false;

		songName = songName.toLowerCase();
		
		var altStageUnlocks:Map<String, Array<AltStageUnlockData>> = FlxG.save.data.altStageUnlocks;
		if (!altStageUnlocks.exists(songName))
			return false;

		var data:Array<AltStageUnlockData> = altStageUnlocks[songName];
		if (data == null)
			return false;

		for (i in data)
			if (i.name == stageName)
			{
				var wasJustUnlocked:Bool = !i.isUnlocked;
				i.isUnlocked = true;
				return wasJustUnlocked;
			}

		return false;
	}

	static public function initUnlocks()
	{
		if (FlxG.save.data.songsDiffUnlocks == null)
		{			
			var diffsToUnlock:Map<String, Array<SongDiffUnlockData>> = [];

			// pushing onwards
			{
				var data:Array<SongDiffUnlockData> = [];
				data.push(new SongDiffUnlockData(extraHardDiff, false));

				diffsToUnlock['pushing onwards'] = data;
			}

			FlxG.save.data.songsDiffUnlocks = diffsToUnlock;
		}

		if (FlxG.save.data.altStageUnlocks == null)
		{
			var stagesToUnlock:Map<String, Array<AltStageUnlockData>> = [];

			// pushing onwards
			{
				//var data:Array<AltStageUnlockData> = [];
				//data.push(new AltStageUnlockData('laboratory', false));

				//stagesToUnlock['pushing onwards'] = data;
			}

			FlxG.save.data.altStageUnlocks = stagesToUnlock;
		}

		if (FlxG.save.data.unlockedLaboratory == null)
			FlxG.save.data.unlockedLaboratory = false;
	}

	static public function hasUnlockedLaboratory():Bool
	{
		return FlxG.save.data.unlockedLaboratory;
	}

	static public function unlockLaboratory():Bool
	{
		if (hasUnlockedLaboratory())
			return false;

		FlxG.save.data.unlockedLaboratory = true;
		return true;
	}

	static public function resetUnlocks()
	{
		FlxG.save.data.songsDiffUnlocks = null;
		FlxG.save.data.altStageUnlocks = null;

		FlxG.save.data.unlockedLaboratory = null;

		initUnlocks();
	}
}

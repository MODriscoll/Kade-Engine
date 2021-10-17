package;

import flixel.FlxG;

class NoteTypes
{
	public static inline var NORMAL:Int = 0;
	public static inline var TRINKET:Int = 1; // A collectable
	public static inline var SPIKE:Int = 2; // Take damage if hit

	public static function getTypesAsStrings():Array<String>
	{
		return [ "Normal", "Trinket", "Spike"];
	}

	public static function noteTypeToString(noteType:Int):String
	{
		var asStrings:Array<String> = getTypesAsStrings();
		return noteType >= 0 && noteType < asStrings.length ? asStrings[noteType] : "Normal";
	}

	public static function stringToNoteType(string:String):Int
	{
		var asStrings:Array<String> = getTypesAsStrings();
		for (i in 0...asStrings.length)
			if (asStrings[i] == string)
				return i;

		return NORMAL;
	}
}

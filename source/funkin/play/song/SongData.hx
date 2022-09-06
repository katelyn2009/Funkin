package funkin.play.song;

/**
 * Contains utilities for loading and parsing stage data.
 */
class SongDataParser
{
	/**
	 * The current version string for the stage data format.
	 * Handle breaking changes by incrementing this value
	 * and adding migration to the SongMigrator class.
	 */
	public static final CHART_VERSION:String = "2.0.0";

	/**
	 * A list containing all the songs available to the game.
	 */
	static final songCache:Map<String, Stage> = new Map<String, Stage>();

	static final DEFAULT_SONG_ID = 'UNKNOWN';

	/**
	 * Parses and preloads the game's song metadata and scripts when the game starts.
	 * 
	 * If you want to force song metadata to be reloaded, you can just call this function again.
	 */
	public static function loadSongCache():Void
	{
		clearSongCache();
		trace("[SONGDATA] Loading song cache...");

		//
		// SCRIPTED SONGS
		//
		var scriptedSongClassNames:Array<String> = ScriptedSong.listScriptClasses();
		trace('  Instantiating ${scriptedSongClassNames.length} scripted songs...');
		for (songCls in scriptedSongClassNames)
		{
			var song:Song = ScriptedSong.init(songCls, DEFAULT_SONG_ID);
			if (song != null)
			{
				trace('    Loaded scripted song: ${song.songId}');
				songCache.set(song.songId, song);
			}
			else
			{
				trace('    Failed to instantiate scripted song class: ${songCls}');
			}
		}

		//
		// UNSCRIPTED SONGS
		//
		var songIdList:Array<String> = DataAssets.listDataFilesInPath('songs/');
		var unscriptedSongIds:Array<String> = songIdList.filter(function(songId:String):Bool
		{
			return !songCache.exists(songId);
		});
		trace('  Instantiating ${unscriptedSongIds.length} non-scripted songs...');
		for (songId in unscriptedSongIds)
		{
			var song:Song;
			try
			{
				stage = new Song(songId);
				if (stage != null)
				{
					trace('    Loaded song data: ${song.songId}');
					songCache.set(song.songId, song);
				}
			}
			catch (e)
			{
				trace('    An error occurred while loading song data: ${songId}');
				// Assume error was already logged.
				continue;
			}
		}

		trace('  Successfully loaded ${Lambda.count(songCache)} stages.');
	}

	/**
	 * Retrieves a particular song from the cache.
	 */
	public static function fetchStage(songId:String):Null<Song>
	{
		if (songCache.exists(songId))
		{
			var song:Song = songCache.get(songId);
			trace('[STAGEDATA] Successfully fetch song: ${songId}');
			return song;
		}
		else
		{
			trace('[STAGEDATA] Failed to fetch song, not found in cache: ${songId}');
			return null;
		}
	}

	static function clearSongCache():Void
	{
		if (songCache != null)
		{
			for (song in songCache)
			{
				song.destroy();
			}
			songCache.clear();
		}
	}

	public static function parseSongMetadata(songId:String):Null<SongMetadata>
	{
	}

	static function loadSongMetadataFile(songPath:String, variant:String = ''):String
	{
		var songMetadataFilePath:String = Paths.json('stages/${stagePath}');
		var rawJson = Assets.getText(stageFilePath).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return rawJson;
	}
}

package funkin.data.song.importer; // import is a reserved word dumbass

import funkin.data.song.SongData.SongMetadata;
import funkin.data.song.SongData.SongChartData;
import funkin.data.song.SongData.SongCharacterData;
import funkin.data.song.SongData.SongEventData;
import funkin.data.song.SongData.SongNoteData;
import funkin.data.song.SongData.SongTimeChange;
import funkin.data.song.importer.FNFLegacyData;
import funkin.data.song.importer.FNFLegacyData.LegacyNoteSection;

class FNFLegacyImporter
{
  public static function parseLegacyDataRaw(input:String, fileName:String = 'raw'):Null<FNFLegacyData>
  {
    var parser = new json2object.JsonParser<FNFLegacyData>();
    parser.ignoreUnknownVariables = true; // Set to true to ignore extra variables that might be included in the JSON.
    parser.fromJson(input, fileName);

    if (parser.errors.length > 0)
    {
      trace('[FNFLegacyImporter] Error parsing JSON data from ' + fileName + ':');
      for (error in parser.errors)
        DataError.printError(error);
      return null;
    }
    return parser.value;
  }

  /**
   * @param data The raw parsed JSON data to migrate, as a Dynamic.
   * @param difficulty
   * @return SongMetadata
   */
  public static function migrateMetadata(songData:FNFLegacyData, difficulty:String = 'normal'):SongMetadata
  {
    trace('Migrating song metadata from FNF Legacy.');

    var songMetadata:SongMetadata = new SongMetadata('Import', Constants.DEFAULT_ARTIST, 'default');

    // Set generatedBy string for debugging.
    songMetadata.generatedBy = 'Chart Editor Import (FNF Legacy)';

    songMetadata.playData.stage = songData.song?.stageDefault ?? 'mainStage';
    songMetadata.songName = songData.song?.song ?? 'Import';
    songMetadata.playData.difficulties = [];

    if (songData.song?.notes != null)
    {
      switch (songData.song.notes)
      {
        case Left(notes):
          // One difficulty of notes.
          songMetadata.playData.difficulties.push(difficulty);
        case Right(difficulties):
          if (difficulties.easy != null) songMetadata.playData.difficulties.push('easy');
          if (difficulties.normal != null) songMetadata.playData.difficulties.push('normal');
          if (difficulties.hard != null) songMetadata.playData.difficulties.push('hard');
      }
    }

    songMetadata.playData.songVariations = [];

    songMetadata.timeChanges = rebuildTimeChanges(songData);

    songMetadata.playData.characters = new SongCharacterData(songData.song?.player1 ?? 'bf', 'gf', songData.song?.player2 ?? 'dad');

    return songMetadata;
  }

  public static function migrateChartData(songData:FNFLegacyData, difficulty:String = 'normal'):SongChartData
  {
    trace('Migrating song chart data from FNF Legacy.');

    var songChartData:SongChartData = new SongChartData([difficulty => 1.0], [], [difficulty => []]);

    if (songData.song?.notes != null)
    {
      switch (songData.song.notes)
      {
        case Left(notes):
          // One difficulty of notes.
          songChartData.notes.set(difficulty, migrateNoteSections(notes));
        case Right(difficulties):
          if (difficulties.easy != null) songChartData.notes.set('easy', migrateNoteSections(difficulties.easy));
          if (difficulties.normal != null) songChartData.notes.set('normal', migrateNoteSections(difficulties.normal));
          if (difficulties.hard != null) songChartData.notes.set('hard', migrateNoteSections(difficulties.hard));
      }
    }

    // Import event data.
    songChartData.events = rebuildEventData(songData);

    switch (songData.song.speed)
    {
      case Left(speed):
        // All difficulties will use the one scroll speed.
        songChartData.scrollSpeed.set('default', speed);
      case Right(speeds):
        if (speeds.easy != null) songChartData.scrollSpeed.set('easy', speeds.easy);
        if (speeds.normal != null) songChartData.scrollSpeed.set('normal', speeds.normal);
        if (speeds.hard != null) songChartData.scrollSpeed.set('hard', speeds.hard);
    }

    return songChartData;
  }

  /**
   * FNF Legacy doesn't have song events, but without them the song won't look right,
   * so we insert camera events when the character changes.
   */
  static function rebuildEventData(songData:FNFLegacyData):Array<SongEventData>
  {
    var result:Array<SongEventData> = [];

    var noteSections = [];
    switch (songData.song.notes)
    {
      case Left(notes):
        // All difficulties will use the one scroll speed.
        noteSections = notes;
      case Right(difficulties):
        if (difficulties.normal != null) noteSections = difficulties.normal;
        if (difficulties.hard != null) noteSections = difficulties.hard;
        if (difficulties.easy != null) noteSections = difficulties.easy;
    }

    if (noteSections == null || noteSections.length == 0) return result;

    // The current step and time position of the section.
    var totalSteps:Int = 0;
    var totalTimePosition:Float = 0.0;
    // The last BPM that was set.
    var lastBPM:Float = songData?.song?.bpm ?? Constants.DEFAULT_BPM;

    var lastSectionWasMustHit:Null<Bool> = null;
    // Loop through the note sections and add a camera event when the mustHitSection changes.
    for (noteSection in noteSections)
    {
      // Keep track of bpm changes for more accurate event timing.
      if ((noteSection.changeBPM) && (noteSection.bpm != lastBPM))
      {
        lastBPM = noteSection.bpm;
      }

      if (lastSectionWasMustHit != noteSection.mustHitSection)
      {
        lastSectionWasMustHit = noteSection.mustHitSection;
        result.push(new SongEventData(totalTimePosition, 'FocusCamera', {char: noteSection.mustHitSection ? 0 : 1}));
      }
      // Get the exact time position of the event simulating the way legacy conductor does it.
      var deltaSteps:Int = noteSection.lengthInSteps ?? 16;
      totalSteps += deltaSteps;
      totalTimePosition += ((60 / lastBPM) * 1000 / 4 * deltaSteps);
    }

    return result;
  }

  /**
   * Port over time changes from FNF Legacy.
   * If a section contains a BPM change, it will be applied at the estimated timestamp of the start of that section.
   */
  static function rebuildTimeChanges(songData:FNFLegacyData):Array<SongTimeChange>
  {
    var result:Array<SongTimeChange> = [];
    result.push(new SongTimeChange(0, songData?.song?.bpm ?? Constants.DEFAULT_BPM));
    var noteSections = [];
    switch (songData.song.notes)
    {
      case Left(notes):
        // All difficulties will use the one scroll speed.
        noteSections = notes;
      case Right(difficulties):
        if (difficulties.normal != null) noteSections = difficulties.normal;
        if (difficulties.hard != null) noteSections = difficulties.normal;
        if (difficulties.easy != null) noteSections = difficulties.normal;
    }

    if (noteSections == null || noteSections.length == 0) return result;

    // The current step and time position of the section.
    var totalSteps:Int = 0;
    var totalTimePosition:Float = 0.0;
    // The last BPM that was set.
    var lastBPM:Float = songData?.song?.bpm ?? Constants.DEFAULT_BPM;

    for (noteSection in noteSections)
    {
      if ((noteSection.changeBPM) && (noteSection.bpm != lastBPM))
      {
        lastBPM = noteSection.bpm;
        trace('Adding time change at ' + totalTimePosition + ' with BPM ' + lastBPM + ' at step ' + totalSteps);
        result.push(new SongTimeChange(totalTimePosition, lastBPM));
      }
      // Get the exact time position of the event simulating the way legacy conductor does it.
      var deltaSteps:Int = noteSection.lengthInSteps ?? 16;
      totalSteps += deltaSteps;
      totalTimePosition += ((60 / lastBPM) * 1000 / 4 * deltaSteps);
    }

    return result;
  }

  static final STRUMLINE_SIZE = 4;

  static function migrateNoteSections(input:Array<LegacyNoteSection>):Array<SongNoteData>
  {
    var result:Array<SongNoteData> = [];

    for (section in input)
    {
      var mustHitSection = section.mustHitSection ?? false;
      for (note in section.sectionNotes)
      {
        // Handle the dumb logic for mustHitSection.
        var noteData = note.data;
        if (noteData < 0) continue; // Exclude Psych event notes.
        if (noteData > (STRUMLINE_SIZE * 2)) noteData = noteData % (2 * STRUMLINE_SIZE); // Handle other engine event notes.

        // Flip notes if mustHitSection is FALSE (not true lol).
        if (!mustHitSection)
        {
          if (noteData >= STRUMLINE_SIZE)
          {
            noteData -= STRUMLINE_SIZE;
          }
          else
          {
            noteData += STRUMLINE_SIZE;
          }
        }

        result.push(new SongNoteData(note.time, noteData, note.length, note.getKind()));
      }
    }

    return result;
  }
}

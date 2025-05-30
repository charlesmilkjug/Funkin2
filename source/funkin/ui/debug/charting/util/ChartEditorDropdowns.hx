package funkin.ui.debug.charting.util;

import funkin.data.notestyle.NoteStyleRegistry;
import funkin.play.notes.notestyle.NoteStyle;
import funkin.data.song.SongData.SongTimeChange;
import funkin.play.event.SongEvent;
import funkin.data.stage.StageRegistry;
import funkin.play.character.CharacterData;
import funkin.ui.debug.theme.EditorTheme;
import funkin.data.theme.ThemeRegistry;
import haxe.ui.components.DropDown;
import funkin.play.stage.Stage;
import funkin.ui.freeplay.Album;
import funkin.data.freeplay.album.AlbumRegistry;
import funkin.play.character.BaseCharacter.CharacterType;
import funkin.data.event.SongEventRegistry;
import funkin.play.character.CharacterData.CharacterDataParser;

/**
 * Functions for populating dropdowns based on game data.
 * These get used by both dialogs and toolboxes so they're in their own class to prevent "reaching over."
 */
@:nullSafety
@:access(funkin.ui.debug.charting.ChartEditorState)
class ChartEditorDropdowns
{
  /**
   * Populate a dropdown with a list of characters.
   */
  public static function populateDropdownWithCharacters(dropDown:DropDown, charType:CharacterType, startingCharId:String):DropDownEntry
  {
    dropDown.dataSource.clear();

    // TODO: Filter based on charType.
    var charIds:Array<String> = CharacterDataParser.listCharacterIds();

    var returnValue:DropDownEntry = switch (charType)
    {
      case BF: {id: "bf", text: "Boyfriend"};
      case DAD: {id: "dad", text: "Daddy Dearest"};
      default: {
          dropDown.dataSource.add({id: "none", text: ""});
          {id: "none", text: "None"};
        }
    }

    for (charId in charIds)
    {
      var character:Null<CharacterData> = CharacterDataParser.fetchCharacterData(charId);
      if (character == null) continue;

      var value = {id: charId, text: character.name};
      if (startingCharId == charId) returnValue = value;

      dropDown.dataSource.add(value);
    }

    dropDown.dataSource.sort('text', ASCENDING);

    return returnValue;
  }

  /**
   * Populate a dropdown with a list of stages.
   */
  public static function populateDropdownWithStages(dropDown:DropDown, startingStageId:String):DropDownEntry
  {
    dropDown.dataSource.clear();

    var stageIds:Array<String> = StageRegistry.instance.listEntryIds();

    var returnValue:DropDownEntry = {id: "mainStage", text: "Main Stage"};

    for (stageId in stageIds)
    {
      var stage:Null<Stage> = StageRegistry.instance.fetchEntry(stageId);
      if (stage == null) continue;

      var value = {id: stage.id, text: stage.stageName};
      if (startingStageId == stageId) returnValue = value;

      dropDown.dataSource.add(value);
    }

    dropDown.dataSource.sort('text', ASCENDING);

    return returnValue;
  }

  /**
   * Populate a dropdown with a list of time changes.
   */
  public static function populateDropdownWithTimeChanges(dropDown:DropDown, timeChanges:Array<SongTimeChange>, startingTimeChange:Int = 0):DropDownEntry
  {
    dropDown.dataSource.clear();

    var returnValue:DropDownEntry =
      {
        id: "0",
        text: '${timeChanges[0].timeStamp} : BPM: ${timeChanges[0].bpm} in ${timeChanges[0].timeSignatureNum}/${timeChanges[0].timeSignatureDen}'
      };

    for (index in 0...timeChanges.length)
    {
      var value =
        {
          id: '$index',
          text: '${timeChanges[index].timeStamp} : BPM: ${timeChanges[index].bpm} in ${timeChanges[index].timeSignatureNum}/${timeChanges[index].timeSignatureDen}'
        };
      if (startingTimeChange == index) returnValue = value;

      dropDown.dataSource.add(value);
    }

    dropDown.dataSource.sort('id', ASCENDING);

    return returnValue;
  }

  /**
   * Populate a dropdown with a list of song events.
   */
  public static function populateDropdownWithSongEvents(dropDown:DropDown, startingEventId:String):DropDownEntry
  {
    dropDown.dataSource.clear();

    var returnValue:DropDownEntry = {id: "FocusCamera", text: "Focus Camera"};

    var songEvents:Array<SongEvent> = SongEventRegistry.listEvents();

    for (event in songEvents)
    {
      var value = {id: event.id, text: event.getTitle()};
      if (startingEventId == event.id) returnValue = value;
      dropDown.dataSource.add(value);
    }

    dropDown.dataSource.sort('text', ASCENDING);

    return returnValue;
  }

  /**
   * Given the ID of a dropdown element, find the corresponding entry in the dropdown's dataSource.
   */
  public static function findDropdownElement(id:String, dropDown:DropDown):Null<DropDownEntry>
  {
    // Attempt to find the entry.
    for (entryIndex in 0...dropDown.dataSource.size)
    {
      var entry = dropDown.dataSource.get(entryIndex);
      if (entry.id == id) return entry;
    }

    // Not found.
    return null;
  }

  /**
   * Populate a dropdown with a list of note styles.
   */
  public static function populateDropdownWithNoteStyles(dropDown:DropDown, startingStyleId:String):DropDownEntry
  {
    dropDown.dataSource.clear();

    var noteStyleIds:Array<String> = NoteStyleRegistry.instance.listEntryIds();

    var returnValue:DropDownEntry = {id: "funkin", text: "Funkin'"};

    for (noteStyleId in noteStyleIds)
    {
      var noteStyle:Null<NoteStyle> = NoteStyleRegistry.instance.fetchEntry(noteStyleId);
      if (noteStyle == null) continue;

      // check if the note style has all necessary assets (strums, notes, holdNotes)
      if (noteStyle._data?.assets?.noteStrumline == null
        || noteStyle._data?.assets?.note == null
        || noteStyle._data?.assets?.holdNote == null) continue;

      var value = {id: noteStyleId, text: noteStyle.getName()};
      if (startingStyleId == noteStyleId) returnValue = value;

      dropDown.dataSource.add(value);
    }

    dropDown.dataSource.sort('text', ASCENDING);

    return returnValue;
  }

  public static function populateDropdownWithDifficulties(dropDown:DropDown, startingDifficultyId:String):DropDownEntry
  {
    dropDown.dataSource.clear();

    var returnValue:DropDownEntry = {id: Constants.DEFAULT_DIFFICULTY, text: Constants.DEFAULT_DIFFICULTY.toTitleCase()};

    for (difficultyId in Constants.DEFAULT_DIFFICULTY_LIST_FULL)
    {
      var value = {id: difficultyId, text: difficultyId.toTitleCase()};
      if (startingDifficultyId == difficultyId) returnValue = value;

      dropDown.dataSource.add(value);
    }

    return returnValue;
  }

  public static function populateDropdownWithThemes(dropDown:DropDown, startingTheme:String):DropDownEntry
  {
    dropDown.dataSource.clear();

    var themeIds:Array<String> = ThemeRegistry.instance.listEntryIds();

    var returnValue:DropDownEntry = {id: "light", text: "Light"};

    for (themeId in themeIds)
    {
      var theme:Null<EditorTheme> = ThemeRegistry.instance.fetchEntry(themeId);
      if (theme == null) continue;

      var value = {id: themeId, text: theme.getThemeName()};
      if (startingTheme == themeId) returnValue = value;

      dropDown.dataSource.add(value);
    }

    dropDown.dataSource.sort('text', ASCENDING);
    return returnValue;
  }

  public static final NOTE_KINDS:Map<String, String> = [
    // Base
    "" => "Default",
    "~CUSTOM~" => "Custom",
    // Weeks 1-7
    "censor" => "[UH-OH!] (bf-christmas / pico-playable)",
    "mom" => "Mom Sings (Week 5)",
    "ugh" => "Tankman Ugh (Week 7)",
    "hehPrettyGood" => "Tankman Heh, Pretty Good (Week 7)",
    // Weekend 1
    "weekend-1-lightcan" => "Darnell Light Can (2hot)",
    "weekend-1-kneecan" => "Darnell Knee Can (2hot)",
    "weekend-1-kickcan" => "Darnell Kick Can (2hot)",
    "weekend-1-cockgun" => "Pico Cock (2hot)",
    "weekend-1-firegun" => "Pico Fire Gun (2hot)",
    "weekend-1-punchhigh" => "Punch High (Blazin')",
    "weekend-1-punchhighdodged" => "Punch High (Dodge) (Blazin')",
    "weekend-1-punchhighblocked" => "Punch High (Block) (Blazin')",
    "weekend-1-punchhighspin" => "Punch High (Spin) (Blazin')",
    "weekend-1-punchlow" => "Punch Low (Blazin')",
    "weekend-1-punchlowdodged" => "Punch Low (Dodge) (Blazin')",
    "weekend-1-punchlowblocked" => "Punch Low (Block) (Blazin')",
    "weekend-1-punchlowspin" => "Punch High (Spin) (Blazin')",
    "weekend-1-picouppercutprep" => "Pico Uppercut (Prep) (Blazin')",
    "weekend-1-picouppercut" => "Pico Uppercut (Blazin')",
    "weekend-1-blockhigh" => "Block High (Blazin')",
    "weekend-1-blocklow" => "Block Low (Blazin')",
    "weekend-1-blockspin" => "Block High (Spin) (Blazin')",
    "weekend-1-dodgehigh" => "Dodge High (Blazin')",
    "weekend-1-dodgelow" => "Dodge Low (Blazin')",
    "weekend-1-dodgespin" => "Dodge High (Spin) (Blazin')",
    "weekend-1-hithigh" => "Hit High (Blazin')",
    "weekend-1-hitlow" => "Hit Low (Blazin')",
    "weekend-1-hitspin" => "Hit High (Spin) (Blazin')",
    "weekend-1-darnelluppercutprep" => "Darnell Uppercut (Prep) (Blazin')",
    "weekend-1-darnelluppercut" => "Darnell Uppercut (Blazin')",
    "weekend-1-idle" => "Idle (Blazin')",
    "weekend-1-fakeout" => "Fakeout (Blazin')",
    "weekend-1-taunt" => "Taunt (If Fakeout) (Blazin')",
    "weekend-1-tauntforce" => "Taunt (Forced) (Blazin')",
    "weekend-1-reversefakeout" => "Fakeout (Reverse) (Blazin')",
  ];

  public static function populateDropdownWithNoteKinds(dropDown:DropDown, startingKindId:String):DropDownEntry
  {
    dropDown.dataSource.clear();

    var returnValue:DropDownEntry = lookupNoteKind('');

    for (noteKindId in NOTE_KINDS.keys())
    {
      var noteKind:String = NOTE_KINDS.get(noteKindId) ?? 'Unknown';

      var value:DropDownEntry = {id: noteKindId, text: noteKind};
      if (startingKindId == noteKindId) returnValue = value;

      dropDown.dataSource.add(value);
    }

    dropDown.dataSource.sort('id', ASCENDING);

    return returnValue;
  }

  public static function lookupNoteKind(noteKindId:Null<String>):DropDownEntry
  {
    if (noteKindId == null) return lookupNoteKind('');
    if (!NOTE_KINDS.exists(noteKindId)) return {id: '~CUSTOM~', text: 'Custom'};
    return {id: noteKindId ?? '', text: NOTE_KINDS.get(noteKindId) ?? 'Unknown'};
  }

  public static function populateDropdownWithVariations(dropDown:DropDown, state:ChartEditorState, startingVariation:String, inPreference:Bool = false,
      includeNone:Bool = true):DropDownEntry
  {
    dropDown.dataSource.clear();

    var variationIds:Array<String>;
    if (inPreference) variationIds = Constants.DEFAULT_VARIATION_LIST;
    else
      variationIds = state.availableVariations;

    if (includeNone) dropDown.dataSource.add({id: "none", text: ""});

    var returnValue:DropDownEntry = includeNone ? ({id: "none", text: ""}) : ({id: "default", text: "Default"});

    for (variationId in variationIds)
    {
      var value = {id: variationId, text: variationId.toTitleCase()};
      if (startingVariation == variationId) returnValue = value;

      dropDown.dataSource.add(value);
    }

    dropDown.dataSource.sort('text', ASCENDING);

    return returnValue;
  }

  /**
   * Populate a dropdown with a list of albums.
   */
  public static function populateDropdownWithAlbums(dropDown:DropDown, startingAlbumId:Null<String>):DropDownEntry
  {
    dropDown.dataSource.clear();

    var albumIds:Array<String> = AlbumRegistry.instance.listEntryIds();

    var returnValue:DropDownEntry = {id: "", text: "placeholder"};

    for (albumId in albumIds)
    {
      var album:Null<Album> = AlbumRegistry.instance.fetchEntry(albumId);
      if (album == null) continue;

      var value = {id: album.id, text: album.getAlbumName()};
      if (startingAlbumId == albumId) returnValue = value;

      dropDown.dataSource.add(value);
    }

    dropDown.dataSource.sort('text', ASCENDING);

    return returnValue;
  }
}

/**
 * An entry in a dropdown.
 */
typedef DropDownEntry =
{
  id:String,
  text:String
}

package funkin.ui.debug.charting.commands;

import funkin.data.song.SongData.SongEventData;
import funkin.data.song.SongData.SongNoteData;
import funkin.data.song.SongDataUtils;
import funkin.data.song.SongDataUtils.SongClipboardItems;

/**
 * A command which inserts the contents of the clipboard into the chart editor.
 */
@:nullSafety
@:access(funkin.ui.debug.charting.ChartEditorState)
class PasteItemsCommand implements ChartEditorCommand
{
  var targetTimestamp:Float;
  // Notes we added with this command, for undo.
  var addedNotes:Array<SongNoteData> = [];
  var addedEvents:Array<SongEventData> = [];

  var currentClipboard:SongClipboardItems =
    {
      valid: false,
      notes: [],
      events: []
    };

  public function new(targetTimestamp:Float)
  {
    this.targetTimestamp = targetTimestamp;
    // Doing this here so that clearing or changing the clipboard doesn't break the redo and string.
    this.currentClipboard = SongDataUtils.readItemsFromClipboard();
  }

  public function execute(state:ChartEditorState):Void
  {
    if (currentClipboard.valid != true)
    {
      state.error('Failed to Paste', 'Could not parse clipboard contents.');
      state.clipboardDirty = true;
      state.clipboardValid = false;
      return;
    }

    var stepEndOfSong:Float = Conductor.instance.getTimeInSteps(state.songLengthInMs);
    var stepCutoff:Float = stepEndOfSong - 1.0;
    var msCutoff:Float = Conductor.instance.getStepTimeInMs(stepCutoff);

    addedNotes = SongDataUtils.offsetSongNoteData(currentClipboard.notes, Std.int(targetTimestamp));
    addedNotes = SongDataUtils.clampSongNoteData(addedNotes, 0.0, msCutoff);
    addedEvents = SongDataUtils.offsetSongEventData(currentClipboard.events, Std.int(targetTimestamp));
    addedEvents = SongDataUtils.clampSongEventData(addedEvents, 0.0, msCutoff);

    state.currentSongChartNoteData = state.currentSongChartNoteData.concat(addedNotes);
    state.currentSongChartEventData = state.currentSongChartEventData.concat(addedEvents);
    state.currentNoteSelection = addedNotes.copy();
    state.currentEventSelection = addedEvents.copy();

    state.saveDataDirty = state.noteDisplayDirty = state.notePreviewDirty = state.editButtonsDirty = true;

    state.sortChartData();

    state.success('Paste Successful', 'Successfully pasted clipboard contents.');
  }

  public function undo(state:ChartEditorState):Void
  {
    state.playSound(Paths.sound('chartingSounds/undo'));

    state.currentSongChartNoteData = SongDataUtils.subtractNotes(state.currentSongChartNoteData, addedNotes);
    state.currentSongChartEventData = SongDataUtils.subtractEvents(state.currentSongChartEventData, addedEvents);
    state.currentNoteSelection = [];
    state.currentEventSelection = [];

    state.saveDataDirty = state.noteDisplayDirty = state.notePreviewDirty = state.editButtonsDirty = true;

    state.sortChartData();
  }

  public function shouldAddToHistory(state:ChartEditorState):Bool
  {
    // This command is undoable. Add to the history if we actually performed an action.
    return (addedNotes.length > 0 || addedEvents.length > 0);
  }

  public function toString():String
  {
    var len:Int = currentClipboard.notes.length + currentClipboard.events.length;

    if (currentClipboard.notes.length == 0) return 'Paste $len Events';
    else if (currentClipboard.events.length == 0) return 'Paste $len Notes';
    else
      return 'Paste $len Items';
  }
}

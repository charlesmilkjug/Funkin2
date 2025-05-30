package funkin.ui.debug.results;

import funkin.play.ResultState.ResultsStateParams;
import funkin.ui.MenuList.MenuTypedList;
import funkin.ui.MenuList.MenuTypedItem;
import flixel.text.FlxText;
import funkin.data.freeplay.player.PlayerRegistry;
import funkin.ui.options.items.CheckboxPreferenceItem;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

/**
 * Debug substate to configure the results screen for testing purposes,
 * allowing you to set the score, rank, character, and other parameters.
 */
class ResultsDebugSubState extends MusicBeatSubState
{
  public static var instance:ResultsDebugSubState = null;

  var resultsParams:ResultsStateParams;
  var items:MenuTypedList<MenuTypedItem<FlxText>>;

  override function create():Void
  {
    super.create();

    instance = this;

    persistentUpdate = persistentDraw = false;
    initResultsParams();

    items = new MenuTypedList<MenuTypedItem<FlxText>>();
    add(items);

    createItems();
  }

  var returnToDebugScreen:Bool = false;

  function createItems():Void
  {
    createTextItem("TEST RESULTS SCREEN", () -> {
      // I'm being lazy, and putting a timer here so that when you enter result screen you don't immediately press an input
      new FlxTimer().start(0.5, (_) -> {
        if (returnToDebugScreen)
        {
          var resultState:funkin.play.ResultState = new funkin.play.ResultState(resultsParams);
          resultState.closeCallback = () -> {
            FlxTimer.globalManager.clear();
            FlxTween.globalManager.clear();
            FlxG.sound.music?.stop();
            FlxG.cameras.reset();
          };
          openSubState(resultState);
        }
        else
          FlxG.switchState(() -> new funkin.play.ResultState(resultsParams));
      });
    });
    // Get base game players.
    var players = PlayerRegistry.instance.listBaseGameEntryIds();
    players = players.concat(PlayerRegistry.instance.listModdedEntryIds());
    createToggleListItem("Character", players, (result:String) -> resultsParams.characterId = result);
    createToggleListItem("Results Mode", ["Debug", "Story", "Freeplay"], (result:String) -> {
      returnToDebugScreen = result == "Debug"; // We will create the ResultsState as a Substate, that we will just close and return back to here
      resultsParams.storyMode = result == "Story"; // Debug overrides this, but if not using Debug, we will return to either Freeplay or Story menus
    });
    createToggleListItem("Ranking", DebugTallies.DEBUG_RANKS, (result:String) -> resultsParams.scoreData.tallies = DebugTallies.getTallyForRank(result));
  }

  function createTextItem(name:String, ?onChange:Void->Void):MenuTypedItem<FlxText>
  {
    var txt:FlxText = new FlxText(0, 0, name);
    txt.antialiasing = false;
    txt.setFormat(Paths.font('vcr.ttf'), 32);

    var menuItem:MenuTypedItem<FlxText> = new MenuTypedItem<FlxText>(10, 36 * items.length, txt, name, onChange);
    menuItem.setEmptyBackground();
    menuItem.fireInstantly = true;
    return items.addItem(name, menuItem);
  }

  function createCheckboxItem(name:String, ?onChange:Bool->Void):Void
  {
    var toggle:Bool = false;
    var menuItem:MenuTypedItem<FlxText> = createTextItem(name);
    menuItem.callback = () -> {
      menuItem.label.text = name + ": " + (toggle ? "on" : "off");
      toggle = !toggle;
      onChange(toggle);
    };
  }

  /**
   * Toggles between different options in a list
   * @param name
   * @param toggleList
   * @param onChange
   * @return MenuTypedItem<FlxText>
   */
  function createToggleListItem(name:String, toggleList:Array<String>, ?onChange:String->Void):MenuTypedItem<FlxText>
  {
    var toggleCounter:Int = 0;
    var menuItem:MenuTypedItem<FlxText> = createTextItem(name);

    // We create and call the labelCallback here to initalize it
    var labelCallback:Void->Void = () -> {
      menuItem.label.text = name + ":" + toggleList[toggleCounter];
      onChange(toggleList[toggleCounter]);
    };
    labelCallback();

    menuItem.callback = () -> {
      toggleCounter = (toggleCounter + 1) % toggleList.length;
      labelCallback();
    };

    return menuItem;
  }

  function initResultsParams():Void
  {
    resultsParams =
      {
        storyMode: false,
        title: "Cum Song Erect by Kawai Sprite",
        songId: "cum",
        characterId: "bf",
        difficultyId: "nightmare",
        variationId: "erect",
        isNewHighscore: true,
        isPracticeMode: true, // Invalidates achievements/scores.
        isBotPlayMode: true, // Also invalidates achievements/scores.
        scoreData:
          {
            score: 1_234_567,
            tallies:
              {
                sick: 130,
                good: 60,
                bad: 69,
                shit: 69,
                missed: 69,
                combo: 69,
                maxCombo: 69,
                totalNotesHit: 140,
                totalNotes: 190
              }
          },
      };
  }

  public override function destroy():Void
  {
    super.destroy();
    instance = null;
  }
}

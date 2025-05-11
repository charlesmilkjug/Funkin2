package funkin.ui.options;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.ui.AtlasText.AtlasFont;
import funkin.ui.Page;
import funkin.graphics.FunkinCamera;
import funkin.graphics.FunkinSprite;
import funkin.ui.TextMenuList.TextMenuItem;
import funkin.ui.options.items.CheckboxPreferenceItem;
import funkin.ui.options.items.NumberPreferenceItem;
import funkin.ui.options.items.EnumPreferenceItem;
import lime.ui.WindowVSyncMode;

class PreferencesMenu extends Page<OptionsState.OptionsMenuPageName>
{
  var items:TextMenuList;
  var preferenceItems:FlxTypedSpriteGroup<FlxSprite>;
  var headers:FlxTypedSpriteGroup<AtlasText>;
  var preferenceDesc:Array<String> = [];
  var itemDesc:FlxText;
  var itemDescBox:FunkinSprite;

  var menuCamera:FlxCamera;
  var hudCamera:FlxCamera;
  var camFollow:FlxObject;

  public function new()
  {
    super();

    menuCamera = new FunkinCamera('prefMenu');
    FlxG.cameras.add(menuCamera, false);
    menuCamera.bgColor = 0x0;

    hudCamera = new FlxCamera();
    FlxG.cameras.add(hudCamera, false);
    hudCamera.bgColor = 0x0;

    camera = menuCamera;

    add(items = new TextMenuList());
    add(preferenceItems = new FlxTypedSpriteGroup<FlxSprite>());
    add(headers = new FlxTypedSpriteGroup<AtlasText>());

    add(itemDescBox = new FunkinSprite());
    itemDescBox.cameras = [hudCamera];

    add(itemDesc = new FlxText(0, 0, 1180, null, 32));
    itemDesc.cameras = [hudCamera];

    createPrefItems();
    createPrefDescription();

    camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
    if (items != null) camFollow.y = items.selectedItem.y;

    menuCamera.follow(camFollow, null, 0.085);
    var margin = 160;
    menuCamera.deadzone.set(0, margin, menuCamera.width, menuCamera.height - margin * 2);
    menuCamera.minScrollY = 0;

    items.onChange.add((selected) -> {
      camFollow.y = selected.y;
      itemDesc.text = preferenceDesc[items.selectedIndex];
    });
  }

  /**
   * Create the description for preferences.
   */
  function createPrefDescription():Void
  {
    itemDescBox.makeSolidColor(1, 1, FlxColor.BLACK);
    itemDescBox.alpha = 0.6;
    itemDesc.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    itemDesc.borderSize = 3;

    // Update the text.
    itemDesc.text = preferenceDesc[items.selectedIndex];
    itemDesc.screenCenter();
    itemDesc.y += 270;

    // Create the box around the text.
    itemDescBox.setPosition(itemDesc.x - 10, itemDesc.y - 10);
    itemDescBox.setGraphicSize(Std.int(itemDesc.width + 20), Std.int(itemDesc.height + 25));
    itemDescBox.updateHitbox();
  }

  function addCategory(name:String):Void
  {
    var labelY:Float = (120 * (preferenceItems.length + headers.length)) + 30;
    headers.add(new AtlasText(0, labelY, name, AtlasFont.BOLD)).screenCenter(X);
  }

  /**
   * Create the menu items for each of the preferences.
   */
  function createPrefItems():Void
  {
    addCategory('Gameplay');
    createPrefItemCheckbox('Naughtyness', 'If enabled, raunchy content (such as swearing, etc.) will be displayed.', function(value:Bool):Void {
      Preferences.naughtyness = value;
    }, Preferences.naughtyness);
    createPrefItemCheckbox('Downscroll', 'If enabled, this will make the notes move downwards.', function(value:Bool):Void {
      Preferences.downscroll = value;
    }, Preferences.downscroll);
    createPrefItemPercentage('Strumline Background', 'The strumline background\'s transparency level. Also known as "Lane Underlay"',
      function(value:Int):Void {
        Preferences.strumlineBackgroundOpacity = value;
      }, Preferences.strumlineBackgroundOpacity);
    createPrefItemCheckbox('Flashing Lights', 'If disabled, it will dampen flashing effects. Useful for people with photosensitive epilepsy.',
      function(value:Bool):Void {
        Preferences.flashingLights = value;
      }, Preferences.flashingLights);
    createPrefItemCheckbox('Camera Zooming', 'If disabled, the camera stops bouncing to the song (every measure).', function(value:Bool):Void {
      Preferences.zoomCamera = value;
    }, Preferences.zoomCamera);

    addCategory('Additional');
    createPrefItemCheckbox('Debug Display', 'If enabled, the FPS and other debug stats will be displayed.', function(value:Bool):Void {
      Preferences.debugDisplay = value;
    }, Preferences.debugDisplay);
    createPrefItemCheckbox('Pause on Unfocus', 'If enabled, the game automatically pauses when it loses focus.', function(value:Bool):Void {
      Preferences.autoPause = value;
    }, Preferences.autoPause);
    createPrefItemCheckbox('Launch in Fullscreen', 'If enabled, the game will automatically open in fullscreen on startup.', function(value:Bool):Void {
      Preferences.autoFullscreen = value;
    }, Preferences.autoFullscreen);
    #if web
    createPrefItemCheckbox('Unlocked Framerate', 'If enabled, the framerate will be unlocked.', function(value:Bool):Void {
      Preferences.unlockedFramerate = value;
    }, Preferences.unlockedFramerate);
    #else
    // disabled on macos due to "error: Late swap tearing currently unsupported"
    #if !mac
    createPrefItemEnum('VSync', 'If enabled, the game will attempt to match the framerate with your monitor.', [
      "Off" => WindowVSyncMode.OFF,
      "On" => WindowVSyncMode.ON,
      "Adaptive" => WindowVSyncMode.ADAPTIVE,
    ], function(key:String, value:WindowVSyncMode):Void {
      trace("Setting vsync mode to " + key);
      Preferences.vsyncMode = value;
    }, switch (Preferences.vsyncMode)
      {
        case WindowVSyncMode.OFF: "Off";
        case WindowVSyncMode.ON: "On";
        case WindowVSyncMode.ADAPTIVE: "Adaptive";
      });
    #end
    createPrefItemNumber('FPS', 'The maximum framerate that the game targets.', (value:Float) -> {
      Preferences.framerate = Std.int(value);
    }, null, Preferences.framerate, 30, 360, 5, 0, 1);
    #end

    addCategory('Screenshots');
    createPrefItemCheckbox('Hide Mouse', 'If enabled, the mouse will be hidden when taking a screenshot.', function(value:Bool):Void {
      Preferences.shouldHideMouse = value;
    }, Preferences.shouldHideMouse);
    createPrefItemCheckbox('Fancy Preview', 'If enabled, a preview will be shown after taking a screenshot.', function(value:Bool):Void {
      Preferences.fancyPreview = value;
    }, Preferences.fancyPreview);
    createPrefItemCheckbox('Preview on Save', 'If enabled, the preview will be shown only after a screenshot is saved.', function(value:Bool):Void {
      Preferences.previewOnSave = value;
    }, Preferences.previewOnSave);
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    // Indent the selected item.
    items.forEach((daItem:TextMenuItem) -> {
      var thyOffset:Int = 0;
      // Initializing thy text width. (if thou text present)
      var thyTextWidth:Int = 0;
      switch (Type.typeof(daItem))
      {
        case TClass(CheckboxPreferenceItem):
          thyTextWidth = 0;
          thyOffset = 0;
        case TClass(EnumPreferenceItem):
          thyTextWidth = cast(daItem, EnumPreferenceItem<Dynamic>).lefthandText.getWidth();
          thyOffset = 0 + thyTextWidth - 75;
        case TClass(NumberPreferenceItem):
          thyTextWidth = cast(daItem, NumberPreferenceItem).lefthandText.getWidth();
          thyOffset = 0 + thyTextWidth - 75;
        default:
          // Huh?
      }

      if (items.selectedItem == daItem) thyOffset += 150;
      else
        thyOffset += 120;

      daItem.x = thyOffset;
    });
  }

  // - Preference item creation methods -
  // Should be moved into a separate PreferenceItems class but you can't access PreferencesMenu.items and PreferencesMenu.preferenceItems from outside.

  /**
   * Creates a preference item that works with booleans.
   * @param onChange Gets called every time the player changes the value; use this to apply the value.
   * @param defaultValue The value that is loaded in when the preference item is created. (usually your `Preferences.settingVariable`)
   */
  function createPrefItemCheckbox(prefName:String, prefDesc:String, onChange:Bool->Void, defaultValue:Bool):Void
  {
    var checkbox:CheckboxPreferenceItem = new CheckboxPreferenceItem(0, 120 * (items.length + headers.length), defaultValue);

    items.createItem(0, (120 * (items.length + headers.length)) + 30, prefName, AtlasFont.BOLD, () -> {
      var value = !checkbox.currentValue;
      onChange(value);
      checkbox.currentValue = value;
    }, true);

    preferenceItems.add(checkbox);
    preferenceDesc.push(prefDesc);
  }

  /**
   * Creates a preference item that works with general numbers. (Floats, to be specific)
   * @param onChange Gets called every time the player changes the value; use this to apply the value.
   * @param valueFormatter Will get called every time the game needs to display the float value; use this to change how the displayed value looks.
   * @param defaultValue The value that is loaded in when the preference item is created. (usually your `Preferences.settingVariable`)
   * @param min Minimum value. (example: 0)
   * @param max Maximum value. (example: 10)
   * @param step The value to increment/decrement by. (default = 0.1)
   * @param precision Rounds decimals up to a `precision` amount of digits. (ex: 4 -> 0.1234, 2 -> 0.12)
   */
  function createPrefItemNumber(prefName:String, prefDesc:String, onChange:Float->Void, ?valueFormatter:Float->String, defaultValue:Int, min:Int, max:Int,
      step:Float = 0.1, precision:Int, stepPrecise:Float = 0.1):Void
  {
    var item = new NumberPreferenceItem(0, (120 * (items.length + headers.length)) + 30, prefName, defaultValue, min, max, step, precision, stepPrecise,
      onChange, valueFormatter);
    items.addItem(prefName, item);
    preferenceItems.add(item.lefthandText);
    preferenceDesc.push(prefDesc);
  }

  /**
   * Creates a preference item that works with number percentages. (Ints, to be specific)
   * @param onChange Gets called every time the player changes the value; use this to apply the value.
   * @param defaultValue The value that is loaded in when the preference item is created. (usually your `Preferences.settingVariable`)
   * @param min Minimum value. (default = 0)
   * @param max Maximum value. (default = 100)
   */
  function createPrefItemPercentage(prefName:String, prefDesc:String, onChange:Int->Void, defaultValue:Int, min:Int = 0, max:Int = 100):Void
  {
    var newCallback = (value:Float) -> onChange(Std.int(value));
    var formatter = (value:Float) -> return '${value}%';
    var item = new NumberPreferenceItem(0, (120 * (items.length + headers.length)) + 30, prefName, defaultValue, min, max, 10, 0, 1, newCallback, formatter);
    items.addItem(prefName, item);
    preferenceItems.add(item.lefthandText);
    preferenceDesc.push(prefDesc);
  }

  /**
   * Creates a preference item that works with enums. (Or choices, if you call it that in a non-technical way)
   * @param values Maps enum values to display strings. _(ex: `NoteHitSoundType.PingPong => "Ping pong"`)_
   * @param onChange Gets called every time the player changes the value; use this to apply the value.
   * @param defaultValue The value that is loaded in when the preference item is created. (usually your `Preferences.settingVariable`)
   */
  function createPrefItemEnum<T>(prefName:String, prefDesc:String, values:Map<String, T>, onChange:String->T->Void, defaultKey:String):Void
  {
    var item = new EnumPreferenceItem<T>(0, (120 * items.length) + 30, prefName, values, defaultKey, onChange);
    items.addItem(prefName, item);
    preferenceItems.add(item.lefthandText);
    preferenceDesc.push(prefDesc);
  }
}

package funkin.ui.debug.anim;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.input.Cursor;
import funkin.play.character.BaseCharacter;
import funkin.play.character.CharacterData;
import funkin.play.character.CharacterData.CharacterDataParser;
import funkin.ui.mainmenu.MainMenuState;
import funkin.util.MouseUtil;
import funkin.util.SerializerUtil;
import funkin.util.SortUtil;
import haxe.ui.components.DropDown;
import haxe.ui.containers.dialogs.CollapsibleDialog;
import haxe.ui.core.Screen;
import haxe.ui.events.UIEvent;
import haxe.ui.RuntimeComponentBuilder;
import lime.utils.Assets as LimeAssets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.geom.Rectangle;
import openfl.net.FileReference;

using flixel.util.FlxSpriteUtil;

@:nullSafety
class DebugBoundingState extends FlxState
{
  /*
    TODAY'S TO-DO
    - Cleaner UI
   */
  public static var instance:Null<DebugBoundingState> = null;

  var bg:Null<FlxBackdrop>;
  var fileInfo:Null<FlxText>;

  var txtGrp:Null<FlxTypedGroup<FlxText>>;

  var hudCam:Null<FlxCamera>;

  var curView:ANIMDEBUGVIEW = SPRITESHEET;

  var spriteSheetView:Null<FlxGroup>;
  var offsetView:Null<FlxGroup>;
  var dropDownSetup:Bool = false;

  var onionSkinChar:Null<FlxSprite>;
  var txtOffsetShit:Null<FlxText>;

  var offsetEditorDialog:Null<CollapsibleDialog>;
  var offsetAnimationDropdown:Null<DropDown>;

  var haxeUIFocused(get, default):Bool = false;

  var currentAnimationName(get, never):String;

  function get_currentAnimationName():String
    return offsetAnimationDropdown?.value?.id ?? "idle";

  function get_haxeUIFocused():Bool
  {
    // get the screen position, according to the HUD camera, temp default to FlxG.camera juuust in case?
    var hudMousePos:FlxPoint = FlxG.mouse.getViewPosition(hudCam ?? FlxG.camera);
    return Screen.instance.hasSolidComponentUnderPoint(hudMousePos.x, hudMousePos.y);
  }

  override function create()
  {
    Paths.setCurrentLevel('week1');

    instance = this;

    hudCam = new FlxCamera();
    hudCam.bgColor.alpha = 0;

    bg = new FlxBackdrop(FlxGridOverlay.createGrid(10, 10, FlxG.width, FlxG.height, true, 0xffe7e6e6, 0xffd9d5d5));
    add(bg);

    // we are setting this as the default draw camera only temporarily, to trick haxeui
    FlxG.cameras.add(hudCam);

    var str = Paths.xml('ui/animation-editor/offset-editor-view');
    offsetEditorDialog = cast RuntimeComponentBuilder.fromAsset(str);

    var viewDropdown:Null<DropDown> = offsetEditorDialog.findComponent("swapper", DropDown);

    if (viewDropdown != null) viewDropdown.onChange = (e:UIEvent) -> curView = cast e.data.curView;

    offsetAnimationDropdown = offsetEditorDialog.findComponent("animationDropdown", DropDown);

    offsetEditorDialog.cameras = [hudCam];

    add(offsetEditorDialog);
    offsetEditorDialog.showDialog(false);

    // Anchor to the left side by default
    offsetEditorDialog.x = 16;
    offsetEditorDialog.y = 16;

    // sets the default camera back to FlxG.camera, since we set it to hudCamera for haxeui stuf
    FlxG.cameras.setDefaultDrawTarget(FlxG.camera, true);
    FlxG.cameras.setDefaultDrawTarget(hudCam, false);

    initSpritesheetView();
    initOffsetView();

    Cursor.show();

    super.create();
  }

  var bf:Null<FlxSprite>;
  var swagOutlines:Null<FlxSprite>;

  function initSpritesheetView():Void
  {
    spriteSheetView = new FlxGroup();
    add(spriteSheetView);

    var tex = Paths.getSparrowAtlas('characters/BOYFRIEND');

    bf = new FlxSprite();
    bf.loadGraphic(tex.parent);
    spriteSheetView.add(bf);

    swagOutlines = new FlxSprite().makeGraphic(tex.parent.width, tex.parent.height, FlxColor.TRANSPARENT);

    generateOutlines(tex.frames);

    txtGrp = new FlxTypedGroup<FlxText>();
    if (hudCam != null) txtGrp.cameras = [hudCam];
    spriteSheetView.add(txtGrp);

    addInfo('boyfriend.xml', "");
    addInfo('Width', bf.width);
    addInfo('Height', bf.height);

    spriteSheetView.add(swagOutlines);
  }

  function generateOutlines(frameShit:Array<FlxFrame>):Void
  {
    if (swagOutlines != null) swagOutlines.pixels.fillRect(new Rectangle(0, 0, swagOutlines.width, swagOutlines.height), 0x00000000);

    for (i in frameShit)
    {
      var lineStyle:LineStyle = {color: FlxColor.RED, thickness: 2};
      var uvW:Float = (i.uv.width * i.parent.width) - (i.uv.x * i.parent.width);
      var uvH:Float = (i.uv.height * i.parent.height) - (i.uv.y * i.parent.height);

      if (swagOutlines != null) swagOutlines.drawRect(i.uv.x * i.parent.width, i.uv.y * i.parent.height, uvW, uvH, FlxColor.TRANSPARENT, lineStyle);
    }
  }

  function initOffsetView():Void
  {
    offsetView = new FlxGroup();
    add(offsetView);

    onionSkinChar = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.TRANSPARENT);
    onionSkinChar.visible = false;
    offsetView.add(onionSkinChar);

    txtOffsetShit = new FlxText(20, 20, 0, "", 20);
    txtOffsetShit.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    if (hudCam != null) txtOffsetShit.cameras = [hudCam];
    txtOffsetShit.y = FlxG.height - 20 - txtOffsetShit.height;
    offsetView.add(txtOffsetShit);

    var characters:Array<String> = CharacterDataParser.listCharacterIds();
    characters = characters.filter((charId:String) -> {
      var char = CharacterDataParser.fetchCharacterData(charId);
      @:nullSafety(Off)
      return char.renderType != AnimateAtlas;
    });
    characters.sort(SortUtil.alphabetically);

    var charDropdown:Null<DropDown> = null;
    if (offsetEditorDialog != null) charDropdown = offsetEditorDialog.findComponent('characterDropdown', DropDown);

    if (charDropdown != null)
    {
      for (char in characters)
        charDropdown.dataSource.add({text: char});

      charDropdown.onChange = (e:UIEvent) -> loadAnimShit(e.data.text);
    }
  }

  public var mouseOffset:FlxPoint = FlxPoint.get(0, 0);
  public var oldPos:FlxPoint = FlxPoint.get(0, 0);
  public var movingCharacter:Bool = false;

  function mouseOffsetMovement()
  {
    if (swagChar != null)
    {
      if (FlxG.mouse.justPressed && !haxeUIFocused)
      {
        movingCharacter = true;
        mouseOffset.set(FlxG.mouse.x - -swagChar.animOffsets[0], FlxG.mouse.y - -swagChar.animOffsets[1]);
      }

      if (!movingCharacter) return;

      if (FlxG.mouse.pressed)
      {
        swagChar.animOffsets = [(FlxG.mouse.x - mouseOffset.x) * -1, (FlxG.mouse.y - mouseOffset.y) * -1];

        if (offsetAnimationDropdown != null) swagChar.animationOffsets.set(offsetAnimationDropdown.value.id, swagChar.animOffsets);

        if (txtOffsetShit != null)
        {
          txtOffsetShit.text = 'Offset: ' + swagChar?.animOffsets;
          txtOffsetShit.y = FlxG.height - 20 - txtOffsetShit.height;
        }
      }

      if (FlxG.mouse.justReleased) movingCharacter = false;
      if (FlxG.mouse.justReleased) movingCharacter = false;
    }
  }

  function addInfo(str:String, value:Dynamic)
  {
    var swagText:FlxText = new FlxText(10, FlxG.height - 32);
    swagText.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    swagText.scrollFactor.set();

    if (txtGrp != null)
    {
      var texts = txtGrp.members;

      if (texts != null) for (text in texts)
        text.y -= swagText.height;

      txtGrp.add(swagText);
    }

    swagText.text = str + ": " + Std.string(value);
  }

  function clearInfo()
    if (txtGrp != null) txtGrp.clear();

  function checkLibrary(library:String)
  {
    trace(Assets.hasLibrary(library));
    if (Assets.getLibrary(library) == null)
    {
      @:privateAccess
      if (!LimeAssets.libraryPaths.exists(library)) throw "Missing library: " + library;

      Assets.loadLibrary(library).onComplete((_) -> trace('LOADED... awesomeness...'));
    }
  }

  override function update(elapsed:Float)
  {
    if (FlxG.keys.justPressed.ONE)
    {
      var lv:Null<DropDown> = null;
      if (offsetEditorDialog != null) lv = offsetEditorDialog.findComponent("swapper", DropDown);
      if (lv != null) lv.selectedIndex = 0;
      curView = SPRITESHEET;
    }

    if (FlxG.keys.justReleased.TWO)
    {
      var lv:Null<DropDown> = null;
      if (offsetEditorDialog != null) lv = offsetEditorDialog.findComponent("swapper", DropDown);
      if (lv != null) lv.selectedIndex = 1;
      curView = ANIMATIONS;
      if (swagChar != null)
      {
        FlxG.camera.focusOn(swagChar.getMidpoint());
        FlxG.camera.zoom = 0.95;
      }
    }

    if (spriteSheetView != null && offsetView != null && offsetAnimationDropdown != null)
    {
      switch (curView)
      {
        case SPRITESHEET:
          spriteSheetView.visible = true;
          offsetView.visible = offsetView.active = false;
          offsetAnimationDropdown.visible = false;
        case ANIMATIONS:
          spriteSheetView.visible = false;
          offsetView.visible = offsetView.active = true;
          offsetAnimationDropdown.visible = true;
          offsetControls();
          mouseOffsetMovement();
      }
    }

    if (FlxG.keys.justPressed.H && hudCam != null) hudCam.visible = !hudCam.visible;

    if (FlxG.keys.justPressed.F4) FlxG.switchState(() -> new MainMenuState());

    MouseUtil.mouseCamDrag(FlxG.camera.scroll);
    if (!haxeUIFocused) MouseUtil.mouseWheelZoom();

    if (bg != null) bg.setGraphicSize(Std.int(bg.width / FlxG.camera.zoom));

    super.update(elapsed);
  }

  function offsetControls():Void
  {
    if (FlxG.keys.justPressed.RBRACKET || FlxG.keys.justPressed.E)
    {
      if (offsetAnimationDropdown != null
        && offsetAnimationDropdown.selectedIndex + 1 <= offsetAnimationDropdown.dataSource.size) offsetAnimationDropdown.selectedIndex += 1;
      else if (offsetAnimationDropdown != null) offsetAnimationDropdown.selectedIndex = 0;

      trace(currentAnimationName);
      playCharacterAnimation(currentAnimationName, true);
    }
    if (FlxG.keys.justPressed.LBRACKET || FlxG.keys.justPressed.Q)
    {
      if (offsetAnimationDropdown != null && offsetAnimationDropdown.selectedIndex - 1 >= 0) offsetAnimationDropdown.selectedIndex -= 1;
      else if (offsetAnimationDropdown != null) offsetAnimationDropdown.selectedIndex = offsetAnimationDropdown.dataSource.size - 1;

      playCharacterAnimation(currentAnimationName, true);
    }

    // Keyboards controls for general WASD "movement"
    // modifies the animDrooffsetAnimationDropdownpDownMenu so that it's properly updated and shit
    // and then it's just played and updated from the offsetAnimationDropdown callback, which is set in the loadAnimShit() function probabbly
    if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S || FlxG.keys.justPressed.D || FlxG.keys.justPressed.A)
    {
      var suffix:String = '';
      var targetLabel:String = '';
      if (FlxG.keys.pressed.SHIFT) suffix = 'miss';
      if (FlxG.keys.justPressed.W) targetLabel = 'singUP$suffix';
      if (FlxG.keys.justPressed.S) targetLabel = 'singDOWN$suffix';
      if (FlxG.keys.justPressed.A) targetLabel = 'singLEFT$suffix';
      if (FlxG.keys.justPressed.D) targetLabel = 'singRIGHT$suffix';

      if (targetLabel != currentAnimationName)
      {
        if (offsetAnimationDropdown != null) offsetAnimationDropdown.value = {id: targetLabel, text: targetLabel};

        // Play the new animation if the IDs are the different.
        // Override the onion skin.
        playCharacterAnimation(currentAnimationName, true);
      }
      else
      {
        // Replay the current animation if the IDs are the same.
        // Don't override the onion skin.
        playCharacterAnimation(currentAnimationName, false);
      }
    }

    if (FlxG.keys.justPressed.F) if (onionSkinChar != null) onionSkinChar.visible = !onionSkinChar.visible;

    if (FlxG.keys.justPressed.G) if (swagChar != null) swagChar.flipX = !swagChar.flipX;

    // Plays the idle animation.
    if (FlxG.keys.justPressed.SPACE)
    {
      if (offsetAnimationDropdown != null) offsetAnimationDropdown.value = {id: 'idle', text: 'idle'};

      playCharacterAnimation(currentAnimationName, true);
    }

    // Playback the animation.
    if (FlxG.keys.justPressed.ENTER) playCharacterAnimation(currentAnimationName, false);

    if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
    {
      if (swagChar != null)
      {
        var animName = currentAnimationName;
        @:nullSafety(Off)
        var coolValues:Array<Float> = swagChar.animationOffsets.get(animName).copy();

        var multiplier:Int = 5;

        if (FlxG.keys.pressed.CONTROL) multiplier = 1;

        if (FlxG.keys.pressed.SHIFT) multiplier = 10;

        if (FlxG.keys.justPressed.RIGHT) coolValues[0] -= 1 * multiplier;
        else if (FlxG.keys.justPressed.LEFT) coolValues[0] += 1 * multiplier;
        else if (FlxG.keys.justPressed.UP) coolValues[1] += 1 * multiplier;
        else if (FlxG.keys.justPressed.DOWN) coolValues[1] -= 1 * multiplier;

        swagChar.animationOffsets.set(currentAnimationName, coolValues);
        swagChar.playAnimation(animName);

        if (txtOffsetShit != null)
        {
          txtOffsetShit.text = 'Offset: ' + coolValues;
          txtOffsetShit.y = FlxG.height - 20 - txtOffsetShit.height;
        }

        trace(animName);
      }
    }

    if (FlxG.keys.justPressed.ESCAPE)
    {
      var outputString = FlxG.keys.pressed.CONTROL ? buildOutputStringOld() : buildOutputStringNew();
      if (swagChar != null) saveOffsets(outputString, FlxG.keys.pressed.CONTROL ? swagChar.characterId + "Offsets.txt" : swagChar.characterId + ".json");
    }
  }

  function buildOutputStringOld():String
  {
    var outputString:String = "";

    if (swagChar != null)
    {
      var keys = swagChar.animationOffsets.keys();
      if (keys != null) for (i in keys)
      {
        @:nullSafety(Off) // This bug is fixed in haxe 5.0 or something
        outputString += '${i}  ${swagChar.animationOffsets.get(i)[0]}  ${swagChar.animationOffsets.get(i)[1]}\n';
      }
    }

    outputString.trim();

    return outputString;
  }

  function buildOutputStringNew():String
  {
    var charData:Null<CharacterData> = Reflect.copy(swagChar?._data);

    var animations = charData?.animations;
    if (animations != null)
    {
      for (charDataAnim in animations)
      {
        var animName:String = charDataAnim.name;
        charDataAnim.offsets = swagChar?.animationOffsets.get(animName);
      }
    }
    return SerializerUtil.toJSON(charData, true);
  }

  var swagChar:Null<BaseCharacter>;

  /*
    Called when animation dropdown is changed!
   */
  function loadAnimShit(char:String)
  {
    if (swagChar != null)
    {
      if (offsetView != null) offsetView.remove(swagChar);
      swagChar.destroy();
    }

    swagChar = CharacterDataParser.fetchCharacter(char);

    if (swagChar == null || swagChar.frames == null) trace('ERROR: Failed to load character ${char}!');
    else if (swagChar != null)
    {
      swagChar.x = 100;
      swagChar.y = 100;
      swagChar.debug = true;
      if (offsetView != null) offsetView.add(swagChar);

      generateOutlines(swagChar.frames.frames);
      if (bf != null) bf.pixels = swagChar.pixels;

      clearInfo();
      addInfo(swagChar._data.assetPath, "");
      if (bf != null) addInfo('Width', bf.width);
      if (bf != null) addInfo('Height', bf.height);

      characterAnimNames = [];

      var keys = swagChar.animationOffsets?.keys();
      if (keys != null) for (i in keys)
        characterAnimNames.push(i);

      if (offsetAnimationDropdown != null)
      {
        offsetAnimationDropdown.dataSource.clear();

        for (charAnim in characterAnimNames)
        {
          trace('Adding ${charAnim} to HaxeUI dropdown');
          offsetAnimationDropdown.dataSource.add({id: charAnim, text: charAnim});
        }

        offsetAnimationDropdown.selectedIndex = 0;

        trace('Added ${offsetAnimationDropdown.dataSource.size} to HaxeUI dropdown');

        offsetAnimationDropdown.onChange = (event:UIEvent) -> {
          if (event?.data?.id == null) return;
          trace('Selected animation ${event?.data?.id}');
          playCharacterAnimation(event.data.id, true);
        }
      }

      if (txtOffsetShit != null)
      {
        txtOffsetShit.text = 'Offset: ' + swagChar?.animOffsets;
        txtOffsetShit.y = FlxG.height - 20 - txtOffsetShit.height;
      }
      dropDownSetup = true;
    }
  }

  private var characterAnimNames:Null<Array<String>>;

  function playCharacterAnimation(str:String, setOnionSkin:Bool = true)
  {
    if (setOnionSkin && onionSkinChar != null)
    {
      // clears the canvas
      onionSkinChar.pixels.fillRect(new Rectangle(0, 0, FlxG.width * 2, FlxG.height * 2), 0x00000000);

      if (swagChar != null) onionSkinChar.stamp(swagChar, Std.int(swagChar.x), Std.int(swagChar.y));
      onionSkinChar.alpha = 0.6;
    }

    var animName = str;
    if (swagChar != null) swagChar.playAnimation(animName, true);
    trace(swagChar?.animationOffsets.get(animName));

    if (txtOffsetShit != null)
    {
      txtOffsetShit.text = 'Offset: ' + swagChar?.animOffsets;
      txtOffsetShit.y = FlxG.height - 20 - txtOffsetShit.height;
    }
  }

  var _file:Null<FileReference>;

  function saveOffsets(saveString:String, fileName:String)
  {
    if ((saveString != null) && (saveString.length > 0))
    {
      _file = new FileReference();
      _file.addEventListener(Event.COMPLETE, onSaveComplete);
      _file.addEventListener(Event.CANCEL, onSaveCancel);
      _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
      _file.save(saveString, fileName);
    }
  }

  function onSaveComplete(_):Void
  {
    if (_file != null)
    {
      _file.removeEventListener(Event.COMPLETE, onSaveComplete);
      _file.removeEventListener(Event.CANCEL, onSaveCancel);
      _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
      _file = null;
      FlxG.log.notice("Successfully saved LEVEL DATA.");
    }
  }

  /**
   * Called when the save file dialog is cancelled.
   */
  function onSaveCancel(_):Void
  {
    if (_file != null)
    {
      _file.removeEventListener(Event.COMPLETE, onSaveComplete);
      _file.removeEventListener(Event.CANCEL, onSaveCancel);
      _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
      _file = null;
    }
  }

  /**
   * Called if there is an error while saving the gameplay recording.
   */
  function onSaveError(_):Void
  {
    if (_file != null)
    {
      _file.removeEventListener(Event.COMPLETE, onSaveComplete);
      _file.removeEventListener(Event.CANCEL, onSaveCancel);
      _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
      _file = null;
      FlxG.log.error("Problem saving Level data");
    }
  }

  public override function destroy():Void
  {
    super.destroy();
    instance = null;
  }
}

enum abstract ANIMDEBUGVIEW(String)
{
  var SPRITESHEET;
  var ANIMATIONS;
}

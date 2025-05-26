package funkin.ui.charSelect;

#if html5
import funkin.graphics.video.FlxVideo;
#end
#if hxvlc
import funkin.graphics.video.FunkinVideoSprite;
#end
import funkin.ui.MusicBeatSubState;
import funkin.save.Save;

/**
 * When you first enter the character select state, it will play an introductory video opening up the lights
 */
class IntroSubState extends MusicBeatSubState
{
  #if html5
  static final LIGHTS_VIDEO_PATH:String = Paths.stripLibrary(Paths.videos('introSelect'));
  #end

  #if hxvlc
  static final LIGHTS_VIDEO_PATH:String = Paths.videos('introSelect');
  #end

  public static var instance:IntroSubState = null;

  public override function create():Void
  {
    instance = this;

    if (Save.instance.oldChar)
    {
      onLightsEnd();
      return;
    }
    // Pause existing music.
    if (FlxG.sound.music != null)
    {
      FlxG.sound.music.destroy();
      FlxG.sound.music = null;
    }

    #if html5
    trace('Playing web video ${LIGHTS_VIDEO_PATH}');
    playVideoHTML5(LIGHTS_VIDEO_PATH);
    #end

    #if hxvlc
    trace('Playing native video ${LIGHTS_VIDEO_PATH}');
    playVideoNative(LIGHTS_VIDEO_PATH);
    #end

    #if !FEATURE_VIDEO_PLAYBACK
    onLightsEnd();
    #end
  }

  #if html5
  var vid:FlxVideo;

  function playVideoHTML5(filePath:String):Void
  {
    // Video displays OVER the FlxState.
    vid = new FlxVideo(filePath);

    vid.scrollFactor.set();
    if (vid != null)
    {
      vid.zIndex = 0;

      vid.finishCallback = onLightsEnd;

      add(vid);
    }
    else
      trace('ALERT: Video is null! Could not play cutscene!');
  }
  #end

  #if hxvlc
  var vid:FunkinVideoSprite;

  function playVideoNative(filePath:String):Void
  {
    // Video displays OVER the FlxState.
    vid = new FunkinVideoSprite(0, 0);

    vid.scrollFactor.set();

    if (vid != null)
    {
      vid.zIndex = 0;
      vid.bitmap.onEndReached.add(onLightsEnd);

      add(vid);
      if (vid.load(filePath)) vid.play();
    }
    else
      trace('ALERT: Video is null! Could not play cutscene!');
  }
  #end

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    // if (!introSound.paused)
    // {
    //   #if html5
    //   @:privateAccess
    //   vid.netStream.seek(introSound.time);
    //   #elseif hxvlc
    //   vid.bitmap.time = Std.int(introSound.time);
    //   #end
    // }
  }

  /**
   * When the lights video finishes, it will close the substate
   */
  function onLightsEnd():Void
  {
    #if FEATURE_VIDEO_PLAYBACK
    if (vid != null)
    {
      #if hxvlc
      vid.stop();
      #end
      remove(vid);
      vid.destroy();
      vid = null;
    }
    #end

    FlxG.camera.zoom = 1;

    close();
  }

  public override function destroy():Void
  {
    super.destroy();
    instance = null;
  }
}

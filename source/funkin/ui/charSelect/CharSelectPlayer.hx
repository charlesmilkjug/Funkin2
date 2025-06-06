package funkin.ui.charSelect;

import funkin.graphics.adobeanimate.FlxAtlasSprite;
import funkin.modding.IScriptedClass.IBPMSyncedScriptedClass;
import funkin.modding.events.ScriptEvent;

@:nullSafety
class CharSelectPlayer extends FlxAtlasSprite implements IBPMSyncedScriptedClass
{
  var pressedSelect:Bool = false;

  public function new(x:Float, y:Float)
  {
    super(x, y, Paths.animateAtlas("charSelect/bfChill"));

    onAnimationComplete.add((animLabel:String) -> {
      switch (animLabel)
      {
        case "slidein":
          if (hasAnimation("slidein idle point"))
          {
            if (pressedSelect)
            {
              playAnimation("select");
              pressedSelect = false;
            }
            else
              playAnimation("slidein idle point", true, false, false);
          }
          else
          {
            if (pressedSelect)
            {
              playAnimation("select");
              pressedSelect = false;
            }
            else
              playAnimation("idle", true, false, false);
          }
        case "deselect":
          playAnimation("deselect loop start", true, false, true);

        case "slidein idle point", "cannot select Label", "unlock":
          playAnimation("idle", true, false, false);
        case "idle":
          trace('Waiting for onBeatHit');
      }
    });
  }

  public function onStepHit(event:SongTimeScriptEvent):Void {}

  public function onBeatHit(event:SongTimeScriptEvent):Void
  {
    // TODO: There's a minor visual bug where there's a little stutter.
    // This happens because the animation is getting restarted while it's already playing.
    // I tried make this not interrupt an existing idle,
    // but isAnimationFinished() and isLoopComplete() both don't work! What the hell?
    // danceEvery isn't necessary if that gets fixed.
    //
    if (getCurrentAnimation() == "idle") playAnimation("idle", true, false, false);
  }

  public function updatePosition(str:String)
  {
    switch (str)
    {
      case "bf":
        x = 0;
        y = 0;
      case "pico":
        x = 0;
        y = 0;
      case "random":
    }
  }

  public function switchChar(str:String, pressedSelect:Bool = false)
  {
    switch (str)
    {
      default:
        loadAtlas(Paths.animateAtlas("charSelect/" + str + "Chill"));
    }

    playAnimation("slidein", true, false, false);

    this.pressedSelect = pressedSelect;

    updateHitbox();

    updatePosition(str);
  }

  public function onScriptEvent(event:ScriptEvent):Void {}

  public function onCreate(event:ScriptEvent):Void {}

  public function onDestroy(event:ScriptEvent):Void {}

  public function onUpdate(event:UpdateScriptEvent):Void {}
}
